% function [boutindexes, minh, nbouts] = BoutSpot(cx, cy, angle, fps, checkplot, varargin)

% Extraction of bout indexes from x y coordinated and angle of the fish
% INPUT
% ---
% coordinates   : x and y coordinated of the mass center of the fish
% angle_source  : cumulative angle of the fish relative to the light source (in degrees)
% framerate     : framerate per sequence
% checkplot     : 0 or 1 whether you want a plot or not
%
% OUTPUT
% ---
% boutindexes   : indexes of bouts in the sequence

%--------------------------------------------------------------------------
    
cx = xbody(1,:);
cy = ybody(1,:);
checkplot = 1;
fps = 150;

x = cx;
y = cy;

% smooth all variables (x, y, theta)
% [mtheta, mx, my] = smoothCoord(angle, x, y);
mx = movmean(cx,10,'omitnan');
my = movmean(cy,10,'omitnan');
% mx = cx;
% my = cy;

% get the differentials and their squares
dx = diff(mx, 1, 2);
dxcarr = dx.^2;

dy = diff(my, 1, 2);
dycarr = dy.^2;

% dtheta = diff(angle, 1, 2);
% dthetacarr = dtheta.^2;

% get variances
% vardth = nanvar(dtheta(:));
vardxy = nanvar(dx(:)+dy(:));

% get the significant displacement 
% sigdisplacementmatrix = ((dthetacarr'/vardth).*((dxcarr'+dycarr')/vardxy))';
sigdisplacementmatrix = ((dxcarr'+dycarr')/vardxy)';
logsigdisplacementmatrix = log(sigdisplacementmatrix);
logsigdisplacementmatrix(~isfinite(logsigdisplacementmatrix)) = NaN;
datasetSize = size(sigdisplacementmatrix,1);

%%
minIPI = 0.2; %minimum inter-peak interval (in secs)
minh = nanmedian(logsigdisplacementmatrix,2)+abs(prctile(logsigdisplacementmatrix, 10, 2)-nanmedian(logsigdisplacementmatrix,2));
% minh = min(minh, zeros(size(minh,1),1));
pkmaxnb = 0;
for i = 1 : datasetSize
    lsdm = logsigdisplacementmatrix(i,:);
    pks = findpeaks(lsdm , 'MinPeakHeight', minh(i),...
        'MinPeakDistance', minIPI*fps(i));
    if pkmaxnb < length(pks)
        pkmaxnb = length(pks);
    end
end
nbouts = pkmaxnb;
%%
% if contains(varargin, 'ini')
%     boutindexes = [];
%     minh = [];
% else
    maxbout = NaN(size(sigdisplacementmatrix,1),pkmaxnb);
    boutwindow = 0.25;%secs
    boutindexes = NaN(size(sigdisplacementmatrix,1),pkmaxnb);
    
    for i = 1 : datasetSize
        lsdm = logsigdisplacementmatrix(i,:);
        lsdm(lsdm < minh(i)) = NaN;
        nanmx = isnan(lsdm);
        flankedbynans = [1 0 1];
        todel = strfind(nanmx, flankedbynans);
        lsdm(todel+1) = NaN;
        lsdm(isnan(lsdm)) = -inf;
        [pks, locs] = findpeaks(lsdm, 'MinPeakHeight', minh(i),...
            'MinPeakDistance', minIPI*fps(i));
        maxbout(i, 1:length(locs)) = locs;
        tau = floor(fps(i)*boutwindow);
        
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
            
            subx = mx(i, subreg); % subregion of the signal around the bout
            px = polyfit(prereg, mx(i, prereg), 1); % linear fit of the pre-bout signal
            subreg_redressx = subx-px(2)-px(1)*subreg; % substract the resulting fitting function
            sd = std(subreg_redressx(1:length(prereg)));
            binsubregx = double( abs(subreg_redressx) > 3*sd);
            
            suby = my(i, subreg);
            py = polyfit(prereg, my(i, prereg), 1); % linear fit of the pre-bout signal
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
            subplot(1,3,1:2)
            yyaxis left
            plot((1:length(cx(i,:)))/fps(i), x(i,:), '-')
            hold on
            plot((1:length(cx(i,:)))/fps(i), mx(i,:), 'r-')
            hold on
            plot((1:length(cx(i,:)))/fps(i), y(i,:), '-')
            plot((1:length(cx(i,:)))/fps(i), my(i,:), 'r-')
            plot( (1:length(cx(i,:)))/fps(i), (cx(i,:)), '-', 'Color', [0.5 0.5 0.5], 'Linewidth', 1)
%             plot( (1:length(angle(i,:)))/fps(i), (mtheta(i,:)), '-k' , 'Linewidth', 1)
%             plot(locs/fps(i), (mtheta(i,locs)), 'sq', 'Color', [0 0 0], 'MarkerSize', 2, 'MarkerFaceColor', [0.4 0.4 0.9])
            plot(locs/fps(i), x(i,locs),'o',locs/fps(i), y(i,locs), 'o')
            yyaxis right
            plot((1:length(cx(i,1:end-1)))/fps(i), lsdm)
            title(['seq : ' num2str(i) ', ' num2str(minh(i))])
            
            subplot(1,3,3);
            histogram(lsdm,100)
%             waitfor(h)
        end
        boutindexes(i,1:length(locs)) = locs;
    end
% end

