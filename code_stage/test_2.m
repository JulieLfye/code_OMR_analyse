% test
% cx = xbody(f,ind_seq(1,1):ind_seq(2,1));
% cy = ybody(f,ind_seq(1,1):ind_seq(2,1));
% cang = ang_body(f,ind_seq(1,1):ind_seq(2,1));

close all

vel_f = nan(size(cang));
fps = 150;


clear peakMags peakInds dst dist vel minInds minMags
mx = movmean(cx,10)*0.098;
my = movmean(cy,10)*0.098;
endseq = size(cx,2);
time = 0:1/fps:(endseq-1)/150;
dst = zeros(1,endseq-1);
for j = 1:endseq-1
    dst(j) = sqrt((mx(j+1)-mx(j))^2+(my(j+1)-my(j))^2); %distance between two consecutive centroids in pixel
end
dist = cumsum(dst);
vel = diff(dist);
vel = vel*fps;
vel_f(1,1:endseq-2) = movmean(vel,10);
vel_f(1,:) = vel_f(1,:) - min(vel_f(1,:));

figure,
plot(time,vel_f);

minPeakHigh = 3;

% ----- find peak and valley -----
[peakMags, peakInds] = findpeaks(vel_f,'MinPeakDistance', 20, 'MinPeakHeight', minPeakHigh);
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
            m1 = vel_f(1,kL-1);
            m2 = vel_f(1,kR+1);
            while mL>m1 && kL>2 %find the left valley
                kL = kL - 1;
                mL = m1;
                m1 = vel_f(1,kL-1);
            end
            while mR>m2 && kR+2<endseq %find the right valley
                kR = kR + 1;
                mR = m2;
                m2 = vel_f(1,kR+1);
            end
            minInds(i,:) = [kL kR];
            minMags(i,:) = [vel_f(1,kL) vel_f(1,kR)];
        end
    end
    
    % ----- plot the velocity profil -----
    
    hold on
    plot(peakInds/fps, peakMags, 'o')
    plot(minInds(:,1)/fps, minMags(:,1), 'o')
    plot(minInds(:,2)/fps, minMags(:,2), 'o')
end
