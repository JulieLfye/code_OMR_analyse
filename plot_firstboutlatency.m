%% -- Plotfirst bout latency for spontaneous data and OMR

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

F.dpf = '5_dpf';
F.cycle = '10_mm';
F.speed = '20_mm_s';
D = F.load('data.mat');

% load spontaneous data
Fs = Focus_spontaneous();
Fs.dpf = F.dpf;
Fs.Root = fullfile('D:\OMR_acoustic_experiments',r,'spontaneous\data\');
Ds = Fs.load('data.mat');

if strcmp(F.dpf,'5_dpf') == 1
    color = 'k';
end
if strcmp(F.dpf,'6_dpf') == 1
    color = 'r';
end
if strcmp(F.dpf,'7_dpf') == 1
    color = 'b';
end

%% First bout latency OMR
lat = D.latency_ms;
ne = 50; % nb interval
time = 5; % in sec
xc = linspace(time/ne,time,ne)-time/(2*ne);

% -- per run
mlat = nan(1,size(lat,2));
pb_lat = nan(size(lat,2),size(xc,2));
for i = 1:size(lat,2)
    lat2 = lat{i}-10/150; % OMR starts 10 frame after 150 or 0
%     lat2 = lat{i};
    lat2(isnan(lat2)==1) = [];
    lat2(lat2 > time) = [];
    lat2(lat2 < 0) = [];
    [counts, ~] = hist(lat2,xc);
    pb_lat(i,:) = counts/size(lat2,2);
    mlat(i) = mean(lat2);
end
% figure
% hold on
% for i = 1:size(lat,2)
%     plot(xc,cumsum(pb_lat(i,:)))
% end

m = mean(pb_lat);
s = std(pb_lat)/sqrt(size(lat,2));

% all for proba
lat1 = [];
for i = 1:size(lat,2)
    l = lat{i};
    l(isnan(l)==1) = [];
    l(l > time) = [];
    lat1 = [lat1 l];
end

% figure
% plot(xc,cumsum(m),color,'LineWidth',2)
hold on
% patch([xc fliplr(xc)], [cumsum(m)-s fliplr(cumsum(m)+s)], color, 'FaceAlpha', 0.3, 'EdgeColor', 'none')
plot(xc,m,color,'LineWidth',2)
ylim([0 1])
text(max(xlim)*0.8, max(ylim)*0.9, ['n_{run} = ' num2str(size(lat,2))])
text(max(xlim)*0.8, max(ylim)*0.8, ['n_{fish} = ' num2str(size(lat1,2))])
title(['First bout latency OMR, ' F.dpf(1) 'dpf'])


% %-- all
% 
% [counts, ~] = hist(lat1,xc);
% clat1 = counts/size(lat1,2);
% figure
% plot(xc,cumsum(clat1),color)
% hold on
% plot(xc,clat1,color)
% text(max(xlim)*0.8,max(ylim)*0.8,['n_{fish} = ' num2str(size(lat1,2))])
% title('First bout latency OMR, all')


%% First bout latency spontaneous
lats = Ds.latency_ms_spon;

% -- per run
mlats = nan(1,size(lats,2));
pb_lats = nan(size(lats,2),size(xc,2));
for i = 1:size(lats,2)
    lat2 = lats{i}-10/150;
    lat2(isnan(lat2)==1) = [];
    lat2(lat2 > time) = [];
    lat2(lat2 < 0) = [];
    [counts, ~] = hist(lat2,xc);
    pb_lats(i,:) = counts/size(lat2,2);
    mlats(i) = mean(lat2);
end
% figure
% hold on
% for i = 1:size(lats,2)
%     plot(xc,cumsum(pb_lats(i,:)))
% end

lat1s = [];
for i = 1:size(lats,2)
    l = lats{i};
    l(isnan(l)==1) = [];
    l(l > time) = [];
    lat1s = [lat1s l];
end

[h,p] = kstest2(lat1s,lat1);

ms = mean(pb_lats);
ss = std(pb_lats)/sqrt(size(lats,2));
% figure;
% plot(xc,cumsum(ms),'Color', [97 153 59]/256,'LineWidth',2)
hold on
% patch([xc fliplr(xc)], [cumsum(ms)-ss fliplr(cumsum(ms)+ss)], [97 153 59]/256, 'FaceAlpha', 0.3, 'EdgeColor', 'none')
plot(xc,ms,'Color',[97 153 59]/256,'LineWidth',2)
ylim([0 1])
text(max(xlim)*0.8, max(ylim)*0.7, ['n_{runspon} = ' num2str(size(lats,2))])
text(max(xlim)*0.8, max(ylim)*0.6, ['n_{fishspon} = ' num2str(sum(Ds.nb_fish_spon))])
% text(max(xlim)*0.8, max(ylim)*0.7, ['p = ' num2str(p,3)])
title(['First bout latency spontaneous, ' F.dpf(1) 'dpf'])

xlim([0 5])
ylim([0 1])

% % % -- All

% lat1s(isnan(lat1s) == 1) = [];
% [counts, ~] = hist(lat1s,xc);
% clat1s = counts/size(lat1s,2);
% figure
% plot(xc,cumsum(clat1s),color)
% hold on
% plot(xc,clat1s,color)
% title('First bout latency OMR, all')

% %% difference
% % d = cumsum(clat1s)-cumsum(clat1);
% dc = cumsum(ms)-cumsum(m);
% figure(3)
% plot(xc,dc,color)
% hold on
% f = find(dc==max(dc));
% stem(xc(f),dc(f),color)
% text(8,max(ylim)*0.9,['t = ' num2str(xc(f)) 's'],'Color',color)
% title('difference cpdf first bout latency, spon-OMR')
% 
% % d = (ms-m).^2;
% % figure
% % plot(xc,d,color)
% % % hold on
% % % f = find(dc==max(dc));
% % % stem(xc(f),dc(f),color)
% % title('difference cpdf first bout latency, spon-OMR')

