% test
% code test

close all;
clc;

fish_after = [];
IBI = nan(1,nb_detected_object);
latency_K = nan(1,nb_detected_object);
latency_J = nan(1,nb_detected_object);

% f = 14;

for f = 1:nb_detected_object
    not_a_peak = [];
    
    if f == 1
        ind_seq = seq(:,1:ff(f)-1);
    else
        ind_seq = seq(:,ff(f-1)+1:ff(f)-1);
    end
    
    ind = ind_seq(:,1);
    % I only take fish that are present from the beginning
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
        acc = diff(vel);
        acc = movmean(acc,5);
        
        % ----- find peak and valley  with acceleration !! -----
        minIPI = round(0.2*fps);
        minh = 0.25;
        [peakMags, peakInds] = findpeaks(acc,'MinPeakDistance', minIPI, 'MinPeakHeight', minh);
        
        
        %     figure;
        %     plot(acc);
        %     hold on;
        %     plot(peakInds,peakMags,'o');
        %     plot(xlim,[0.15 0.15],'k')
        %     plot(xlim,[-0.15 -0.15],'k')
        
        if isempty(peakInds)==0
            % remove peak too close from the edges
            if peakInds(1) < round(0.15*fps)
                peakInds(1) = [];
                peakMags(1) = [];
            elseif peakInds(end) > size(vel,2)-round(0.2*fps)
                peakInds(end) = [];
                peakMags(end) = [];
            end
            indbout = nan(2,size(peakInds,2));
            % determine beginning and end bout with acceleration
            for i=1:size(peakInds,2)
                %             i = 10;
                prewindow = 0.15;
                prewindow = round(prewindow*fps);
                prebout = peakInds(i) - prewindow : peakInds(i) - 1;
                if i==1
                    prebout(prebout<0) = [];
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
                %             figure
                %             plot(acc(prebout(1):postbout(end)));
                %             hold on
                %             plot(xlim,[0.15 0.15],'k')
                %             plot(xlim,[-0.15 -0.15],'k')
                %             plot(size(prebout,2)+1,acc(peakInds(i)),'o')
                %             hold on;
                %             plot(xlim, [0.15 0.15],'k');
                %             plot(xlim, [-0.15 -0.15],'k');
                % --- beginning
                t = [find(abs(acc(prebout))<0.15) 50];
                tt =  find(diff(t)>1,1);
                if isempty(tt) == 0
                    indbout(1,i) = prebout(t(tt));
                else
                    indbout(1,i) = indbout(2,i-1);
                end
                % --- end
                t = [-5 find(abs(acc(postbout))<0.15)];
                tt = find(diff(t)>1);
                if isempty(tt) == 0
                    indbout(2,i) = postbout(t(tt(end)+1))+1;
                end
            end
        end
        
        
%         figure
%         plot(acc)
%         hold on
%         plot(peakInds,acc(peakInds),'o')
%         plot(xlim,[0.15 0.15],'k')
%         plot(xlim,[-0.15 -0.15],'k')
%         plot(indbout(1,:),acc(indbout(1,:)),'ro')
%         plot(indbout(2,:),acc(indbout(2,:)),'ko')
%         
        
        % determine IBI
        IBI(f) = mean(diff(indbout(1,:))/150);
        
        % determine OMR latency according Kristen
        % first bout after grading starting ie first bout
        latency_K(f) = indbout(1,1)/fps;
        
        % determine OMR latency according to the bout that "align" the fish
        % with OMR
        % need angle !
        %                     figure,
        %                     plot(angf)
        %                     hold on
        %                     plot(ind_bout(1,:), angf(ind_bout(1,:)), 'ro')
        %                     plot(ind_bout(2,:), angf(ind_bout(2,:)), 'ko')
        % determine angle "step"
        ang_step = nan(1,size(indbout,2)+1);
        ang_step(1) = mean(angf(indbout(1,1)-10:indbout(1,1)));
        for i = 1:size(indbout,2)
            if indbout(2,i)+10 <= ind(2,1)
                ang_step(i+1) = mean(angf(indbout(2,i):indbout(2,i)+10));
            else
                ang_step(i+1) = mean(angf(indbout(2,i):end));
            end
        end
        b = mod(ang_step,2*pi);
        b(b>pi) = b(b>pi)-2*pi;
        t = find(abs(b)<45*pi/180);
        if isempty(t) == 0
            if t(1)>1
                latency_J(f) = indbout(1,t(1)-1)/fps;
            elseif size(t,2) > 1
                latency_J(f) = indbout(1,t(2)-1)/fps;
            end
        end
    else
        fish_after = [fish_after f];
    end
end

mIBI = mean(IBI,'omitnan');
mlatency_K = mean(latency_K,'omitnan');
mlatency_J = mean(latency_J,'omitnan');

% latency_J(f)*150

