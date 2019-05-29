%% ----- Extract raw data for OMR movie -----
% New Fasttrack

clear;
clc;
close all;

warning off

nb = [nan, nan];
no_tracking = [];
file = 'tracking.txt';

F = Focus_OMR();
F.cycle = '10_mm';
F.speed = '20_mm_s';

disp('Select the folder with the movie to analyze');
selpath = uigetdir('D:\OMR_acoustic_experiments\OMR\');
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
        %         if isfile(fullfile(path,'raw_data.mat')) == 0
        
        path = fullfile(path,'movie','Tracking_Result');
        t = readtable(fullfile(path,file),'Delimiter','\t');
        s = table2array(t);
        
        
        p = path(1:end-21);
        f = ['parametersrun_', num2str(d), num2str(u), '.mat'];
        load(fullfile(p,f));
        
        fps = 150;
        OMR_angle = P.OMR.angle*pi/180;
        F.dpf = P.fish(4);
        F.dpf = [F.dpf '_dpf'];
        
        % -- Extract information from fast track
        [nb_frame, nb_detected_object, xbody, ybody, ang_body, ang_tail]...
            = extract_parameters_from_fast_track(s);
        
        % -- Determine the swimming sequence
        [seq, xbody, ybody, ang_body, ang_tail] = extract_sequence(nb_detected_object,...
            xbody, ybody, ang_body, ang_tail, fps);
        
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
        angle_OMR = nan(nb_detected_object,nb_frame);
        angle_tail = nan(nb_detected_object,nb_frame);
        for f = 1:nb_detected_object
            ind_seq = seq{f}(:,:);
            while isempty(ind_seq) == 0
                % correct body angle of the sequence
                cang = ang_body(f,ind_seq(1,1):ind_seq(2,1));
                [~, corr_angle] = correct_angle_sequence(cang, fig, OMR_angle, 230*pi/180);
                angle_OMR(f,ind_seq(1,1):ind_seq(2,1)) = corr_angle;
                
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
        
        % -- Determine IBI
        IBI = nan(1,nb_detected_object);
        for f = 1:nb_detected_object
            if sum(sum(indbout{f}(:,:))) ~= 0
                IBI(f) = mean(diff(indbout{f}(1,:)))/fps;
            end
        end
        
        % -- determine fish that are present from the OMR beginning
        if nb_frame == 1650 % 1s no OMR and 10s OMR
            fish_to_consider = find(isnan(xbody(:,150)) == 0)';
            a = 0;
            for i = 1:size(fish_to_consider,2)
                f = fish_to_consider(i);
                indbt = indbout{f};
                t = find(indbt(1,:) > 150);
                a1 = size(t,2);
                if a1 > a
                    a = a1;
                end
            end
            
            % -- Determine latency first bout
            lat_im = nan(1,size(fish_to_consider,2));
            lat_ms = lat_im;
            % i = 1;
            for i = 1:size(fish_to_consider,2)
                f = fish_to_consider(i);
                indbt = indbout{f};
                t = find(indbt(1,:) > 150,1);
                if isempty(t) == 0
                    lat_im(i) = indbt(1,t);
                    lat_ms(i) = (indbt(1,t)-150)/150;
                end
            end
            
            % -- Determine direction of bouts (toward, against OMR, forward bout)
            % mat_turn
            % line: fish
            % column: bout
            mat_turn = nan(size(fish_to_consider,2),a);
            for i = 1:size(fish_to_consider,2)
                f = fish_to_consider(i);
                indbt = indbout{f};
                t = find(indbt(1,:) > 150);
                j = 1;
                if isempty(t) == 0
                    while j <= size(t,2)
                        if indbt(1,t(j))-10 > 0
                            ang_b = mean(angle_OMR(f,indbt(1,t(j))-10:indbt(1,t(j))));
                            ang_b = mod(ang_b, 2*pi);
                        else
                            ang_b = angle_OMR(f,indbt(1,t(j)));
                        end
                        if ang_b > pi
                            ang_b = ang_b - 2*pi;
                        end
                        turn = angle_OMR(f,indbt(2,t(j)))-angle_OMR(f,indbt(1,t(j)));
                        if abs(turn) > 20*pi/180
                            mat_turn(i,j) = -sign(ang_b)*sign(turn);
                        else
                            mat_turn(i,j) = 0;
                        end
                        j = j+1;
                    end
                end
            end
            
        elseif nb_frame == 1500 % 10s OMR
            fish_to_consider = find(isnan(xbody(:,1)) == 0)';
            a = 0;
            for i = 1:size(fish_to_consider,2)
                f = fish_to_consider(i);
                indbt = indbout{f};
                a1 = size(indbt,2);
                if a1 > a
                    a = a1;
                end
            end
            
            % -- Determine latency first bout
            lat_im = nan(1,size(fish_to_consider,2));
            lat_ms = lat_im;
            % i = 1;
            for i = 1:size(fish_to_consider,2)
                f = fish_to_consider(i);
                indbt = indbout{f};
                t = find(indbt(1,:) > 0,1);
                if isempty(t) == 0
                    lat_im(i) = indbt(1,t);
                    lat_ms(i) = (indbt(1,t)-1)/150;
                end
            end
            
            % -- Determine direction of bouts
            % mat_turn
            % line: fish
            % column: bout
            mat_turn = nan(size(fish_to_consider,2),a);
            for i = 1:size(fish_to_consider,2)
                f = fish_to_consider(i);
                indbt = indbout{f};
                t = find(indbt(1,:) > 0);
                j = 1;
                if isempty(t) == 0
                    while j <= size(t,2)
                        if indbt(1,t(j))-10 > 0
                            ang_b = mean(angle_OMR(f,indbt(1,t(j))-10:indbt(1,t(j))));
                            ang_b = mod(ang_b, 2*pi);
                        else
                            ang_b = angle_OMR(f,indbt(1,t(j)));
                        end
                        if ang_b > pi
                            ang_b = ang_b - 2*pi;
                        end
                        turn = angle_OMR(f,indbt(2,t(j)))-angle_OMR(f,indbt(1,t(j)));
                        if abs(turn) > 20*pi/180
                            mat_turn(i,j) = -sign(ang_b)*sign(turn);
                        else
                            mat_turn(i,j) = 0;
                        end
                        j = j+1;
                    end
                end
            end
        end
        
        % -- save raw data
        save(fullfile(path(1:end-21), 'raw_data.mat'), 'ang_body', 'angle_OMR',...
            'f_remove', 'file', 'fish_to_consider', 'fps', 'IBI', 'indbout',...
            'nb_detected_object', 'nb_frame', 'OMR_angle', 'P', 'path', 'seq',...
            'xbody', 'ybody','lat_im','lat_ms','mat_turn');
        disp('Raw data saved')
        %         else
        %             X = ['Raw data already extracted run ', num2str(d), num2str(u)];
        %             disp(X)
        %         end
    else
        no_tracking = [no_tracking, k];
    end
    
    if isfolder(F.path) == 0
        mkdir(F.path);
    end
    
    if isfile(fullfile(F.path,'data_latency.mat')) == 1
        D = F.load('data_latency.mat');
        latency_im = [D.latency_im lat_im];
        latency_ms = [D.latency_ms lat_ms];
        bout_direction = D.bout_direction;
        
        a = size(bout_direction{1},2);
        if a > 1
            b = size(bout_direction,2);
            if b > 0
                bout_direction{b+1} = mat_turn;
            end
        else
            bout_direction{1} = mat_turn;
        end
        save(fullfile(F.path,'data_latency.mat'),'latency_im','latency_ms','bout_direction');
    else
        latency_im = lat_im;
        latency_ms = lat_ms;
        bout_direction{1} = mat_turn;
        save(fullfile(F.path,'data_latency.mat'),'latency_im','latency_ms','bout_direction');
    end
    
    
    
    waitbar((k-nb(1)+1)/(nb(2)-nb(1)+1),wb,sprintf('Extract bout, movie %d / %d', k-nb(1)+1, nb(2)-nb(1)+1));
end

if isempty(no_tracking) == 0
    X = ['No tracking for run ', num2str(no_tracking)];
    disp(X);
end

close(wb)
close all;
path