% code test

close all;
clc;

IBI = nan(1,nb_detected_object);

f = 1;
% for f = 10:nb_detected_object
% for f = 1:10
ind_seq = seq{f}(:,:);

if isempty(ind_seq) == 0
    ind = ind_seq(:,1);
    
    % I only take fish that are present from close beginning
    if ind(1,1) <= fps/2
        %             disp('patate')
        cx = xbody(f,ind(1,1):ind(2,1));
        cy = ybody(f,ind(1,1):ind(2,1));
        angf = angle(f,ind(1,1):ind(2,1));
        
        mx = movmean(cx,10,'omitnan');
        my = movmean(cy,10,'omitnan');
        mangf = movmean(angf,10,'omitnan');
        
        dx = diff(mx, 1, 2);
        dxcarr = dx.^2;
        dy = diff(my, 1, 2);
        dycarr = dy.^2;
        dtheta = diff(mangf, 1, 2);
        dthetacarr = dtheta.^2;
        
        % get variances
        vardxy = nanvar(dx(:)+dy(:));
        vardth = nanvar(dtheta(:));
        
        % get the significant displacement
        sigdisplacementmatrix = ((dxcarr'+dycarr')/vardxy)';
        sigdisplacementmatrix = sigdisplacementmatrix - min(sigdisplacementmatrix);
        sigdisplacementmatrix = sigdisplacementmatrix/max(sigdisplacementmatrix)*100;
        vel = sigdisplacementmatrix;
        vel = movmean(vel,5);
        acc = diff(vel);
        acc = movmean(acc,3);
        lvel = log(vel);
        lvel(~isfinite(lvel)) = NaN;
        lvel(isnan(lvel)) = 0;
        lvel(lvel<-5) = -5;
        
        % ----- find peak and valley  with acceleration and velocity !! -----
        minIPI = round(0.2*fps);
        minh = std(lvel)+median(lvel);
        minPro = 2;
        [peakMags, peakInds] = findpeaks(lvel,'MinPeakDistance', minIPI, 'MinPeakHeight', minh, 'MinPeakProminence',minPro);
        
        [peakMagsvel, peakIndsvel] = findpeaks(vel,'MinPeakDistance', minIPI, 'MinPeakHeight', 5*median(vel));
        %             [peakMagsacc, peakIndsacc] = findpeaks(acc,'MinPeakDistance', minIPI, 'MinPeakHeight', std(acc));
        
        % - PLOT
                    figure;
                    plot(lvel);
                    hold on;
                    plot(peakInds,peakMags,'o');
        %
        %                     figure;
        %                     plot(vel);
        %                     hold on;
        %                     plot(peakIndsvel,peakMagsvel,'o');
        %
        %           figure;
        %         plot(acc);
        %         hold on;
        %         plot(peakIndsacc,peakMagsacc,'o');
        
        figure
        plot(vel);
        hold on
        plot(peakIndsvel,peakMagsvel,'o')
        plot(peakInds, vel(peakInds)+10,'o')
        peakIndsvel1 = peakIndsvel;
        % - END PLOT -
        
        %         return
    end
end
% end

return

% remove peak too close from the edges
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

if isempty(peakInds) == 0
    indbout = nan(2,size(peakInds,2));
    
    i = 1;
    %             for i=1:size(peakInds,2)
    prewindow = 0.15;
    prewindow = round(prewindow*fps);
    prebout = peakInds(i) - prewindow : peakInds(i) - 1;
    if i==1
        prebout(prebout<=0) = [];
    else
        prebout(prebout<indbout(2,i-1)) = [];
    end
    postwindow = 0.3;
    postwindow = round(postwindow*fps);
    postbout = peakInds(i) + 1 : peakInds(i) + postwindow - 1;
    if i == size(peakInds,2)
        postbout(postbout>=size(vel,2)) = [];
    else
        postbout(postbout>=peakInds(i+1)-5) = [];
    end
    
    velbout = vel(prebout(1):postbout(end));
    pfit = fitdist(velbout','normal');
    %                 x = 1:1:siz;
    gaussfit = max(velbout)*exp(-((x-pfit.mu).^2)/(2*pfit.sigma^2));
    
    figure;
    plot(velbout);
    hold on
    %                 plot(x, gaussfit);
    
    
    
    %             end
end


% end
% end
% end