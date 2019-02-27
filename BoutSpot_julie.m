% function [boutindexes, minh, nbouts] = BoutSpot_julie(cx, cy, fps, checkplot)
% function [boutindexes, minh, nbouts] = BoutSpot_julie(cx, cy, cang, fps, checkplot)

% Extraction of bout indexes from x y coordinated and angle of the fish
% INPUT
% ---
% coordinates (cx and cy)   : x and y coordinated of the mass center of the fish
% angle_source (cang)       : cumulative angle of the fish relative to the light source (in degrees)
% framerate                 : framerate per sequence
% checkplot                 : 0 or 1 whether you want a plot or not
%
% OUTPUT
% ---
% boutindexes   : indexes of bouts in the sequence

%--------------------------------------------------------------------------

% checkplot = 1;
% fps = 150;

% smooth all variables (x, y, theta)
% mang = movmean(cang,10,'omitnan');
mx = movmean(cx,10,'omitnan');
my = movmean(cy,10,'omitnan');

%without smooth
% mang = cang;
% mx = cx;
% my = cy;

% get the differentials and their squares
dx = diff(mx, 1, 2);
dxcarr = dx.^2;

dy = diff(my, 1, 2);
dycarr = dy.^2;

% dang = diff(cang, 1, 2);
% dangcarr = dang.^2;

% get variances
% vardang = nanvar(dang(:));
vardxy = nanvar(dx(:)+dy(:));

% get the significant displacement
% sigdisplacementmatrix = ((dangcarr'/vardang).*((dxcarr'+dycarr')/vardxy))';
sigdisplacementmatrix = ((dxcarr'+dycarr')/vardxy)';
logsigdisplacementmatrix = log(sigdisplacementmatrix);
logsigdisplacementmatrix(~isfinite(logsigdisplacementmatrix)) = NaN;

%%
minIPI = 0.2; %minimum inter-peak interval (in secs)
% minh = nanmedian(logsigdisplacementmatrix,2)+abs(prctile(logsigdisplacementmatrix, 10, 2)-nanmedian(logsigdisplacementmatrix,2));
minh = prctile(logsigdisplacementmatrix, 70, 2);

pkmaxnb = 0;
lsdm = logsigdisplacementmatrix;
pks = findpeaks(lsdm , 'MinPeakHeight', minh,...
    'MinPeakDistance', minIPI*fps);
if pkmaxnb < length(pks)
    pkmaxnb = length(pks);
end
nbouts = pkmaxnb;
%%
maxbout = NaN(size(sigdisplacementmatrix,1),pkmaxnb);
boutwindow = 0.25;%secs
boutindexes = NaN(size(sigdisplacementmatrix,1),pkmaxnb);

lsdm = logsigdisplacementmatrix;
lsdm(lsdm < minh) = NaN;
nanmx = isnan(lsdm);
flankedbynans = [1 0 1];
todel = strfind(nanmx, flankedbynans);
lsdm(todel+1) = NaN;
lsdm(isnan(lsdm)) = -inf;
[pks, locs] = findpeaks(lsdm, 'MinPeakHeight', minh,...
    'MinPeakDistance', minIPI*fps);
maxbout(1, 1:length(locs)) = locs;
tau = floor(fps*boutwindow);

for j = 1 : length(locs)
    subreg = locs(j) - tau : locs(j) + tau;
    neg = length(find(subreg<=0));
    oversize = length(find(subreg>length(lsdm)+1));
    if isempty(neg)
        neg = 0;
    end
    subreg = subreg(subreg > 0);
    if ~isempty(oversize)
        subreg = subreg(1:end-oversize);
    end
    prereg = locs(j)-tau+neg : locs(j)-1-floor(2*tau/3);
    
    subx = mx(1, subreg); % subregion of the signal around the bout
    px = polyfit(prereg, mx(1, prereg), 1); % linear fit of the pre-bout signal
    subreg_redressx = subx-px(2)-px(1)*subreg; % substract the resulting fitting function
    sd = std(subreg_redressx(1:length(prereg)));
    binsubregx = double( abs(subreg_redressx) > 3*sd);
    
    suby = my(1, subreg);
    py = polyfit(prereg, my(1, prereg), 1); % linear fit of the pre-bout signal
    subreg_redressy = suby-py(2)-py(1)*subreg;
    subreg_redressy(1:3)=0;
    sd = std(subreg_redressy(1:length(prereg)));
    binsubregy = double( abs(subreg_redressy) > 3*sd);
    
    [~, transition] = find(diff([binsubregx; binsubregy],1, 2)==1,1); % first val beyond sig
    if ~isempty(transition)
        locs(j) = locs(j)+neg-tau+transition-1;
    else
        locs(j) = NaN;
    end
end

pks(isnan(locs)) = [];
locs(isnan(locs)) = [];

if checkplot ==1
    h = figure('units','normalized','outerposition',[0 0 1 1]);
%     subplot(1,3,1:2)
    yyaxis left
    plot((1:length(cx))/fps, cx, '-')
    hold on
    plot((1:length(cx))/fps, mx, 'r-')
    hold on
    plot((1:length(cx))/fps, cy, '-')
    plot((1:length(cx))/fps, my, 'r-')
    plot((1:length(cx))/fps, cx, '-', 'Color', [0.5 0.5 0.5], 'Linewidth', 1)
%     plot((1:length(cang))/fps, mang, '-k' , 'Linewidth', 1)
%     plot(locs/fps, (mang(1,locs)), 'sq', 'Color', [0 0 0], 'MarkerSize', 2, 'MarkerFaceColor', [0.4 0.4 0.9])
    plot(locs/fps, cx(1,locs),'o',locs/fps, cy(1,locs), 'o')
    yyaxis right
    plot((1:length(cx(1,1:end-1)))/fps, lsdm)
    
%     subplot(1,3,3);
%     histogram(lsdm,100)
%     waitfor(h)
end
boutindexes(1,1:length(locs)) = locs;

boutindexes(isnan(boutindexes)==1) = [];
nbouts = size(boutindexes,2);

