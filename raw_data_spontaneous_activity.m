% extract raw data for spontaneous activity movie

if exist('ang_body','var') == 0
    clear;
    clc;
    close all;
    
    disp('Select the first frame of the binarized movie');
    [file,path] = uigetfile('*.tif',[],'C:\Users\LJP\Documents\MATLAB\these\data_spontaneous');
    t = readtable(fullfile(path,'Tracking_Result\tracking.txt'),'Delimiter','\t');
    s = table2array(t);
    
    disp('Select the experiment parameters file')
    [f,p] = uigetfile('.mat',[],path(1:end-10));
    load(fullfile(p,f));
    
    if isfile(fullfile(path(1:end-10), 'raw_data.mat')) == 0
        
        fps = input('fps of the movie? \n');
        date = path(end-25:end-18);
        
        [nb_tracked_object, nb_frame, nb_detected_object, xbody, ybody]...
            = extract_parameters_from_fast_track(s);
        
        % extract angle from the binarized movie
        tic
        [ang_body] = extract_angle_fish_OMR(nb_detected_object, nb_frame, 50, 50,...
            xbody, ybody, file, path, 0);
        toc
        
        % determine the swimming sequence
        [seq, xbody, ybody, ang_body] = extract_sequence(nb_detected_object,...
            xbody, ybody, ang_body, fps);
        
        % correct angle
        ff = find(isnan(seq(1,:))==1);
        angle = nan(nb_detected_object,nb_frame);
        OMRangle = 0;
        for f = 1:nb_detected_object
            if f == 1
                ind_seq = seq(:,1:ff(f)-1);
            else
                ind_seq = seq(:,ff(f-1)+1:ff(f)-1);
            end
            
            while isempty(ind_seq) == 0
                cang = ang_body(f,ind_seq(1,1):ind_seq(2,1));
                
                % correct angle of the sequence
                [~, corr_angle] = correct_angle_sequence(cang, 0, OMRangle);
                angle(f,ind_seq(1,1):ind_seq(2,1)) = corr_angle;
                ind_seq(:,1) = [];
            end
        end
        
        %save raw data
        save(fullfile(path(1:end-10), 'raw_data.mat'), 'ang_body', 'angle',...
            'date', 'file', 'fps', 'nb_detected_object', 'nb_frame', 'nb_tracked_object',...
            'OMRangle', 'path', 'seq', 'xbody', 'ybody','P');
        disp('Raw data saved')
        
    else
        load(fullfile(path(1:end-10), 'raw_data.mat'));
        disp('Raw data already extracted')
    end
end