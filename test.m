% code test

close all;
clc;

% peak detection parameters
im = 0;
prewindow = 0.2;
prewindow = round(prewindow*fps);
postwindow = 0.25;
postwindow = round(postwindow*fps);
sig_lim = round(0.6*150/6);
correl_lim = 0.85;


IBI = nan(1,nb_detected_object);

f = 10;
for f = 1:nb_detected_object
ff = find(isnan(seq(1,:))==1);
if f == 1
    ind_seq = seq(:,1:ff(f)-1);
else
    ind_seq = seq(:,ff(f-1)+1:ff(f)-1);
end

if isempty(ind_seq) == 0
    ind = ind_seq(:,1);
    
    % I only take fish that are present from close beginning
    if ind(1,1) <= fps/2
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
        %             figure;
        %             plot(lvel);
        %             hold on;
        %             plot(peakInds,peakMags,'o');
        %
        %                     figure;
        %                     plot(vel);
        %                     hold on;
        %                     plot(peakIndsvel,peakMagsvel,'o');
        
        %             figure
        %             plot(vel);
        %             hold on
        %             plot(peakIndsvel,peakMagsvel,'o')
        %             plot(peakInds, vel(peakInds)+10,'o')
        %             peakIndsvel1 = peakIndsvel;
        % - END PLOT -
        
        %% part to define bout
        indbout = nan(2,size(peakInds,2));
        
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
        % close
        
        
        peakIndsvel1 = peakIndsvel;
        i = 6;
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
                % peak detected on both lvel and vel
                [fg,x,y, correl] = fitgauss_vel_bout(prewindow, postwindow, peakInds, i, indbout, vel, im);
                if correl > correl_lim && fg.sig < sig_lim
                    % on va prendre comme "largeur de bout", 6*sig
                    indbout(1,i) = round(fg.mu - 3*fg.sig)-1;
                    indbout(2,i) = round(fg.mu + 3*fg.sig)+1;
                end
                
            else
                % peak detected on lvel but not on vel
                [fg,x,y,correl] = fitgauss_vel_bout(prewindow, postwindow, peakInds, i, indbout, vel, im);
                if correl > correl_lim && fg.sig < sig_lim
                    [mags, inds] = findpeaks(y,'minPeakHeight', 1.5*std(y));
                    indbout(1,i) = round(fg.mu - 3*fg.sig)-1;
                    indbout(2,i) = round(fg.mu + 3*fg.sig)+1;
                end
            end
        end
        
        indbout(:,isnan(indbout(1,:))) = [];
        d = diff(indbout,1)+1;
        indbout(:,d<0.1*fps) = [];
        % check if peak detected on vel but not on lvel
        peakIndsvel1(peakIndsvel1==0) = [];
        if isempty(peakIndsvel1) == 0
            i = 1;
            for i = 1:size(peakIndsvel1,2)
                ibout = zeros(2,size(peakIndsvel1,2));
                [fg,x,y, correl] = fitgauss_vel_bout(prewindow, postwindow, peakIndsvel1, i, ibout, vel, im);
                if correl > correl_lim && fg.sig < sig_lim
%                     disp(['peak on vel not on lvel ' num2str(i) ' fish ' num2str(f)]);
                    indtoadd = [round(fg.mu - 3*fg.sig)-1; round(fg.mu + 3*fg.sig)+1];
                    if indtoadd(2) < indbout(1,1)
                        indbout = [indtoadd, indbout];
                    elseif indtoadd(1) > indbout(2,end)
                        indbout = [indbout, indtoadd];
                    else
                        jsup = find(indbout(2,:)>fg.mu,1);
                        jinf = find(indbout(1,:)<fg.mu);
                        jinf = jinf(end);
                        if jsup-jinf == 1
                            % peak with position jsup
                            indbout = [indbout(:,1:jinf), indtoadd, indbout(:,jsup:end)];
                        end
                    end
                end
            end
        end
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
    end
end
end