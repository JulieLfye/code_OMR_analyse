% code test

% plot <angle_fish - angle_OMR>bn_fish over time

tic
[ang_body] = extract_angle_fish_OMR(nb_detected_object, nb_frame, 50, 50,...
    xbody, ybody, file, path, 0);
toc

[angle, ang_OMR] = correct_angle(nb_detected_object,...
    nb_frame, ang_body, 0, 0);

figure;
plot(movmean(ang_OMR',10,'omitnan'))

% code for  <angle_fish - angle_OMR>bn_fish over time
% for i = 1:nb_frame
%     mean_ang_OMR_per_fish = mean(ang_OMR