% code test

% determine interbout interval IBI

cx = xbody(1,:);
cy = ybody(1,:);
vel = nan(1,size(cx,2)-2);

mx = movmean(cx,10,'omitnan');
my = movmean(cy,10,'omitnan');
endseq = 1500;
fps = 150;

time = linspace(0,endseq/fps,endseq-1);
time(1,endseq+1:size(cx,2)) = nan;
dst = zeros(1,endseq-1);
dist = dst;
for j = 1:endseq-1
    dst = (mx(j+1)-mx(j))^2+(my(j+1)-my(j))^2; %square distance between two consecutive centroids in pixel
    if isnan(dst) == 0
        dist(j+1) = dist(j) + dst;
    end
end

% il faudrait que j'ajoute la variation de l'angle !
% sigdisplacementmatrix = ((dthetacarr'/vardth).*((dxcarr'+dycarr')/vardxy))';

f = find(dist==0);
dist(f) = nan;
vardxdy = nanvar(diff(mx)+diff(my));
vel = diff(dist/vardxdy);
vel = movmean(vel,10,'omitnan');
vel = vel - min(vel);
figure;
plot(time,vel);

%par comparaison avec le code de sophia, vel = sigdisplacementmatrix
% logvel = log(vel);
% logvel(~isfinite(logvel)) = NaN;
% datasetSize = size(vel,1);



% ----- find peak and valley -----
[peakMags, peakInds] = findpeaks(vel,'MinPeakDistance', 0.2*150, 'MinPeakHeight', 0.2);
seq = 1;
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
            m1 = vel(seq,kL-1);
            m2 = vel(seq,kR+1);
            while mL>m1 && kL>2 %find the left valley
                kL = kL - 1;
                mL = m1;
                m1 = vel(seq,kL-1);
            end
            while mR>m2 && kR+2<endseq %find the right valley
                kR = kR + 1;
                mR = m2;
                m2 = vel(seq,kR+1);
            end
            minInds(i,:) = [kL kR];
            minMags(i,:) = [vel(seq,kL) vel(seq,kR)];
        end
    end
    
    % ----- plot the velocity profil -----
    
    hold on
    plot(peakInds/fps, peakMags, 'o')
    plot(minInds(:,1)/fps, minMags(:,1), 'o')
    plot(minInds(:,2)/fps, minMags(:,2), 'o')
    title ('Velocity of sequence ')
end