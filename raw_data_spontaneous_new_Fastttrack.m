%% ----- Extract raw data for spontaneous activity movie -----
% New Fasttrack

clear;
clc;
close all;

warning off

nb = [nan, nan];
no_tracking = [];
file = 'tracking.txt';
F = Focus_spontaneous();

disp('Select the folder with the movie to analyze');
selpath = uigetdir('D:\OMR_acoustic_experiments\spontaneous');
disp('Movie to analyse?');
nb(1) = input('from ??     ');
nb(2) = input('to ??       ');

tic
wb = waitbar(0,sprintf('Extract bout, movie 1 / %d', nb(2)-nb(1)+1));
for k = nb(1):nb(2)
    
    d = floor(k/10);
    u = floor(k-d*10);
    run = ['run_', num2str(d), num2str(u)];
    path = fullfile(selpath,run);
    
    if isfolder(fullfile(path, 'movie','Tracking_Result')) == 1
        if isfile(fullfile(path,'raw_data.mat')) == 0
            path = fullfile(path,'movie','Tracking_Result');
            t = readtable(fullfile(path,file),'Delimiter','\t');
            s = table2array(t);
            
            
            p = path(1:end-21);
            f = ['parametersrun_', num2str(d), num2str(u), '.mat'];
            load(fullfile(p,f));
            F.dpf = P.fish(4);
            F.dpf = [F.dpf '_dpf'];
            
            fps = 150;
            OMR_angle = 0;
            
            % -- Extract information from fast track
            [nb_frame, nb_detected_object, xbody, ybody, ang_body, ang_tail]...
                = extract_parameters_from_fast_track(s);
            
            % -- Determine the swimming sequence
            [seq, xbody, ybody, ang_body, ang_tail] = extract_sequence(nb_detected_object,...
                xbody, ybody, ang_body,ang_tail, fps);
            
            % -- Remove too short sequence
            f_remove = [];
            for i = 1:nb_detected_object
                f(i) = size(find(isnan(xbody(i,:))==0),2);
                if f(i) < 55
                    f_remove = [f_remove i];
                end
            end
            
            xbody(f_remove,:) = nan;
            ybody(f_remove,:) = nan;
            ang_body(f_remove,:) = nan;
            ang_tail(f_remove,:) = nan;
            for i = 1:size(f_remove,2)
                seq{f_remove(i)} = [];
            end
            
            % -- Correct angle
            fig = 0;
            angle = nan(nb_detected_object,nb_frame);
            angle_tail = nan(nb_detected_object,nb_frame);
            for f = 1:nb_detected_object
                ind_seq = seq{f}(:,:);
                while isempty(ind_seq) == 0
                    % correct body angle of the sequence
                    cang = ang_body(f,ind_seq(1,1):ind_seq(2,1));
                    [~, corr_angle] = correct_angle_sequence(cang, fig, OMR_angle, 230*pi/180);
                    angle(f,ind_seq(1,1):ind_seq(2,1)) = corr_angle;
                    
                    % correct tail angle of the sequence
                    cang = ang_tail(f,ind_seq(1,1):ind_seq(2,1));
                    [~, corr_angle] = correct_angle_sequence(cang, fig, OMR_angle, 2);
                    angle_tail(f,ind_seq(1,1):ind_seq(2,1)) = corr_angle;
                    ind_seq(:,1) = [];
                end
            end
            
            % -- Find bout
            checkIm = 0;
            [indbout, xbody, ybody] = extract_bout(xbody,...
                ybody, nb_detected_object, seq, fps, f_remove, checkIm);
            
        else
            load(fullfile(path,'raw_data.mat'));
            F.dpf = P.fish(4);
            F.dpf = [F.dpf '_dpf'];
        end
        
        % -- Determine IBI
        fish_to_consider = find(isnan(xbody(:,1)) == 0)';
        IBI = nan(1,size(fish_to_consider,2));
        for i = 1:size(fish_to_consider,2)
            f = fish_to_consider(i);
            if sum(sum(indbout{f}(:,:))) ~= 0
                IBI(i) = mean(diff(indbout{f}(1,:)))/fps;
            end
        end
        
        % -- Determine latency first bout with moving window
        lat = [];
        for p = 1:nb_frame
            fish_to_consider = find(isnan(xbody(:,p)) == 0)';
            for i = 1:size(fish_to_consider,2)
                f = fish_to_consider(i);
                indbt = indbout{f};
                t = find(indbt(1,:) > p,1);
                if isempty(t) == 0
                    lat = [lat, (indbt(1,t)-p)/150];
                end
            end
        end
        
        % -- 
        
        % -- Determine direction of bouts (towards, against, forward bout)
        a = 0;
        fish_to_consider = find(isnan(xbody(:,1)) == 0)';
        for i = 1:size(fish_to_consider,2)
            f = fish_to_consider(i);
            indbt = indbout{f};
            a1 = size(indbt,2);
            if a1 > a
                a = a1;
            end
        end
        mat_turn = nan(size(fish_to_consider,2),a);
        for i = 1:size(fish_to_consider,2)
            f = fish_to_consider(i);
            indbt = indbout{f};
            t = find(indbt(1,:) > 150);
            j = 1;
            if isempty(t) == 0
                while j <= size(t,2)
                    if indbt(1,t(j))-10 > 0
                        ang_b = mean(angle(f,indbt(1,t(j))-10:indbt(1,t(j))));
                        ang_b = mod(ang_b, 2*pi);
                    else
                        ang_b = angle_OMR(f,indbt(1,t(j)));
                    end
                    if ang_b > pi
                        ang_b = ang_b - 2*pi;
                    end
                    turn = angle(f,indbt(2,t(j)))-angle(f,indbt(1,t(j)));
                    if abs(turn) > 20*pi/180
                        mat_turn(i,j) = -sign(ang_b)*sign(turn);
                    else
                        mat_turn(i,j) = 0;
                    end
                    j = j+1;
                end
            end
        end
        
        % mat_turn
        % line: fish
        % column: bout
        
        % -- save raw data
        path = fullfile(selpath,run);
        save(fullfile(path, 'raw_data.mat'), 'ang_body', 'ang_tail','angle',...
            'angle_tail', 'f_remove', 'fish_to_consider', 'fps', 'IBI', 'indbout',...
            'lat','mat_turn', 'nb_detected_object', 'nb_frame', 'P', 'seq', 'xbody', 'ybody');
        disp('Raw data saved')
        
    else
        no_tracking = [no_tracking, k];
    end
    
    if isfolder(F.path) == 0
        mkdir(F.path);
    end
    
    if isfile(fullfile(F.path,'data.mat')) == 1
        D = F.load('data.mat');
        
        a = size(D.IBI_spon,2);
        D.angle_spon{a+1} = angle;
        D.latency_ms_spon{a+1} = lat;
        D.bout_dir_spon{a+1} = mat_turn;
        D.IBI_spon{a+1} = IBI;
        D.n_fish = [D.n_fish size(fish_to_consider,2)];
        angle_spon = D.angle_spon;
        latency_ms_spon = D.latency_ms_spon;
        bout_dir_spon = D.bout_dir_spon;
        IBI_spon = D.IBI_spon;
        n_fish = D.n_fish;
        save(fullfile(F.path,'data.mat'),'angle_spon','latency_ms_spon','bout_dir_spon',...
            'IBI_spon', 'n_fish');
    else
        angle_spon{1} = angle;
        latency_ms_spon{1} = lat;
        bout_dir_spon{1} = mat_turn;
        IBI_spon{1} = IBI;
        n_fish = size(fish_to_consider,2);
        save(fullfile(F.path,'data.mat'),'angle_spon','latency_ms_spon','bout_dir_spon',...
            'IBI_spon', 'n_fish');
    end
    
    
    waitbar((k-nb(1)+1)/(nb(2)-nb(1)+1),wb,sprintf('Extract bout, movie %d / %d', k-nb(1)+2, nb(2)-nb(1)+1));
end

if isempty(no_tracking) == 0
    X = ['No tracking for run ', num2str(no_tracking)];
    disp(X);
end

close(wb)
close all;
path