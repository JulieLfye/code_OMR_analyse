%% Plot direction probability

clear;
close all;
clc;

% load OMR data
F = Focus_OMR();

% --- Experiment Protocol background
% r = 'whole_illumination_asus_projo';
% r = 'whole_illumination';
r = 'OMR_fixed';

F.Root = fullfile('D:\OMR_acoustic_experiments',r,'OMR\data');
% F.Root = fullfile('D:\OMR_acoustic_experiments',r,'pattern_OMR\data');

F.dpf = '7_dpf';
F.cycle = '10_mm';
F.speed = '20_mm_s';
D = F.load('data.mat');

if strcmp(F.dpf,'5_dpf') == 1
    color = 'k';
end
if strcmp(F.dpf,'6_dpf') == 1
    color = 'r';
end
if strcmp(F.dpf,'7_dpf') == 1
    color = 'b';
end

time = 2; % in sec
ne = 8;
xc = linspace(0,2,ne+1);

%%
% close all

% i = 1;
% bd = [];
% lat = [];
% for i = 1:size(D.bout_direction,2)
%     bd = [bd D.bout_direction{i}(:,1)'];
%     lat = [lat D.latency_ms{i}-10/150];
% end
% bd(isnan(lat)==1) = [];
% lat(isnan(lat)==1) = [];
% bd(lat < 0) = [];
% lat(lat < 0) = [];
% 
% % without taking into account the angle before the bout
% 
% m1 = nan(1,ne);
% for j = 1:ne
%     f = find(lat <= xc(j+1));
%     m1(j) = mean(bd(f));
%     lat(f) = [];
%     bd(f) = [];
% end
% hold on
% plot(xc(2:end),m1,'o')
% xlim([0 2])
% ylim([-1 1])
% hold on
% plot(xlim,[0 0],'k')

% %%

% for i = 1:size(D.bout_direction,2)
%     bd = D.bout_direction{i}(:,1)';
%     lat = D.latency_ms{i};
%
%     % without taking into account the angle before the bout
%
%     for j = 1:ne
%         f = find(lat < xc(j+1));
%         m2(i,j) = mean(bd(f),'omitnan');
%         lat(f) = [];
%         bd(f) = [];
%     end
% end
% m2m = mean(m2,'omitnan');
% s2 = std(m2,'omitnan')/sqrt(size(m2,1));
% % plot(xc(2:end),m2m,'o')
% errorbar(xc(2:end),m2m,s2,'-o')
% xlim([0 2])
% ylim([-1 1])
% hold on
% plot(xlim,[0 0],'k')

%% per run
% close all
clc

i = 1;
for i = 1: size(D.bout_direction,2)
    bd = D.bout_direction{i}(:,1)';
    lat = D.latency_ms{i};
    latim = D.latency_im{i};
    bd(isnan(latim)==1) = [];
    lat(isnan(latim)==1) = [];
    latim(isnan(latim)==1) = [];
    ang_b = [];
    for j = 1:size(latim,2)
        if latim(j) > 6
        ang_b(j) = mean(D.angle_OMR{i}(j,latim(j)-5:latim(j)));
        else
            ang_b = D.angle_OMR{i}(j,latim(j));
        end
    end
    ang_b = mod(ang_b,2*pi);
    ang_b(ang_b > pi) = ang_b(ang_b > pi) - 2*pi;
    
    % determine fish in the good quadrant
    indleft = find(ang_b > 0);
    indright = find(ang_b <= 0);
    
    l1 = find(ang_b > 40*pi/180);
    l2 = find(ang_b < 140*pi/180);
    for i = 1:size(l1,2)
        b = find(l2 == l1(i));
        if isempty(b) == 1
            l1(i) = nan;
        end
    end
    indlq = l1(isnan(l1)==0);
    
    r1 = find(ang_b < -40*pi/180);
    r2 = find(ang_b > -140*pi/180);
    b = [];
    for i = 1:size(r1,2)
        b = find(r2 == r1(i));
        if isempty(b) == 1
            r1(i) = nan;
        end
    end
    indrq = r1(isnan(r1)==0);
    indok = [indlq, indrq];
    indok = sort(indok);
    
    lat2 = lat(indok);
    bd2 = bd(indok);
    for j = 1:ne
        f = find(lat2 < xc(j+1));
%         bd3 = bd2(f);
%         bd3(bd3==0) = [];
        m2(i,j) = mean(bd2(f),'omitnan');
%         ptoward(i,j) = size(bd2(bd2(f)==1))/size(bd2(f),2);
%         pforward(i,j) = size(bd2(bd2(f)==0))/size(bd2(f),2);
%         pagainst(i,j) = size(bd2(bd2(f)==-1))/size(bd2(f),2);
%         m2(i,j) = mean(bd3,'omitnan');
        lat2(f) = [];
        bd2(f) = [];
    end
end

m2m = mean(m2,'omitnan');
s2 = std(m2,'omitnan')/sqrt(size(m2,1));
plot(xc(2:end),m2m,'o','Color',color,'MarkerFace',color)
hold on
errorbar(xc(2:end),m2m,s2,'Color',color)
xlim([0 2.1])
ylim([-1 1])
hold on
plot(xlim,[0 0],'k')

% figure
% plot(xc(2:end),mean(ptoward),'g')
% hold on
% plot(xc(2:end),mean(pforward),'k')
% plot(xc(2:end),mean(ptoward),'r')
% 
% %% per fish
% bd = [];
% lat = [];
% latim = [];
% ang_b = [];
% for i = 1:size(D.bout_direction,2)
%     bd = [bd D.bout_direction{i}(:,1)'];
%     lat = [lat D.latency_ms{i}];
%     latim = [latim D.latency_im{i}];
%     bd(isnan(latim)==1) = [];
%     lat(isnan(latim)==1) = [];
%     latim(isnan(latim)==1) = [];
%     l = D.latency_im{i};
%     l(isnan(l)==1) = [];
%     for j = 1:size(l,2)
%         ang_b = [ang_b mean(D.angle_OMR{i}(j,l(j)-10:l(j)))];
%     end
% end
% ang_b = mod(ang_b,2*pi);
% ang_b(ang_b > pi) = ang_b(ang_b > pi) - 2*pi;
% 
% % determine fish in the good quadrant
% indleft = find(ang_b > 0);
% indright = find(ang_b <= 0);
% 
% l1 = find(ang_b > 40*pi/180);
% l2 = find(ang_b < 140*pi/180);
% for i = 1:size(l1,2)
%     b = find(l2 == l1(i));
%     if isempty(b) == 1
%         l1(i) = nan;
%     end
% end
% indlq = l1(isnan(l1)==0);
% 
% r1 = find(ang_b < -40*pi/180);
% r2 = find(ang_b > -140*pi/180);
% b = [];
% for i = 1:size(r1,2)
%     b = find(r2 == r1(i));
%     if isempty(b) == 1
%         r1(i) = nan;
%     end
% end
% indrq = r1(isnan(r1)==0);
% indok = [indlq, indrq];
% indok = sort(indok);
% 
% % determine mean direction
% lat1 = lat(indok);
% bd1 = bd(indok);
% for j = 1:ne
%     f = find(lat1 < xc(j+1));
%     m(j) = mean(bd1(f),'omitnan');
%     s(j) = std(bd1(f))/sqrt(size(f,2));
% %     s(j) = std(bd1(f))
%     lat1(f) = [];
%     bd1(f) = [];
% end
% 
% % plot(xc(2:end),m,'o')
% errorbar(xc(2:end),m,s,'-o')
% xlim([0 2])
% ylim([-1 1])
% hold on
% plot(xlim,[0 0],'k')