% %% ----- Extract raw data for OMR movie -----
% % New Fasttrack
% 
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
selpath = uigetdir('D:\OMR_acoustic_experiments\');
disp('Movie to analyse?');
nb(1) = input('from ??     ');
nb(2) = input('to ??       ');

F.Root = [selpath(1:end-8) 'data\'];

wb = waitbar(0,sprintf('Extract bout, movie 1 / %d', nb(2)-nb(1)+1));
for k = nb(1):nb(2)
%     k = nb(1);
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
            OMR_angle = P.OMR.angle;
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
                xbody, ybody, ang_body, ang_tail, fps);
            
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
            angle_OMR = nan(size(xbody));
            angle_tail = nan(size(xbody));
            for f = 1:nfish
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
                ybody, nfish, seq, fps, f_remove, checkIm);
            
            % -- determine fish that are present from the OMR beginning
            if nb_frame == 1500 % 0s no OMR the 10s OMR
                fish_to_consider = find(isnan(xbody(:,1)) == 0)';
                nfish = size(fish_to_consider,2);
                fish_to_consider_FT = fish_ok(fish_to_consider)-1;
                fish_to_remove = find(isnan(xbody(:,1)) == 1)';
                xbody(fish_to_remove,:) = [];
                ybody(fish_to_remove,:) = [];
                angle_OMR(fish_to_remove,:) = [];
                angle_tail(fish_to_remove,:) = [];
                indbout(fish_to_remove) = [];
                
                a = 0;
                for i = 1:nfish
                    indbt = indbout{i};
                    t = find(indbt(1,:) > 1);
                    a1 = size(t,2);
                    if a1 > a
                        a = a1;
                    end
                end
                % -- Determine OMR IBI
                IBI = nan(size(fish_to_consider));
                for i = 1:nfish
                    if sum(sum(indbout{i}(:,:))) ~= 0
                        b = find(indbout{i}(1,:)>1);
                        IBI(i) = mean(diff(indbout{i}(1,b)))/fps;
                    end
                end
                
                % -- Determine latency first bout
                lat_im = nan(size(fish_to_consider));
                lat_ms = lat_im;
                % i = 1;
                for i = 1:nfish
                    indbt = indbout{i};
                    t = find(indbt(1,:) > 1,1);
                    if isempty(t) == 0
                        lat_im(i) = indbt(1,t);
                        lat_ms(i) = (indbt(1,t)-1)/150;
                    end
                end
                
                % -- Determine direction of bouts (toward, against OMR, forward bout)
                % mat_turn
                % line: fish
                % column: bout
                mat_turn = nan(nfish,a);
                for i = 1:nfish
                    indbt = indbout{i};
                    t = find(indbt(1,:) > 1);
                    j = 1;
                    if isempty(t) == 0
                        while j <= size(t,2)
                            if indbt(1,t(j))-10 > 0
                                ang_b = mean(angle_OMR(i,indbt(1,t(j))-10:indbt(1,t(j))));
                                ang_b = mod(ang_b, 2*pi);
                            else
                                ang_b = angle_OMR(i,indbt(1,t(j)));
                            end
                            if ang_b > pi
                                ang_b = ang_b - 2*pi;
                            end
                            turn = angle_OMR(i,indbt(2,t(j)))-angle_OMR(i,indbt(1,t(j)));
                            if abs(turn) > 20*pi/180
                                mat_turn(i,j) = -sign(ang_b)*sign(turn);
                            else
                                mat_turn(i,j) = 0;
                            end
                            j = j+1;
                        end
                    end
                end
            elseif nb_frame ~= 1500 % 1s no OMR and then OMR
                fish_to_consider = find(isnan(xbody(:,150)) == 0)';
                nfish = size(fish_to_consider,2);
                fish_to_consider_FT = fish_ok(fish_to_consider)-1;
                fish_to_remove = find(isnan(xbody(:,150)) == 1)';
                xbody(fish_to_remove,:) = [];
                ybody(fish_to_remove,:) = [];
                angle_OMR(fish_to_remove,:) = [];
                angle_tail(fish_to_remove,:) = [];
                indbout(fish_to_remove) = [];
                
                a = 0;
                for i = 1:nfish
                    indbt = indbout{i};
                    t = find(indbt(1,:) > 150);
                    a1 = size(t,2);
                    if a1 > a
                        a = a1;
                    end
                end
                % -- Determine OMR IBI
                IBI = nan(size(fish_to_consider));
                for i = 1:nfish
                    if sum(sum(indbout{i}(:,:))) ~= 0
                        b = find(indbout{i}(1,:)>150);
                        IBI(i) = mean(diff(indbout{i}(1,b)))/fps;
                    end
                end
                
                % -- Determine latency first bout
                lat_im = nan(size(fish_to_consider));
                lat_ms = lat_im;
                % i = 1;
                for i = 1:nfish
                    indbt = indbout{i};
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
                mat_turn = nan(nfish,a);
                for i = 1:nfish
                    indbt = indbout{i};
                    t = find(indbt(1,:) > 150);
                    j = 1;
                    if isempty(t) == 0
                        while j <= size(t,2)
                            if indbt(1,t(j))-10 > 0
                                ang_b = mean(angle_OMR(i,indbt(1,t(j))-10:indbt(1,t(j))));
                                ang_b = mod(ang_b, 2*pi);
                            else
                                ang_b = angle_OMR(i,indbt(1,t(j)));
                            end
                            if ang_b > pi
                                ang_b = ang_b - 2*pi;
                            end
                            turn = angle_OMR(i,indbt(2,t(j)))-angle_OMR(i,indbt(1,t(j)));
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
            
            f_remove = 1:nb_detected_object;
            fish_to_remove = setdiff(f_remove,fish_to_consider);
            
            % -- save raw data
            save(fullfile(path(1:end-21), 'raw_data.mat'), 'ang_body_raw', 'ang_tail_raw',...
                'angle_OMR', 'angle_tail', 'file', 'fish_to_consider', 'fish_to_consider_FT',...
                'fish_to_remove', 'fps', 'IBI', 'indbout', 'lat_im', 'lat_ms', 'mat_turn',...
                'nb_detected_object', 'nb_frame', 'OMR_angle', 'P', 'path', 'xbody', ...
                'xbody_raw', 'ybody', 'ybody_raw');
            disp('Raw data saved')
            %         else
            %             X = ['Raw data already extracted run ', num2str(d), num2str(u)];
            %             disp(X)
            %         end
%         else
%             load(fullfile(path,'raw_data.mat'))
%             F.dpf = P.fish(4);
%             F.dpf = [F.dpf '_dpf'];
%             angOMR = angle_OMR;
%             ib = IBI;
%             clear IBI angle_OMR
%         end
%         
        % save summary data
        if isfolder(F.path) == 0
            mkdir(F.path);
        end
        
        ang_OMR = angle_OMR;
        angle_OMR = [];
        ib = IBI;
        IBI = [];
        OMR_ang = OMR_angle;
        OMR_angle = [];
        
        
        if isfile(fullfile(F.path,'data.mat')) == 1
            D = F.load('data.mat');
            a = size(D.IBI,2);
            
            D.angle_OMR{a+1} = ang_OMR;
            nb_fish = [D.nb_fish nfish];
            D.fish_num_FT{a+1} = fish_to_consider_FT;
            D.IBI{a+1} = ib;
            D.latency_im{a+1} = lat_im;
            D.latency_ms{a+1} = lat_ms;
            D.bout_direction{a+1} = mat_turn;
            OMR_angle = [D.OMR_angle OMR_ang];
            
            angle_OMR = D.angle_OMR;
            fish_num_FT = D.fish_num_FT;
            IBI = D.IBI;
            latency_im = D.latency_im;
            latency_ms = D.latency_ms;
            bout_direction = D.bout_direction;
            
            save(fullfile(F.path,'data.mat'),'angle_OMR', 'nb_fish', 'fish_num_FT',...
                'IBI', 'latency_im', 'latency_ms', 'bout_direction','OMR_angle');
        else
            angle_OMR{1} = ang_OMR;
            nb_fish(1) = nfish;
            fish_num_FT{1} = fish_to_consider_FT;
            IBI{1} = ib;
            latency_im{1} = lat_im;
            latency_ms{1} = lat_ms;
            bout_direction{1} = mat_turn;
            OMR_angle(1) = OMR_ang;
            
            save(fullfile(F.path,'data.mat'),'angle_OMR', 'nb_fish', 'fish_num_FT',...
                'IBI', 'latency_im', 'latency_ms', 'bout_direction','OMR_angle');
        end
    else
        no_tracking = [no_tracking, k];
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