function [IBI, latency_K, latency_J] = extract_OMR_latency(nb_detected_object,...
    seq, xbody, ybody, angle, fps)


close all;
clc;

IBI = nan(1,nb_detected_object);
latency_K = nan(1,nb_detected_object);
latency_J = nan(1,nb_detected_object);

% bout detection parameters
im = 0;
prewindow = 0.2;
prewindow = round(prewindow*fps);
postwindow = 0.25;
postwindow = round(postwindow*fps);
sig_lim = round(0.6*150/6);
correl_lim = 0.85;

f = 7;
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
        lvel = log(vel);
        lvel(~isfinite(lvel)) = NaN;
        lvel(isnan(lvel)) = 0;
        lvel(lvel<-5) = -5;
        
        % ----- find peak and valley -----
        minIPI = round(0.2*fps);
        minh = std(lvel)+median(lvel);
        minPro = 2;
        [peakMags, peakInds] = findpeaks(lvel,'MinPeakDistance', minIPI, 'MinPeakHeight', minh, 'MinPeakProminence',minPro);
        
        [peakMagsvel, peakIndsvel] = findpeaks(vel,'MinPeakDistance', minIPI, 'MinPeakHeight', 1);
        
%         plot(vel)
%         hold on
%         plot(peakIndsvel,peakMagsvel,'bo')
%         plot(peakInds, vel(peakInds)+5,'ko')
        
        %% part to define bout
        indbout = nan(2,size(peakInds,2));
        if isempty(peakInds) == 0
            
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
            
            peakIndsvel1 = peakIndsvel;
            i = 5;
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
                    [fg,x,y, correl] = fitgauss_vel_bout(prewindow, postwindow, peakInds, peakIndsvel, i, indbout, vel, im);
                    if correl > correl_lim && fg.sig < sig_lim
                        % on va prendre comme "largeur de bout", 6*sig
                        indbout(1,i) = round(fg.mu - 3*fg.sig)-1;
                        indbout(2,i) = round(fg.mu + 3*fg.sig)+1;
                        if indbout(1,i) <= 0
                            indbout(1,i) = 1;
                        end
                        if i < size(peakInds,2)
                            if indbout(2,i) > peakInds(i+1)-10
                                indbout(2,i) = peakInds(i+1)-11;
                            end
                        else
                            if indbout(2,i) > x(end)
                                indbout(2,i) = x(end);
                            end
                        end
                    end
                    
                else
                    % peak detected on lvel but not on vel
                    [fg,x,y, correl] = fitgauss_vel_bout(prewindow, postwindow, peakInds, peakIndsvel, i, indbout, vel, im);
                    if correl > correl_lim && fg.sig < sig_lim
                        [mags, inds] = findpeaks(y,'minPeakHeight', 1.5*std(y));
                        indbout(1,i) = round(fg.mu - 3*fg.sig)-1;
                        indbout(2,i) = round(fg.mu + 3*fg.sig)+1;
                        if indbout(1,i) <= 0
                            indbout(1,i) = 1;
                        end
                        if i < size(peakInds,2)
                            if indbout(2,i) > peakInds(i+1)-10
                                indbout(2,i) = peakInds(i+1)-11;
                            end
                        else
                            if indbout(2,i) > x(end)
                                indbout(2,i) = x(end);
                            end
                        end
                    end
                end
            end
            
            
            indbout(:,isnan(indbout(1,:))) = [];
            d = diff(indbout,1)+1;
            indbout(:,d<0.1*fps) = [];
            %  -- check if peak detected on vel but not on lvel
            peakIndsvel1(peakIndsvel1==0) = [];
            if isempty(peakIndsvel1) == 0
                i = 1;
                for i = 1:size(peakIndsvel1,2)
                    indtoadd = [];
                    if peakIndsvel1(i) > round(0.15*fps) && peakIndsvel1(i) < size(vel,2)-round(0.2*fps)
                        ibout = zeros(2,size(peakIndsvel1,2));
                        [fg,x,y, correl] = fitgauss_vel_bout(prewindow, postwindow, peakIndsvel1, peakIndsvel, i, ibout, vel, im);
                        if correl > correl_lim && fg.sig < sig_lim
                            indtoadd = [round(fg.mu - 3*fg.sig)-1; round(fg.mu + 3*fg.sig)+1];
                        end
                        if isempty(indtoadd) == 0
                            if indtoadd(1) <= 0
                                indtoadd(1,i) = 1;
                            end
                            if indtoadd(2) < indbout(1,1) % first bout
                                if indtoadd(2) > indbout(1,1)
                                    indtoadd(2) = indbout(1,1)-5;
                                end
                                indbout = [indtoadd, indbout];
                            elseif indtoadd(1) > indbout(2,end) % last bout
                                if indtoadd(2) > size(vel,2)
                                    indtoadd(2) = size(vel,2);
                                end
                                indbout = [indbout, indtoadd];
                            else % between 2 bouts
                                jsup = find(indbout(2,:)>fg.mu,1);
                                jinf = find(indbout(1,:)<fg.mu);
                                if isempty(jinf) == 0
                                    jinf = jinf(end);
                                elseif indtoadd(2) >= indbout(1,jsup)
                                    indtoadd(2) = indbout(1,jsup)-1;
                                    jinf = jsup-1;
                                end
                                if jsup-jinf == 1
                                    % peak with position jsup
                                    indbout = [indbout(:,1:jinf), indtoadd, indbout(:,jsup:end)];
                                end
                            end
                        end
                    end
                end
            end
        end
        
        if isempty(indbout) == 0
            %                 figure
            %                 plot(vel);
            %                 hold on
            %                 plot(peakIndsvel,peakMagsvel,'bo')
            %                 plot(peakInds, vel(peakInds)+5,'ko')
            %                 for i = 1:size(indbout,2)
            %                     x = indbout(1,i):1:indbout(2,i);
            %                     y = vel(indbout(1,i):1:indbout(2,i));
            %                     plot(x,y,'r')
            %                 end
            
            % determine IBI
            if size(indbout,2) > 1
                IBI(f) = mean(diff(indbout(1,:))/150);
            else
                IBI(f) = nan;
            end
            
            % determine OMR latency according Kristen
            % first bout after grading starting ie first bout
            latency_K(f) = (indbout(1,1))/fps;
            
            % determine OMR latency according to the bout that "align" the fish
            % with OMR
            % determine angle "step"
            
            ang_step = nan(1,size(indbout,2)+1);
            if indbout(1,1)-10 > 0
                ang_step(1) = mean(angf(indbout(1,1)-10:indbout(1,1)));
            else
                ang_step(1) = mean(angf(1:indbout(1,1)));
            end
            for i = 1:size(indbout,2)
                if indbout(2,i)+10 <= ind(2,1)-ind(1,1)+1
                    ang_step(i+1) = mean(angf(1,indbout(2,i):indbout(2,i)+10));
                else
                    a = size(angf,2);
                    ang_step(i+1) = mean(angf(1,indbout(2,i):a));
                end
            end
            b = mod(ang_step,2*pi);
            b(b>pi) = b(b>pi)-2*pi;
            t = find(abs(b)<45*pi/180);
            if isempty(t) == 0
                if t(1)>1
                    latency_J(f) = (indbout(1,t(1)-1))/fps;
                elseif size(t,2) > 1
                    latency_J(f) = (indbout(1,t(2)-1))/fps;
                end
            end
        end
    end
end
end