% code test

% plot <angle_fish - angle_OMR>bn_fish over time
clear;
clc;
close all;

disp('Select the first frame of the binarized movie');
[file,path] = uigetfile('*.tif',[],'C:\Users\LJP\Documents\MATLAB\these\data_OMR\');
t = readtable(fullfile(path,'Tracking_Result\tracking.txt'),'Delimiter','\t');
s = table2array(t);

[nb_tracked_object, nb_frame, nb_detected_object, xbody, ybody]...
    = extract_parameters_from_fast_track(s);


tic
[ang_body] = extract_angle_fish_OMR(nb_detected_object, nb_frame, 50, 50,...
    xbody, ybody, file, path, 0);
toc

[angle, ang_OMR] = correct_angle(nb_detected_object,...
    nb_frame, ang_body, 0, 0);

% figure;
% plot(movmean(ang_OMR',10,'omitnan'))

% code for  <angle_fish - angle_OMR>nb_fish over time
time = 0:1/150:10-1/150;
for i = 1:nb_frame
    mean_ang_OMR(i) = mean(ang_OMR(:,i),1,'omitnan');
    mean_norm(i) = mean_ang_OMR(i)/(size(find(isnan(ang_OMR(:,i))==0),1));
end
plot(time,movmean(mean_norm,10))
% figure
% plot(time,movmean(mean_ang_OMR,10)*180/pi)

save(fullfile(path(1:end-10),'angle_to_OMR_time.mat'),'mean_ang_OMR','mean_norm');