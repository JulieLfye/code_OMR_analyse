% % analyse spontaneous activity

F = Focus();

if exist('ang_body','var') == 0
    clear;
    clc;
    close all;
    
    disp('Select the first frame of the binarized movie');
    [file,path] = uigetfile('*.tif',[],'C:\Users\LJP\Documents\MATLAB\these\data_OMR\');
    t = readtable(fullfile(path,'Tracking_Result\tracking.txt'),'Delimiter','\t');
    s = table2array(t);
    
    date = input('Date of the experiment (yy-mm-dd) ?\n','s');
    F.date = date;
    
    if isfile(fullfile(path(1:end-10), 'raw_data.mat')) == 0
        
        [nb_tracked_object, nb_frame, nb_detected_object, xbody, ybody]...
            = extract_parameters_from_fast_track(s);
        
        tic
        [ang_body] = extract_angle_fish_OMR(nb_detected_object, nb_frame, 50, 50,...
            xbody, ybody, file, path, 0);
        toc
        
        [seq, xbody, ybody, ang_body] = extract_sequence(nb_detected_object,...
            xbody, ybody, ang_body);
        
        
        
    else
        load(fullfile(path(1:end-10), 'raw_data.mat'));
        
    end
end


%% determination of IBI
ff = find(isnan(seq(1,:))==1);

OMRangle = 0; % if OMRangle = 0, then angle = ang_OMR
angle = nan(nb_detected_object,nb_frame);

% f = 1;
bout_indexes = [];
nb_bout = [];
IBI = [];
fps = 150;
for f = 1:nb_detected_object
    if f == 1
        ind_seq = seq(:,1:ff(f)-1);
    else
        ind_seq = seq(:,ff(f-1)+1:ff(f)-1);
    end
    
    while isempty(ind_seq) == 0
        cx = xbody(f,ind_seq(1,1):ind_seq(2,1));
        cy = ybody(f,ind_seq(1,1):ind_seq(2,1));
        cang = ang_body(f,ind_seq(1,1):ind_seq(2,1));
        
        % correct angle of the sequence
        [~, corr_angle] = correct_angle_sequence(cang, 0, OMRangle);
        angle(f,ind_seq(1,1):ind_seq(2,1)) = corr_angle;
        
        % determine IBI with x, y (I don't use the angle)
        [boutind, minh, nbouts] = BoutSpot_julie(cx, cy, fps, 0);
        bout_indexes = [bout_indexes, boutind, nan];
        nb_bout = [nb_bout, nbouts, nan];
        IBI = [IBI, diff(boutind)/fps, nan];
        
        ind_seq(:,1) = [];
    end
end


figure,
[counts,centers] = hist(IBI,50);
bar(centers,counts/sum(nb_bout,'omitnan'),1)
mIBI = mean(IBI,'omitnan');
hold on
med = median(IBI,'omitnan');
me = mean(IBI,'omitnan');
plot([med med], ylim, 'k', 'LineWidth', 2)
plot([me me], ylim, 'r', 'LineWidth', 2)

% save raw data
