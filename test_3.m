% code test
close all

cx = xbody(f,ind(1,1):ind(2,1));
cy = ybody(f,ind(1,1):ind(2,1));

vel_f = nan(size(cx));

clear peakMags peakInds dst dist vel minInds minMags
mx = movmean(cx,10);
my = movmean(cy,10);
time = 0:1/fps:10-1/fps;
endseq = size(cx,2);


% dst = zeros(1,endseq-1);
% for j = 1:endseq-1
%     dst(j) = (mx(j+1)-mx(j))^2+(my(j+1)-my(j))^2; % squared distance between two consecutive centroids in pixel
% end
% dist = cumsum(dst);
% vel = diff(dist);
% other way to do:
dx = diff(mx, 1, 2);
dxcarr = dx.^2;
dy = diff(my, 1, 2);
dycarr = dy.^2;
vardxy = nanvar(dx(:)+dy(:));
sigdisplacementmatrix = ((dxcarr'+dycarr')/vardxy)';
sigdisplacementmatrix = sigdisplacementmatrix - min(sigdisplacementmatrix);
logsigdisplacementmatrix = log(movmean(sigdisplacementmatrix,10));
logsigdisplacementmatrix(~isfinite(logsigdisplacementmatrix)) = NaN;

figure,
plot(log(sigdisplacementmatrix));

% ----- find peak and valley -----
minIPI = 0.2; %minimum inter-peak interval (in secs)
minh = prctile(logsigdisplacementmatrix, 70, 2);
% eventuellement prendre audessus de 0... pour log
[peakMags, peakInds] = findpeaks(logsigdisplacementmatrix,'MinPeakDistance', minIPI*fps, 'MinPeakHeight', minh);

% if isempty(peakMags) == 0
%     i=1;
%     while peakInds(i)<=20
%         i = i+1;
%         peakMags = peakMags(i:end);
%         peakInds = peakInds(i:end);
%     end
%     
%     for i=1:size(peakMags,2)
%         if peakInds(i)<endseq-20 %reject last peak if there are too close from the edges
%             kL = peakInds(i)-10;
%             kR = peakInds(i)+10;
%             mL = peakMags(i);
%             mR = peakMags(i);
%             m1 = vel_f(seq,kL-1);
%             m2 = vel_f(seq,kR+1);
%             while mL>m1 && kL>2 %find the left valley
%                 kL = kL - 1;
%                 mL = m1;
%                 m1 = vel_f(seq,kL-1);
%             end
%             while mR>m2 && kR+2<endseq %find the right valley
%                 kR = kR + 1;
%                 mR = m2;
%                 m2 = vel_f(seq,kR+1);
%             end
%             minInds(i,:) = [kL kR];
%             minMags(i,:) = [vel_f(seq,kL) vel_f(seq,kR)];
%         end
%     end
%     
%     % ----- plot the velocity profil -----
%     
    hold on
    plot(peakInds, peakMags, 'o')
%     plot(minInds(:,1)/framerate(seq,3), minMags(:,1), 'o')
%     plot(minInds(:,2)/framerate(seq,3), minMags(:,2), 'o')
%     title (['Velocity of sequence ',num2str(sequence(seq))])
% end
