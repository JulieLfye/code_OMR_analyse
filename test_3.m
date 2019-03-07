% code test
close all;
clc;

fish_after = [];
IBI = nan(1,nb_detected_object);
latency_K = nan(1,nb_detected_object);
latency_J = nan(1,nb_detected_object);

for f = 1:nb_detected_object
    if f == 1
        ind_seq = seq(:,1:ff(f)-1);
    else
        ind_seq = seq(:,ff(f-1)+1:ff(f)-1);
    end
    
    ind = ind_seq(:,1);
    % I only take fish that are present from the beginning
    if ind(1,1) == 1
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
        
        %     figure
        %     plot(sigdisplacementmatrix)
        vel = sigdisplacementmatrix;
        
        % 2
        %     sigdisplacementmatrix2 = ((dthetacarr'/vardth)+((dxcarr'+dycarr')/vardxy))';
        %     sigdisplacementmatri2 = sigdisplacementmatrix2 - min(sigdisplacementmatrix2);
        %     sigdisplacementmatrix2 = sigdisplacementmatrix2/max(sigdisplacementmatrix2)*100;
        %
        %     figure
        %     plot(sigdisplacementmatrix2)
        %     vel = sigdisplacementmatrix2;
        
        % ----- find peak and valley -----
        minIPI = round(0.2*fps)-1;
        % minh = prctile(vel,70);
        minh = 1;
        [peakMags, peakInds] = findpeaks(vel(1,:),'MinPeakDistance', minIPI, 'MinPeakHeight', minh);
        %     hold on
        %     plot(peakInds, peakMags,'o')
        
        [counts, centers] = hist(vel,100);
        % figure, hist(vel, 100);
        % end
        
        % je vais pour le moment, juste définir un seuil
        ind_bout = nan(2,size(peakInds,2));
        thresh_b = 0.01;
        thresh_e = 0.1;
        
        endseq = size(vel,2);
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
                    mL = vel(1,kL);
                    mR = vel(1,kR);
                    while kL>2  && mL>thresh_b %find the bout beginning (left valley)
                        kL = kL - 1;
                        mL = vel(1,kL);
                    end
                    
                    while kR+2<endseq && mR>thresh_e %find the bout end (right valley)
                        kR = kR + 1;
                        mR = vel(1,kR);
                    end
                    t = (kR-kL)/150;
                    if t > 0.1 % remove too short bout
                        ind_bout(1,i) = kL-1;
                        ind_bout(2,i) = kR+1;
                    end
                end
            end
            t = find(isnan(ind_bout(1,:))==1);
            ind_bout(:,t) = [];
            % ----- plot the velocity profil -----
            
            %         hold on
            %         plot(peakInds, peakMags, 'o')
            %         plot(ind_bout(1,:), vel(ind_bout(1,:)), 'ro')
            %         plot(ind_bout(2,:), vel(ind_bout(2,:)), 'ko')
            
            % determine IBI
            IBI(f) = mean(diff(ind_bout(1,:))/150);
            
            % determine OMR latency according Kristen
            % first bout after grading starting ie first bout
            latency_K(f) = ind_bout(1,1)/fps;
            
            % determine OMR latency according to the bout that "align" the fish
            % with OMR
            % need angle !
            %         figure,
            %         plot(angf)
            %         hold on
            %         plot(ind_bout(1,:), angf(ind_bout(1,:)), 'ro')
            %         plot(ind_bout(2,:), angf(ind_bout(2,:)), 'ko')
            % determine angle "step"
            ang_step = nan(1,size(ind_bout,2)+1);
            ang_step(1) = mean(angf(ind_bout(1,1)-10:ind_bout(1,1)));
            for i = 1:size(ind_bout,2)
                if ind_bout(2,i)+10 <= ind(2,1)
                    ang_step(i+1) = mean(angf(ind_bout(2,i):ind_bout(2,i)+10));
                else
                    ang_step(i+1) = mean(angf(ind_bout(2,i):end));
                end
            end
            t = find(abs(ang_step) < 50*pi/180,1);
            if t>1
                latency_J(f) = ind_bout(1,t-1)/fps;
            else
                latency_J(f) = nan;
            end
        end
    else
        fish_after = [fish_after f];
    end
end

mIBI = mean(IBI,'omitnan')
mlatency_K = mean(latency_K,'omitnan')
mlatency_J = mean(latency_J,'omitnan')

