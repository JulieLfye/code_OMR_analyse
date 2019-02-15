% run to_do_first_select_sequence

function [proba_turn_light,ind_b_a_bout,...
    angle_pbout] = angular_velocity(angle_cum,...
    framerate,mov_angle,lum_th,fig)

%% Comments
% Find the angular velocity for the initialization.
% Determine the index before and after a turn
%Inputs -----
% angle_cum: raw angle (rand), without the 0-360 border
% framerate: framerate of the experiement
% mov_angle: moveman of the angle_cum
% lum_th: luminosity profile
% fig: if fig = 1, plot, if fig = 0, don't plot
%Outputs -----
% proba_turn_light: matrix, 1st column: number of turns, 2nd column: number
% of turns toward the light, 3rd column: proba to turn toward the light
% ind_b_a_bout: indice before and after each swim bout
% angle_pbout: each lines represents the angle per turn bout for for one
% sequence

%% Code
vel_ang = nan(size(angle_cum));
for seq = 1:size(angle_cum,1)
    velang = [];
    dstang = [];
    distang = [];
    endseq = framerate(seq,4);
    if endseq > size(angle_cum,2)
        endseq = size(angle_cum,2);
    end
    time = linspace(0,endseq/framerate(seq,3),endseq);
    time(1,endseq+1:size(angle_cum,2)) = nan;
    
    % ----- angular velocity in degre/s -----
    for j = 1:endseq-1
        dstang(j) = mov_angle(seq,j+1)-mov_angle(seq,j);
    end
    distang = cumsum(dstang);
    velang = abs(diff(distang)*framerate(seq,3));
    vel_ang(seq,1:endseq-2) = movmean(velang,10);
    vel_ang(seq,:) = vel_ang(seq,:) - min(vel_ang(seq,:));
    
%     % ----- define minPeakHeight -----
%     [hnoise, vnoise] = hist(vel_ang(seq,:), 100);
%     gf = fit(vnoise',hnoise', 'gauss1');
%     minPeakHeight(seq) = round(gf.c1/sqrt(2)*2);
%     if minPeakHeight(seq) < 15
%         minPeakHeight(seq) = 15;
%     end
    
    % ----- find peak and valley -----
    peakMags = [];
    peakInds = [];
    minInds = [];
    minMags = [];
    [peakMags, peakInds] = findpeaks(vel_ang(seq,:),'MinPeakDistance', 40, 'MinPeakHeight', 15);
    if isempty(peakMags) == 0
        i=1;
        while peakInds(i)<=20
            i = i+1;
            peakMags = peakMags(i:end);
            peakInds = peakInds(i:end);
        end
        
        for i=1:size(peakMags,2)
            if peakInds(i)<endseq-20 %reject last peak if there are too close from the edges
                kL = peakInds(i)-10;
                kR = peakInds(i)+10;
                mL = peakMags(i);
                mR = peakMags(i);
                m1 = vel_ang(seq,kL-1);
                m2 = vel_ang(seq,kR+1);
                while mL>m1 && kL>2 %find the left valley
                    kL = kL - 1;
                    mL = m1;
                    m1 = vel_ang(seq,kL-1);
                end
                while mR>m2 && kR+2<endseq %find the right valley
                    kR = kR + 1;
                    mR = m2;
                    m2 = vel_ang(seq,kR+1);
                end
                minInds(i,:) = [kL kR];
                minMags(i,:) = [vel_ang(seq,kL) vel_ang(seq,kR)];
            elseif peakInds(i) >= endseq-20
                peakInds = peakInds(1:i-1);
                peakMags = peakMags(1:i-1);
            end
        end
        
        % ----- angle per angle bout -----
        light=1;
        dark=1;
        t_light = [];
        t_dark = [];
        good_seq = [];
        k=1;
        for j = 1: size(minInds,1)
            t_ind = 1;
            d = mov_angle(seq,minInds(j,2))-mov_angle(seq,minInds(j,1));
            if abs(d) > 5
                angle_pbout(k,:,seq)= [d peakInds(j)];
                good_seq = [good_seq j];
                
            % ----- turn toward light(+1) or dark(-1)? -----
                a = mod(mov_angle(seq,minInds(j,1)),360);
                s = sign(d);
                if a < 180 && s > 0
                    t_light = [t_light k];
                    angle_stat(seq,k) = +1;
                elseif a < 180 && s < 0
                    t_dark = [t_dark k];
                    angle_stat(seq,k) = -1;
                elseif a >= 180 && s > 0
                    t_dark = [t_dark k];
                    angle_stat(seq,k) = -1;
                elseif a >= 180 && s < 0
                    t_light = [t_light k];
                    angle_stat(seq,k) = +1;
                end
                k=k+1;
            end
        end
        peakInds = peakInds(good_seq);
        peakMags = peakMags(good_seq);
        minInds = minInds(good_seq,:);
        minMags = minMags(good_seq,:);
        
        % ------ PI per beat -----
        if isempty(minInds) == 0
            ind_b_a_bout(seq,1) = round(minInds(1,1));
            ind_b_a_bout(seq,size(minInds,1)+1) = minInds(end,2);
            for p = 2:size(minInds,1)
                ind_b_a_bout(seq,p) = round((minInds(p,1)+minInds(p-1,2))/2);
            end
        end
        
        % ----- probability to turn toward light -----
        proba_turn_light(seq,1) = k-1; % number of turns
        proba_turn_light(seq,2) = size(t_light,2); % number of turns toward light
        proba_turn_light(seq,3) = size(t_light,2)/(k-1)'; % proba to turn toward light
        
        if fig == 1
            % ----- plot the angular velocity profil -----
            figure,
            subplot(2,2,1)
            plot(time,vel_ang(seq,:),'k')
            if isempty(minMags) == 0
                hold on
                plot(peakInds/framerate(seq,3), peakMags, 'o')
                plot(minInds(:,1)/framerate(seq,3), minMags(:,1), 'o')
                plot(minInds(:,2)/framerate(seq,3), minMags(:,2), 'o')
                xlim([0, round(max(time)+1)])
                
                subplot(2,2,2)
                plot_angle_fish(mov_angle,framerate,peakInds,time,seq,lum_th);
                xlim([0, round(max(time)+1)])
                
                % ----- plot the angle per bout -----
                subplot(2,2,3)
                hold on
                if isempty(t_light) == 0
                    light = find(t_light > 0);
                    stem(angle_pbout(t_light(light),2,seq)/framerate(seq,3),angle_pbout(t_light(light),1,seq),'r');
                end
                if isempty(t_dark) == 0
                    dark = find(t_dark > 0);
                    stem(angle_pbout(t_dark(dark),2,seq)/framerate(seq,3),angle_pbout(t_dark(dark),1,seq),'k');
                end
                xlim([0, round(max(time)+1)])
            end
        end
    end
end