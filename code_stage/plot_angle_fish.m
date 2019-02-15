function []=plot_angle_fish(mov_angle,framerate,peakInds,time,seq,lum_th)

hold on

angmed1 = round(interp1(lum_th(:,2),lum_th(:,1),max(lum_th(:,2))*0.3));
angmed2 = round(interp1(lum_th(:,2),lum_th(:,1),max(lum_th(:,2))*0.7));


mi = min(mov_angle(seq,:));
mx = max(mov_angle(seq,:));

% ------ plot the edge of the darker 30% -----
i=0; % ----- 0 to angmed1, up -----
while i*360 < max(mov_angle(seq,:))
    xdark = [0 max(time) max(time) 0];
    ydark = [i*360, i*360, i*360+angmed1, i*360+angmed1];
    fill(xdark,ydark,[0.8 0.8 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none')
    i = i+1;
end
i=1; % ----- 360-angmed1 to 360, down -----
while i*360-angmed1 < max(mov_angle(seq,:))
    xdark = [0 max(time) max(time) 0];
    ydark = [i*360-angmed1, i*360-angmed1, i*360, i*360];
    fill(xdark,ydark,[0.8 0.8 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none')
    i = i+1;
end
i=-1; %----- -360 to -(360-angmed1), up -----
while i*360 > min(mov_angle(seq,:))
    xdark = [0 max(time) max(time) 0];
    ydark = [i*360, i*360, i*360+angmed1, i*360+angmed1];
    fill(xdark,ydark,[0.8 0.8 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none')
    i = i-1;
end
i=0; %----- -(360+angmed1) to -360, down
while i*360 > min(mov_angle(seq,:))
    xdark = [0 max(time) max(time) 0];
    ydark = [i*360-angmed1, i*360-angmed1, i*360, i*360];
    fill(xdark,ydark,[0.8 0.8 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none')
    i = i-1;
end

% ------ plot the edge of the brighter 30% -----
i=0; % ----- 0 to angmed2, up -----
while i*360 < max(mov_angle(seq,:))
    xdark = [0 max(time) max(time) 0];
    ydark = [i*360, i*360, i*360+angmed2, i*360+angmed2];
    fill(xdark,ydark,[0.8 0.8 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none')
    i = i+1;
end
i=1; % ----- 360-angmed2 to 360, down -----
while i*360-angmed2 < max(mov_angle(seq,:))
    xdark = [0 max(time) max(time) 0];
    ydark = [i*360-angmed2, i*360-angmed2, i*360, i*360,];
    fill(xdark,ydark,[0.8 0.8 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none')
    i = i+1;
end

i=-1; %----- -360 to -(360-angmed2), up -----
while i*360 > min(mov_angle(seq,:))
    xdark = [0 max(time) max(time) 0];
    ydark = [i*360, i*360, i*360+angmed2, i*360+angmed2];
    fill(xdark,ydark,[0.8 0.8 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none')
    i = i-1;
end
i=0; %----- -(360+angmed2) to -360, down
while i*360 > min(mov_angle(seq,:))
    xdark = [0 max(time) max(time) 0];
    ydark = [i*360-angmed2, i*360-angmed2, i*360, i*360];
    fill(xdark,ydark,[0.8 0.8 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none')
    i = i-1;
end



plot(time,mov_angle(seq,:),'k')
scatter(peakInds/framerate(seq,3),mov_angle(seq,peakInds),10,'r','filled')
title ('Angle (gray:lum=0.3-0.7)')