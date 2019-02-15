function [vel_f]=velocity_mm_sec(angle_cum,coordinates,framerate,sequence,minPeakHigh)

cx = zeros(size(coordinates,1),1);
cy = cx;
vel_f = nan(size(angle_cum));

for seq = 1:size(angle_cum,1)
    clear peakMags peakInds dst dist vel minInds minMags
    cx = movmean(coordinates(:,2,seq),10)*0.093;
    cy = movmean(coordinates(:,1,seq),10)*0.093;
    endseq = framerate(seq,4);
    if endseq > size(angle_cum,2)
        endseq = size(angle_cum,2);
    end
    time = linspace(0,endseq/framerate(seq,3),endseq);
    time(1,endseq+1:size(angle_cum,2)) = nan;
    dst = zeros(1,endseq-1);
    for j = 1:endseq-1
        dst(j) = sqrt((cx(j+1)-cx(j))^2+(cy(j+1)-cy(j))^2); %distance between two consecutive centroids in pixel
    end
    dist = cumsum(dst);
    vel = diff(dist);
    vel = vel*framerate(seq,3);
    vel_f(seq,1:endseq-2) = movmean(vel,10);
    vel_f(seq,:) = vel_f(seq,:) - min(vel_f(seq,:));
    
    figure,
    subplot(2,2,1)
    plot(time,vel_f(seq,:));
    
    % ----- find peak and valley -----
    [peakMags, peakInds] = findpeaks(vel_f(seq,:),'MinPeakDistance', 20, 'MinPeakHeight', minPeakHigh);
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
                m1 = vel_f(seq,kL-1);
                m2 = vel_f(seq,kR+1);
                while mL>m1 && kL>2 %find the left valley
                    kL = kL - 1;
                    mL = m1;
                    m1 = vel_f(seq,kL-1);
                end
                while mR>m2 && kR+2<endseq %find the right valley
                    kR = kR + 1;
                    mR = m2;
                    m2 = vel_f(seq,kR+1);
                end
                minInds(i,:) = [kL kR];
                minMags(i,:) = [vel_f(seq,kL) vel_f(seq,kR)];
            end
        end
       
        % ----- plot the velocity profil -----
        
        hold on
        plot(peakInds/framerate(seq,3), peakMags, 'o')
        plot(minInds(:,1)/framerate(seq,3), minMags(:,1), 'o')
        plot(minInds(:,2)/framerate(seq,3), minMags(:,2), 'o')
        title (['Velocity of sequence ',num2str(sequence(seq))])
    end
end