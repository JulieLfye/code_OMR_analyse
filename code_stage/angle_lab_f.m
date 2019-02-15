function [angle_lab,mangle_lab] = angle_lab_f(angle_labo,framerate,fig)
%% Comments
% Remove the 0-360° edges and smooth the angle
%Inputs -----
% angleini: raw angle from the initialization
% framerate: framerate of the initialization
% fig: if fig=0, don't plot, if fig=1, plot
%Outputs -----
% angle: raw angle with no 0-360 edge
% angle_mov: movmean of angle
% ang_rand: randomize angle with no 0-360 edge (translation of the raw
% data, not the same angle(0))
% mov_ang_rand: movmean of ang_rand


%% Code
angle_lab = nan(size(angle_labo));

for seq = 1:size(angle_labo,1)
    endseq = framerate(seq,4);
    if endseq > size(angle_labo,2)
        endseq = size(angle_labo,2);
    end
    angle_lab(seq,1) = angle_labo(seq,1);
    for j = 2:endseq-1
        d = angle_labo(seq,j)-angle_labo(seq,j-1);
        d = angle_per_frame(d);
        if abs(d) < 150
            angle_lab(seq,j) = angle_lab(seq,j-1) + d;
        else
            angle_lab(seq,j) = angle_lab(seq,j-1);
        end
    end
    mangle_lab(seq,:) = movmean(angle_lab(seq,:),10,'omitnan');
    if fig==1
        figure
        hold on
        plot(angle_lab(seq,:),'k')
        plot(mangle_lab(seq,:),'b')
    end
end