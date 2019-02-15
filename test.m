% code test

disp('Select the first frame of the binarized movie');
[file,path] = uigetfile('*.tif',[],'C:\Users\LJP\Documents\MATLAB\these\data_OMR\');
% [file,path] = uigetfile('*.tif',[],'G:\these\pot_vibrant');
t = readtable(fullfile(path,'Tracking_Result\tracking.txt'),'Delimiter','\t');
s = table2array(t);

[nb_tracked_object, nb_frame, nb_detected_object, xbody, ybody]...
    = extract_parameters_from_fast_track(s);