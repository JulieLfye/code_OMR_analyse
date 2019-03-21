% test code
close all
clc


s = nan(size(peakInds));
indbout = nan(2,size(peakInds,2));
im = 0;
prewindow = 0.2;
prewindow = round(prewindow*fps);
postwindow = 0.3;
postwindow = round(postwindow*fps);

% remove peak to close from the edges - lvel
while isempty(peakInds) == 0 && peakInds(1) < round(0.15*fps)
    peakInds(1) = [];
    peakMags(1) = [];
end
if isempty(peakInds) == 0
    n = 0;
    
    while isempty(peakInds) == 0 && peakInds(end) > size(vel,2)-round(0.2*fps)
        n = n+1;
        peakInds(end) = [];
        peakMags(end) = [];
    end
end
% remove peak to close from the edges - vel
while isempty(peakIndsvel) == 0 && peakIndsvel(1) < round(0.15*fps)
    peakIndsvel(1) = [];
    peakMagsvel(1) = [];
end
if isempty(peakIndsvel) == 0
    n = 0;
    
    while isempty(peakIndsvel) == 0 && peakIndsvel(end) > size(vel,2)-round(0.2*fps)
        n = n+1;
        peakIndsvel(end) = [];
        peakMagsvel(end) = [];
    end
end

% figure
% plot(vel);
% hold on
% plot(peakIndsvel,peakMagsvel,'bo')
% plot(peakInds, vel(peakInds)+5,'ko')
% peakIndsvel1 = peakIndsvel;
% close

i = 4;
for i=1:size(peakInds,2)
j = size(peakIndsvel,2);
k = [];
while j > 0
    d = abs(peakInds(i) - peakIndsvel(j));
    if d < 10
        k = j;
        j = 0;
    else
        j = j - 1;
    end
end
peakIndsvel1(k) = 0;

if isempty(k) == 0
    [fg,x,y] = fitgauss_vel_bout(prewindow, postwindow, peakInds, i, indbout, vel, im);
    if fg.sig < 20
        s(1,i) = fg.sig;
        % on va prendre comme "largeur de bout", 6*sig
        indbout(1,i) = round(fg.mu - 3*fg.sig)-1;
        indbout(2,i) = round(fg.mu + 3*fg.sig)+1;
    end
else
    % peak detected on lvel but not on vel
    [fg,x,y] = fitgauss_vel_bout(prewindow, postwindow, peakInds, i, indbout, vel, im);
    if fg.sig < 20 % the distribution looks like a peak
        [mags, inds] = findpeaks(y,'minPeakHeight', 1.5*std(y));
        if size(inds,2) == 1 % there is a peak
            disp(['peak on lvel not on vel ' num2str(i)]);
            figure,
            plot(x,y)
            hold on
            plot(fg,x,y)
            indbout(1,i) = round(fg.mu - 3*fg.sig)-1;
            indbout(2,i) = round(fg.mu + 3*fg.sig)+1;
        end
    end
end
end

indbout(:,isnan(indbout(1,:))) = [];
d = diff(indbout,1)+1;
indbout(:,d<0.15*fps) = [];


figure
plot(vel);
hold on
plot(peakIndsvel,peakMagsvel,'bo')
plot(peakInds, vel(peakInds)+5,'ko')
for i = 1:size(indbout,2)
    x = indbout(1,i):1:indbout(2,i);
    y = vel(indbout(1,i):1:indbout(2,i));
    plot(x,y,'r')
end

% check if peak detected on vel but not on lvel
peakIndsvel1(peakIndsvel1==0) = [];
if isempty(peakIndsvel1) == 0
    for i = 1:size(peakIndsvel1,2)
        ibout = zeros(2,size(peakIndsvel1,2));
        [fg,x,y] = fitgauss_vel_bout(prewindow, postwindow, peakIndsvel1, i, ibout, vel, im);
        fg.sig;
        if fg.sig < 20 % the distribution looks like a peak
            disp(['peak on vel not on lvel ' num2str(i)]);
            figure
            plot(x,y)
            hold on
            plot(fg,x,y)
        end
    end
end