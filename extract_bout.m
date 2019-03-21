% function [] = extract_bout

% pour garder les datas, je vais utiliser une cell

close all;
clc;

IBI = nan(1,nb_detected_object);

f = 3;
% for f = 1:nb_detected_object
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
        acc = diff(vel);
        acc = movmean(acc,3);
        
        % ----- find peak and valley  with acceleration and velocity !! -----
        minIPI = round(0.2*fps);
        minhacc = 0.25;
        [peakMags, peakInds] = findpeaks(acc,'MinPeakDistance', minIPI, 'MinPeakHeight', minhacc);
        
        minhvel = 2;
        [peakMagsvel, peakIndsvel] = findpeaks(vel,'MinPeakDistance', minIPI, 'MinPeakHeight', minhvel);
%         [peakMagsvel, peakIndsvel] = findpeaks(vel,'MinPeakDistance', minIPI, 'MinPeakHeight', minhvel,'MinPeakProminence',2);
        
%         nanmedian(logsigdisplacementmatrix,2)+abs(prctile(logsigdisplacementmatrix, 10, 2)-nanmedian(logsigdisplacementmatrix,2));
        
        
        % - PLOT
%                 figure;
%                 plot(acc);
%                 hold on;
%                 plot(peakInds,peakMags,'o');
%                 plot(xlim,[0.15 0.15],'k')
%                 plot(xlim,[-0.15 -0.15],'k')
                
                figure;
                plot(vel);
                hold on;
                plot(peakIndsvel,peakMagsvel,'o');
                return
        % - END PLOT -
        
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
        %         plot(peakInds,peakMags,'o');
        if isempty(peakInds) == 0
            indbout = nan(2,size(peakInds,2));
            % determine beginning and end bout with acceleration
            for i=1:size(peakInds,2)
                %             i = 8;
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
                %                 % - PLOT -
                %                 figure
                %                 plot(acc(prebout(1):postbout(end)));
                %                 hold on
                %                 plot(xlim,[0.15 0.15],'k')
                %                 plot(xlim,[-0.15 -0.15],'k')
                %                 plot(size(prebout,2)+1,acc(peakInds(i)),'o')
                %                 hold on;
                %                 plot(xlim, [0.15 0.15],'k');
                %                 plot(xlim, [-0.15 -0.15],'k');
                %                 % - END PLOT -
                
                % --- beginning
                t = [find(abs(acc(prebout))<0.15) 50];
                tt =  find(diff(t)>1,1);
                if isempty(tt) == 0
                    indbout(1,i) = prebout(t(tt));
                else
                    if i == 1
                        indbout(1,i) = prebout(1);
                    else
                        indbout(1,i) = indbout(2,i-1);
                    end
                end
                % --- end
                t = [-5 find(abs(acc(postbout))<0.15)];
                tt = find(diff(t)>1);
                if isempty(tt) == 0
                    indbout(2,i) = postbout(t(tt(end)+1))+1;
                else
                    indbout(2,i) = postbout(end-1);
                end
                duration = (indbout(2,i)-indbout(1,i))/fps;
                if duration < 0.1
                    indbout(:,i) = [nan; nan];
                    peakInds(1,i) = nan;
                    peakMags(1,i) = nan;
                end
            end
        else
            indbout = [];
        end
        
        indbout(:,isnan(indbout(1,:))) = [];
        peakInds(isnan(peakInds)) = [];
        peakMags(isnan(peakMags)) = [];
        
        if isempty(indbout) == 0
            
            %             % - PLOT -
%             figure
%             plot(acc)
%             hold on
%             plot(peakInds,acc(peakInds),'o')
%             plot(xlim,[0.15 0.15],'k')
%             plot(xlim,[-0.15 -0.15],'k')
%             plot(indbout(1,:),acc(indbout(1,:)),'ro')
%             plot(indbout(2,:),acc(indbout(2,:)),'ko')
            %             % - END PLOT -
            
            % determine IBI
            if size(indbout,2) > 1
                IBI(f) = mean(diff(indbout(1,:))/150);
            else
                IBI(f) = nan;
            end
            
            %             % - PLOT -
            %             figure,
            %             plot(angf)
            %             hold on
            %             plot(indbout(1,:), angf(indbout(1,:)), 'ro')
            %             plot(indbout(2,:), angf(indbout(2,:)), 'ko')
            %             % - END PLOT -
            
            % determine angle "step"
            
            ang_step = nan(1,size(indbout,2)+1);
            if indbout(1,1)-10 > 0
                ang_step(1) = mean(angf(indbout(1,1)-10:indbout(1,1)));
            else
                ang_step(1) = mean(angf(1:indbout(1,1)));
            end
            for j = 1:size(indbout,2)
                if indbout(2,j)+10 <= ind(2,1)-ind(1,1)+1
                    ang_step(j+1) = mean(angf(1,indbout(2,j):indbout(2,j)+10));
                else
                    a = size(angf,2);
                    ang_step(j+1) = mean(angf(1,indbout(2,j):a));
                end
            end
        end
    end
end
% end