function [angle, ang_OMR] = correct_angle_sequence(cang, fig, OMRangle)

%% Information
% input:

% output:   - angle: angle of the fish between 0-2Pi, trigonometric convention
%           - ang_OMR: angle of the fish to OMR, between 0-2Pi

% test code
% correct angle with fasttrack new version

% close all
% fig = 1;
% OMRangle = 0;
% f = 2;
% cang = ang_body(f,:);


% for f = 1:nb_detected_object
    %     cang = ang_body(f,:);
    
    ang = cang;
    
    d  = [nan abs(diff(ang))];
    [val,indall] = findpeaks(d,'MinPeakHeight',120*pi/180);
%         plot(d)
%         hold on
%         plot(indall,val,'o')
%         plot(xlim,[230*pi/180 230*pi/180],'k')
    ind = indall(val <= 230*pi/180);
    
    %% correction of peak, not of 0-360 edges
    nb_frame = size(ang,2);
    % determine and correct angle for group of peaks
    dind = diff(ind);
    b1 = find(dind<8);
    a = diff(b1);
    b2 = find(a>1);
    ind2 = ind;
    
    if isempty(b2) == 0
        n1 = 1;
        n2 = b2(1);
        i = 1;
        while i <= size(b2,2)+1 % 2 groups at least
            if n1 == n2
                %create group of index
                gpind = ind(b1(n1):b1(n1)+1);
                ind2(b1(n1):b1(n1)+1) = nan;
                i = i+1;
                n1 = n2+1;
                if i >= size(b2,2)+1
                    n2 = size(b1,2);
                else
                    n2 = b2(i);
                end
                % correct the angle
                mmin = min(gpind);
                mmax = max(gpind);
                m = round(mean(gpind));
                if mmax <= nb_frame-2 && mmin-2 >= 1
                    ang(1,mmin-1:m-1) = ang(1,mmin-2);
                    if abs(ang(1,mmax+1) - ang(1,mmin-2)) < pi
                        ang(1,m:mmax+1) = ang(1,mmax+2);
                    else
                        ang(1,m:mmax+1) = ang(1,mmin-2);
                    end
                elseif mmax > nb_frame-3
                    ang(1,m:end-1) = ang(1,end);
                elseif mmin <= 3
                    ang(1,2:m-1) = ang(1,1);
                end
            else
                % create group of index
                gpind = ind(b1(n1):b1(n2)+1);
                ind2(b1(n1):b1(n2)+1) = nan;
                i = i+1;
                n1 = n2+1;
                if i >= size(b2,2)+1
                    n2 = size(b1,2);
                else
                    n2 = b2(i);
                end
                % correct the angle
                mmin = min(gpind);
                mmax = max(gpind);
                m = round(mean(gpind));
                if mmax <= nb_frame-2 && mmin-2 >= 1
                    ang(1,mmin-1:m-1) = ang(1,mmin-2);
                    if abs(ang(1,mmax+2) - ang(1,mmin-2)) < pi
                        ang(1,m:mmax+1) = ang(1,mmax+2);
                    else
                        ang(1,m:mmax+1) = ang(1,mmin-2);
                    end
                elseif mmax > nb_frame-3
                    ang(1,m:end-1) = ang(1,end);
                elseif mmin <= 3
                    ang(1,2:m-1) = ang(1,1);
                end
            end
        end
    elseif isempty(b1) == 0 %only one group
        gpind = ind(min(b1):max(b1)+1);
        ind2(b1) = nan;
        ind2(max(b1)+1) = nan;
        mmin = min(gpind);
        mmax = max(gpind);
        m = round(mean(gpind));
        if mmax <= nb_frame-2 && mmin-2 >= 1
            ang(1,mmin-1:m-1) = ang(1,mmin-2);
            if abs(ang(1,mmax+2) - ang(1,mmin-2)) < pi
                ang(1,m:mmax+1) = ang(1,mmax+2);
            else
                ang(1,m:mmax+1) = ang(1,mmin-2);
            end
        elseif mmax > nb_frame-3
            ang(1,m:end-1) = ang(1,end);
        elseif mmin <= 3
            ang(1,2:m-1) = ang(1,1);
        end
    end
    
    
    %% correct isolated point
    l = find(isnan(ind2) == 0);
    for i = 1:size(l,2)
        q = ind2(l(i));
        
        if q <= nb_frame-3 && q >= 5
            md = mean(ang(1,q+2:q+3),'omitnan');
            mg = mean(ang(1,q-3:q-2),'omitnan');
        elseif q> nb_frame-3
            md = ang(1,end);
            mg = mean(ang(1,q-3:q-2),'omitnan');
        elseif q <= 4
            mg = ang(1,1);
            md = mean(ang(1,q+2:q+3),'omitnan');
        end
        
        % correct angle
        if q <= nb_frame-3 && q-3 >= 1
            ang(1,q-2:q-1) = mg;
            ang(1,q:q+2) = md;
        elseif q > nb_frame-3
            ang(1,q+1:end ) = md;
        elseif q <= 3
            ang(1,1:q) = mg;
        end
    end
    
    
    %% Correction of the 0-360 edge
    angle = ang;
    
    for i = 2:nb_frame
        d1 = (ang(1,i) - ang(1,i-1))*180/pi;
        if isnan(d1) == 0
            ta = angle_per_frame(d1);
            if abs(ta) <= 170
                angle(1,i) = angle(1,i-1) + ta*pi/180;
            else
                angle(1,i) = angle(1,i-1);
            end
        end
    end
    % adapt first and last angle
    angle(1,1) = mean(angle(1,2:5),'omitnan');
    angle(1,end) = mean(angle(1,end-5:end-2),'omitnan');
    
    
    %% Angle to OMR
    ang_OMR = angle - OMRangle;
    ang1 = mean(ang_OMR(1,1:5),'omitnan');
    if ang1 > pi
        ang_OMR(1,:) = ang_OMR(1,:) - 2*pi;
    end
    
    if fig == 1
        figure;
        plot(ang_body(f,:)*180/pi,'r');
        hold on;
        plot(angle*180/pi,'b');
        %     text(max(xlim)*0.8,max(ylim)*0.95,'red: raw angle')
        %     text(max(xlim)*0.8,max(ylim)*0.90,'blue: corrected angle')
        %     text(min(xlim)*1.05,max(ylim)*0.85,'black: OMR angle')
    end
% end