%% ----- Extract raw data for spontaneous activity movie -----
% New Fasttrack

clear;
clc;
close all;

nb = [nan, nan];
no_tracking = [];
file = 'tracking.txt';

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
            
            fps = 150;
            OMR_angle = 0;
            
            % -- Extract information from fast track
            [nb_frame, nb_detected_object, xbody, ybody, ang_body]...
                = extract_parameters_from_fast_track(s);
            
            % -- Determine the swimming sequence
            [seq, xbody, ybody, ang_body] = extract_sequence(nb_detected_object,...
                xbody, ybody, ang_body, fps);
            
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
            for i = 1:size(f_remove,2)
                seq{f_remove(i)} = [];
            end
            
            % -- Correct angle
            fig = 0;
            angle = nan(nb_detected_object,nb_frame);
            for f = 1:nb_detected_object
                ind_seq = seq{f}(:,:);
                while isempty(ind_seq) == 0
                    cang = ang_body(f,ind_seq(1,1):ind_seq(2,1));
                    
                    % correct angle of the sequence
                    [~, corr_angle] = correct_angle_sequence(cang, fig, OMR_angle);
                    angle(f,ind_seq(1,1):ind_seq(2,1)) = corr_angle;
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
                IBI(f) = mean(diff(indbout{f}(1,:)))/fps;
            end
           
            % -- save raw data
            save(fullfile(path(1:end-21), 'raw_data.mat'), 'ang_body', 'angle',...
                'f_remove', 'file', 'fps', 'IBI', 'indbout', 'nb_detected_object', 'nb_frame',...
                'P', 'path', 'seq', 'xbody', 'ybody');
            disp('Raw data saved')
        else
            X = ['Raw data already extracted run ', num2str(d), num2str(u)];
            disp(X)
        end
    else
        no_tracking = [no_tracking, k];
    end
    waitbar(k/nb(2)-nb(1)+1,wb,sprintf('Extract bout, movie %d / %d', k, nb(2)-nb(1)+1));
end

if isempty(no_tracking) == 0
    X = ['No tracking for run ', num2str(no_tracking)];
    disp(X);
end

close(wb)
close all;