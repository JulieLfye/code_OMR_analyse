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
selpath = uigetdir('D:\OMR_acoustic_experiments\');
disp('Movie to analyse?');
nb(1) = input('from ??     ');
nb(2) = input('to ??       ');

F.Root = [selpath(1:end-8) 'data\'];

wb = waitbar(0,sprintf('Extract bout, movie 1 / %d', nb(2)-nb(1)+1));
for k = nb(1):nb(2)
    
    d = floor(k/10);
    u = floor(k-d*10);
    run = ['run_', num2str(d), num2str(u)];
    path = fullfile(selpath,run);
    
    if isfolder(fullfile(path, 'movie','Tracking_Result')) == 1
        %         if isfile(fullfile(path,'raw_data.mat')) == 0
        
        path = fullfile(path,'movie','Tracking_Result');
        t = readtable(fullfile(path,file),'Delimiter','\t');
        s = table2array(t);
        
        p = path(1:end-21);
        f = ['parametersrun_', num2str(d), num2str(u), '.mat'];
        load(fullfile(p,f));
        
        fps = 150;
        if isfield(P,'OMR') == 1
            OMR_angle = P.OMR.angle;
        else
            OMR_angle = 0;
        end
        F.dpf = P.fish(4);
        F.dpf = [F.dpf '_dpf'];
        
        % -- Extract information from fast track
        [nb_frame, nb_detected_object, xbody, ybody, ang_body, ang_tail]...
            = extract_parameters_from_fast_track(s);
        xbody_raw = xbody;
        ybody_raw = ybody;
        ang_body_raw = ang_body;
        ang_tail_raw = ang_tail;
        
        % -- Determine the swimming sequence
        [seq, xbody, ybody, ang_body, ang_tail] = extract_sequence(nb_detected_object,...
            xbody, ybody, ang_body,ang_tail, fps);
        
        % -- Remove too short sequence
        f_remove = [];
        fish_ok = [];
        for i = 1:nb_detected_object
            f(i) = size(find(isnan(xbody(i,:))==0),2);
            if f(i) < 75
                f_remove = [f_remove i];
            else
                fish_ok = [fish_ok i];
            end
        end
        
        xbody(f_remove,:) = [];
        ybody(f_remove,:) = [];
        ang_body(f_remove,:) = [];
        ang_tail(f_remove,:) = [];
        seq(f_remove) = [];
        
        % -- Correct angle
        fig = 0;
        nfish = size(xbody,1);
        angle = nan(size(xbody));
        angle_tail = nan(size(xbody));
        for f = 1:nfish
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
            ybody,  nfish, seq, fps, f_remove, checkIm);
        
        % -- Determine IBI
        fish_to_consider = find(isnan(xbody(:,1)) == 0)';
        nfish = size(fish_to_consider,2);
        fish_to_consider_FT = fish_ok(fish_to_consider)-1;
        fish_to_remove = find(isnan(xbody(:,1)) == 1)';
        xbody(fish_to_remove,:) = [];
        ybody(fish_to_remove,:) = [];
        angle(fish_to_remove,:) = [];
        angle_tail(fish_to_remove,:) = [];
        indbout(fish_to_remove) = [];
        
        IBI = nan(size(fish_to_consider));
        for i = 1:nfish
            if sum(sum(indbout{i}(:,:))) ~= 0
                IBI(i) = mean(diff(indbout{i}(1,:)))/fps;
            end
        end
        
        % -- Determine latency first bout with moving window
        lat = [];
        for p = 1:nb_frame
            fa = find(isnan(xbody(:,p)) == 0)';
            for i = 1:size(fa,2)
                f = fa(i);
                indbt = indbout{f};
                t = find(indbt(1,:) > p,1);
                if isempty(t) == 0
                    lat = [lat, (indbt(1,t)-p)/150];
                end
            end
        end
        
        % -- Determine direction of bouts (towards, against, forward bout)
        % mat_turn
        % line: fish
        % column: bout
        
        a = 0;
        for i = 1:nfish
            indbt = indbout{i};
            a1 = size(indbt,2);
            if a1 > a
                a = a1;
            end
        end
        
        mat_turn = nan(nfish,a);
        for i = 1:nfish
            indbt = indbout{i};
            t = find(indbt(1,:) > 1);
            j = 1;
            if isempty(t) == 0
                while j <= size(t,2)
                    if indbt(1,t(j))-10 > 0
                        ang_b = mean(angle(i,indbt(1,t(j))-10:indbt(1,t(j))));
                        ang_b = mod(ang_b, 2*pi);
                    else
                        ang_b = angle(i,indbt(1,t(j)));
                    end
                    if ang_b > pi
                        ang_b = ang_b - 2*pi;
                    end
                    turn = angle(i,indbt(2,t(j)))-angle(i,indbt(1,t(j)));
                    if abs(turn) > 20*pi/180
                        mat_turn(i,j) = -sign(ang_b)*sign(turn);
                    else
                        mat_turn(i,j) = 0;
                    end
                    j = j+1;
                end
            end
        end
        
        f_remove = 1:nb_detected_object;
        fish_to_remove = setdiff(f_remove,fish_to_consider);
        
        % -- save raw data
        path = fullfile(selpath,run);
        save(fullfile(path, 'raw_data.mat'), 'ang_body_raw', 'ang_tail_raw','angle',...
            'angle_tail', 'file', 'fish_to_consider', 'fish_to_consider_FT', ...
            'fish_to_remove', 'fps', 'IBI', 'indbout', 'lat', 'mat_turn',...
            'nb_detected_object', 'nb_frame', 'OMR_angle', 'P', 'path', 'xbody', ...
            'xbody_raw', 'ybody', 'ybody_raw');
        disp('Raw data saved')
        
        %     else
        %         load(fullfile(path,'raw_data.mat'));
        %         F.dpf = P.fish(4);
        %         F.dpf = [F.dpf '_dpf'];
        %     end
        
        if isfolder(F.path) == 0
            mkdir(F.path);
        end
        
        if isfile(fullfile(F.path,'data.mat')) == 1
            D = F.load('data.mat');
            a = size(D.IBI_spon,2);
            
            D.angle_spon{a+1} = angle;
            nb_fish_spon = [D.nb_fish_spon nfish];
            D.fish_num_FT_spon{a+1} = fish_to_consider_FT;
            D.IBI_spon{a+1} = IBI;
            D.latency_ms_spon{a+1} = lat;
            D.bout_dir_spon{a+1} = mat_turn;
            OMR_angle_spon = [D.OMR_angle_spon OMR_angle];
            
            angle_spon = D.angle_spon;
            fish_num_FT_spon  = D.fish_num_FT_spon;
            IBI_spon = D.IBI_spon;
            latency_ms_spon = D.latency_ms_spon;
            bout_dir_spon = D.bout_dir_spon;
            
            save(fullfile(F.path,'data.mat'),'angle_spon','nb_fish_spon',...
                'fish_num_FT_spon', 'IBI_spon', 'latency_ms_spon','bout_dir_spon',...
                'OMR_angle_spon');
        else
            angle_spon{1} = angle;
            nb_fish_spon(1) = nfish;
            fish_num_FT_spon{1} = fish_to_consider_FT;
            IBI_spon{1} = IBI;
            latency_ms_spon{1} = lat;
            bout_dir_spon{1} = mat_turn;
            OMR_angle_spon(1) = OMR_angle;
            
            save(fullfile(F.path,'data.mat'),'angle_spon', 'nb_fish_spon',...
                'fish_num_FT_spon', 'IBI_spon', 'latency_ms_spon','bout_dir_spon',...
                'OMR_angle_spon');
        end
    else
        no_tracking = [no_tracking, k];
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