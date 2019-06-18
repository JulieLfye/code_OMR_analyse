function [indbout, xbody, ybody] = extract_bout(xbody,...
    ybody, nb_detected_object, seq, fps, f_remove, checkIm)

cxf = xbody;
cyf = ybody;

prewindow = 0.2;
prewindow = round(prewindow*fps);
postwindow = 0.2;
postwindow = round(postwindow*fps);
im = 0;
sig_lim = round(0.6*150/6);
correl_lim = 0.85;
indbout = cell(1,nb_detected_object);

%% bout detection for OMR_acoustic
f = 17;
for f = 1:nb_detected_object
    b = find(f_remove==f);
    if isempty(b) == 1
        indb = seq{f}(1);
        inde = seq{f}(2);
        
        cx = cxf(f,indb:inde);
        cy = cyf(f,indb:inde);
        
        mx = movmean(cx,10,'omitnan');
        my = movmean(cy,10,'omitnan');
        
        dx = diff(mx, 1, 2);
        dxcarr = dx.^2;
        dy = diff(my, 1, 2);
        dycarr = dy.^2;
        
        % get variances
        vardxy = nanvar(dx(:)+dy(:));
        
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
        minIPI = round(0.1*fps)-1;
        minh = std(lvel)+median(lvel);
        minPro = 2;
        [~, peakInds] = findpeaks(lvel,'MinPeakDistance', minIPI, 'MinPeakHeight', minh, 'MinPeakProminence',minPro);
        
        [peakMagsvel, peakIndsvel] = findpeaks(vel,'MinPeakDistance', minIPI, 'MinPeakHeight', 1);
        
%             plot(vel)
%             hold on
%             plot(peakIndsvel,peakMagsvel,'bo')
%             plot(peakInds, vel(peakInds)+5,'ko')
        
        %% part to define bout
        indbt = nan(2,size(peakInds,2));
        if isempty(peakInds) == 0
            
            peakIndsvel1 = peakIndsvel;
            i = 1;
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
                    [fg,x,y, correl] = fitgauss_vel_bout(prewindow, postwindow, peakInds, peakIndsvel, i, indbt, vel, im);
                    if peakInds(i) < size(vel,2)-70 % non escape bout
                        if correl > correl_lim && fg.sig < sig_lim
                            indbt(1,i) = round(fg.mu - 3*fg.sig)-1;
                            indbt(2,i) = round(fg.mu + 3*fg.sig)+1;
                            if i < size(peakInds,2)
                                if indbt(2,i) > peakInds(i+1)-10
                                    indbt(2,i) = peakInds(i+1)-11;
                                end
                            end
                        end
                        
                        acc = abs(diff(vel(x(x<peakInds(i)))));
                        xacc = x(x<peakInds(i));
                        xacc(1) = [];
                        if x(1) < indbt(1,i)
                            accp = abs(diff(vel(x(1):indbt(1,i)+1)));
                        else
                            accp = abs(diff(vel(x(1):x(5))));
                        end
                        if indbt(1,i)-1-x(1) > 0
                            a = find(acc(indbt(1,i)-1-x(1):end)>3*std(accp),1)+indbt(1,i)-2;
                        else
                            a = find(acc(1:end)>3*std(accp),1)+indbt(1,i)-2;
                        end
                        if isempty(a) == 0
                            indbt(1,i) = a;
                        end
                        
                    elseif peakInds(i) >= size(vel,2)-70 % escape bout
                        if correl > 0.8 && fg.sig < sig_lim
                            % define beginning and end bout
                            indbt(1,i) = round(fg.mu - 3*fg.sig)-1;
                            indbt(2,i) = round(fg.mu + 3*fg.sig)+1;
                            if indbt(1,i) <= 0
                                indbt(1,i) = 1;
                            end
                            if i < size(peakInds,2)
                                if indbt(2,i) > peakInds(i+1)-10
                                    indbt(2,i) = peakInds(i+1)-11;
                                end
                            end
                            
                            acc = abs(diff(vel(x(x<peakInds(i)))));
                            xacc = x(x<peakInds(i));
                            xacc(1) = [];
                            if x(1) < indbt(1,i)
                                accp = abs(diff(vel(x(1):indbt(1,i)+1)));
                            else
                                accp = abs(diff(vel(x(1):x(5))));
                            end
                            if indbt(1,i)-1-x(1) > 0
                                a = find(acc(indbt(1,i)-1-x(1):end)>3*std(accp),1)+indbt(1,i)-2;
                            else
                                a = find(acc(1:end)>3*std(accp),1)+indbt(1,i)-2;
                            end
                            if isempty(a) == 0
                                indbt(1,i) = a;
                            end
                            
                        end
                    end
                    
                else
                    % peak detected on lvel but not on vel
                    [fg,x,y, correl] = fitgauss_vel_bout(prewindow, postwindow, peakInds, peakIndsvel, i, indbt, vel, im);
                    if correl > correl_lim && fg.sig < sig_lim
                        [mags, inds] = findpeaks(y,'minPeakHeight', 1.5*std(y));
                        indbt(1,i) = round(fg.mu - 3*fg.sig)-1;
                        indbt(2,i) = round(fg.mu + 3*fg.sig)+1;
                        if indbt(1,i) <= 0
                            indbt(1,i) = 1;
                        end
                        if i < size(peakInds,2)
                            if indbt(2,i) > peakInds(i+1)-10
                                indbt(2,i) = peakInds(i+1)-11;
                            end
                        end
                        
                        acc = abs(diff(vel(x(x<peakInds(i)))));
                        xacc = x(x<peakInds(i));
                        xacc(1) = [];
                        if x(1) < indbt(1,i)
                            accp = abs(diff(vel(x(1):indbt(1,i)+1)));
                        else
                            accp = abs(diff(vel(x(1):x(5))));
                        end
                        if indbt(1,i)-1-x(1) > 0
                            a = find(acc(indbt(1,i)-1-x(1):end)>3*std(accp),1)+indbt(1,i)-2;
                        else
                            a = find(acc(1:end)>3*std(accp),1)+indbt(1,i)-2;
                        end
                        if isempty(a) == 0
                            indbt(1,i) = a;
                        end
                    end
                end
            end
            
            indbt(:,isnan(indbt(1,:))) = [];
            d = diff(indbt,1)+1;
            indbt(:,d<0.1*fps) = [];
            
            %  -- check if peak detected on vel but not on lvel
            peakIndsvel1(peakIndsvel1==0) = [];
            if isempty(peakIndsvel1) == 0
                i = 1;
                for i = 1:size(peakIndsvel1,2)
                    indtoadd = [];
                    ibout = zeros(2,size(peakIndsvel1,2));
                    [fg,x,y, correl] = fitgauss_vel_bout(prewindow, postwindow, peakIndsvel1, peakIndsvel, i, ibout, vel, im);
                    if correl > correl_lim && fg.sig < sig_lim
                        indtoadd = [round(fg.mu - 3*fg.sig)-1; round(fg.mu + 3*fg.sig)+1];
                        acc = abs(diff(vel(x(x<peakIndsvel1(i)))));
                        xacc = x(x<peakIndsvel1(i));
                        xacc(1) = [];
                        if x(1) < indtoadd(1)
                            accp = abs(diff(vel(x(1):indtoadd(1)+1)));
                        else
                            accp = abs(diff(vel(x(1):x(5))));
                        end
                        if indtoadd(1)-1-x(1) > 0
                            a = find(acc(indtoadd(1)-1-x(1):end)>3*std(accp),1)+indtoadd(1)-2;
                        else
                            a = find(acc(1:end)>3*std(accp),1)+indtoadd(1)-2;
                        end
                        if isempty(a) == 0
                            indtoadd(1) = a;
                        end
                    end
                    if isempty(indtoadd) == 0
                        if indtoadd(1) <= 0
                            indtoadd(1) = 1;
                        end
                        if isempty(indbt) == 0
                            if indtoadd(1) < indbt(1,1) % first bout
                                if indtoadd(2) > indbt(1,1)
                                    indtoadd(2) = indbt(1,1)-5;
                                end
                                indbt = [indtoadd, indbt];
                            elseif indtoadd(2) > indbt(2,end) % last bout
                                if indtoadd(2) > size(vel,2)
                                    indtoadd(2) = size(vel,2);
                                end
                                if indtoadd(1) <= indbt(2,end)
                                    indtoadd(1) = indbt(2,end) + 1;
                                end
                                indbt = [indbt, indtoadd];
                            else % between 2 bouts
                                jsup = find(indbt(2,:)>fg.mu,1);
                                jinf = find(indbt(1,:)<fg.mu);
                                if isempty(jinf) == 0
                                    jinf = jinf(end);
                                elseif indtoadd(2) >= indbt(1,jsup)
                                    indtoadd(2) = indbt(1,jsup)-1;
                                    jinf = jsup-1;
                                end
                                if jsup-jinf == 1
                                    % peak with position jsup
                                    indbt = [indbt(:,1:jinf), indtoadd, indbt(:,jsup:end)];
                                end
                            end
                        end
                    end
                end
            end
        end
        
        if isempty(indbt) == 0
            indbt(2,indbt(2,:) > size(vel,2)) = size(vel,2);
            if indbt(1,1) == 1
                indbt(:,1) = [];
            end
            a = find(indbt(1,:)<1);
            if isempty(a) == 0
                indbt(:,a) = [];
            end
            a = find(indbt(2,:)<1);
            if isempty(a) == 0
                indbt(:,a) = [];
            end
        end
        
        if checkIm == 1
            figure
            plot(vel);
            hold on
            plot(peakIndsvel,peakMagsvel,'bo')
            plot(peakInds, vel(peakInds)+5,'ko')
            for i = 1:size(indbt,2)
                x = indbt(1,i):1:indbt(2,i);
                y = vel(indbt(1,i):1:indbt(2,i));
                plot(x,y,'r')
            end
        end
        indbout{f} = indbt;
    end
end