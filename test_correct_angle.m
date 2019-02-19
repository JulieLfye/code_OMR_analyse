% code of correct angle
close all
clc
fig = 1;
f = 1;

seq1 = 2;

cx = xbody(1,seq(1,seq1):seq(2,seq1));
cy = ybody(1,seq(1,seq1):seq(2,seq1));
ang = ang_body(1,seq(1,seq1):seq(2,seq1));
ang2 = ang;

% fill the missing value
fnan = find(isnan(ang2)==1);
for i = 1:size(fnan,2)
    ang2(fnan(i)) = ang2(fnan(i)-1);
end
% figure;
% plot(ang2);
% hold on;
% plot(ang);


%%
d  = [nan diff(ang2)];
[val,ind] = findpeaks(d,'MinPeakHeight',pi/2);
plot(d)
hold on
plot(ind,val,'o')

%% determine and correct angle for group of peaks
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
        %%
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
            if mmax <= nb_frame-4 && mmin-4 >= 1
                ang2(f,mmin-3:m-1) = ang2(f,mmin-4);
                ang2(f,m:mmax+3) = ang2(f,mmax+4);
            elseif mmax > nb_frame-3
                ang2(f,m:end-1) = ang2(f,end);
            elseif mmin <= 3
                ang2(f,2:m-1) = ang2(f,1);
            end
            %%
        else
            % create group of index
            %                 disp('n1 diff n2')
            gpind = ind(b1(n1):b1(n2)+1);
            %                 plot(gpind, val(b1(n1):b1(n2)+1),'o')
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
            if mmax <= nb_frame-4 && mmin-4 >= 1
                ang2(f,mmin-3:m-1) = ang2(f,mmin-4);
                ang2(f,m:mmax+3) = ang2(f,mmax+4);
            elseif mmax > nb_frame-3
                ang2(f,m:end-1) = ang2(f,end);
            elseif mmin <= 3
                ang2(f,2:m-1) = ang2(f,1);
            end
        end
    end
elseif isempty(b1) == 0 %only one group
    %     disp('1 gpind?')
    gpind = ind(min(b1):max(b1)+1);
    mmin = min(gpind);
    mmax = max(gpind);
    m = round(mean(gpind));
    if mmax <= nb_frame-4 && mmin-4 >= 1
        ang2(f,mmin-3:m-1) = ang2(f,mmin-4);
        ang2(f,m:mmax+3) = ang2(f,mmax+4);
    elseif mmax > nb_frame-3
        ang2(f,m:end-1) = ang2(f,end);
    elseif mmin <= 3
        ang2(f,2:m-1) = ang2(f,1);
    end
end


%% correct isolated point
l = find(isnan(ind2) == 0);
for i = 1:size(l,2)
    q = ind2(l(i));
    
    if q <= nb_frame-4 && q >= 5
        md = mean(ang2(f,q+3:q+4),'omitnan');
        mg = mean(ang2(f,q-4:q-3),'omitnan');
    elseif q> nb_frame-4
        md = ang2(f,end);
    elseif q <= 4
        mg = ang2(f,1);
    end
    
    % correct angle
    if q <= nb_frame-3 && q-3 >= 1
        ang2(f,q-2:q-1) = mg;
        ang2(f,q:q+2) = md;
    elseif q > nb_frame-3
        ang2(f,q+1:end ) = md;
    elseif q <= 3
        ang2(f,1:q) = mg;
    end
end

angle = ang2;

%% Correction of the 0-360 edge
for i = 2:ind_seq(2,1)
    d1 = (ang2(f,i) - ang2(f,i-1))*180/pi;
    if isnan(d1) == 0
        ta = angle_per_frame(d1);
        if abs(ta) <= 150
            angle(f,i) = angle(f,i-1) + ta*pi/180;
        else
            angle(f,i) = angle(f,i-1);
        end
    end
end
% adapt first and last angle
angle(f,1) = mean(angle(f,2:5),'omitnan');
angle(f,end) = mean(angle(f,end-5:end-2),'omitnan');

if fig == 1
    figure;
    plot(ang*180/pi);
    hold on;
    plot(ang2*180/pi);
%     plot(angle*180/pi);
end