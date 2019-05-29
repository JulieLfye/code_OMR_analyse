% test

% Difference between 1st bout spontaneous latency and OMR 1st bout latency

clear;
close all;
clc;

% load spontaneous data
load('D:\OMR_acoustic_experiments\spontaneous\data\data_all_cum_proba_1st_bout.mat')
Fs = Focus_spontaneous();
Fs.dpf = '5_dpf';
Ds5 = Fs.load('data_latency.mat');
lats5 = [];
for i = 1:size(Ds5.latency_ms,2)
    lats5 = [lats5 Ds5.latency_ms{i}];
end
lats5(isnan(lats5)==1) = [];

Fs.dpf = '6_dpf';
Ds6 = Fs.load('data_latency.mat');
lats6 = [];
for i = 1:size(Ds6.latency_ms,2)
    lats6 = [lats6 Ds6.latency_ms{i}];
end
lats6(isnan(lats6)==1) = [];

Fs.dpf = '7_dpf';
Ds7 = Fs.load('data_latency.mat');
lats7 = [];
for i = 1:size(Ds7.latency_ms,2)
    lats7 = [lats7 Ds7.latency_ms{i}];
end
lats7(isnan(lats7)==1) = [];

% load OMR data
F = Focus_OMR();
F.cycle = '10_mm';
F.speed = '20_mm_s';

F.dpf = '5_dpf';
D5 = F.load('data_latency.mat');
lat5 = D5.latency_ms;
lat5(isnan(lat5)==1) = [];
F.dpf  = '6_dpf';
D6 = F.load('data_latency.mat');
lat6 = D6.latency_ms;
lat6(isnan(lat6)==1) = [];
F.dpf = '7_dpf';
D7 = F.load('data_latency.mat');
lat7 = D7.latency_ms;
lat7(isnan(lat7)==1) = [];

xc = xcenters;
xc(xc==0) = [];
[counts,~] = hist(lat5,xc);
y5 = [0, cumsum(counts)/sum(counts)];
[counts,~] = hist(lat6,xc);
y6 = [0, cumsum(counts)/sum(counts)];
[counts,~] = hist(lat7,xc);
y7 = [0, cumsum(counts)/sum(counts)];

% Plot cum proba OMR data
figure
plot(xcenters,y5,'k')
hold on
plot(xcenters,y6,'r')
plot(xcenters,y7,'b')
title('Cum proba OMR')

% Plot cum proba spontaneous data
figure,
plot(xcenters, m5, 'k')
hold on
patch([xcenters fliplr(xcenters)], [m5+stde5 fliplr(m5-stde5)], 'k', 'FaceAlpha', 0.3, 'EdgeColor', 'none')
plot(xcenters, m6, 'r')
patch([xcenters fliplr(xcenters)], [m6+stde6 fliplr(m6-stde6)], 'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none')
plot(xcenters, m7, 'b')
patch([xcenters fliplr(xcenters)], [m7+stde7 fliplr(m7-stde7)], 'b', 'FaceAlpha', 0.3, 'EdgeColor', 'none')
ylim([0 1])

% Plot difference cum proba spontaneous - OMR
d5 = m5-y5;
d6 = m6-y6;
d7 = m7-y7;
figure
plot(xcenters,d5,'k')
hold on
plot(xcenters,d6,'r')
plot(xcenters,d7,'b')
stem(xcenters(find(d5==max(d5))),max(d5),'k')
stem(xcenters(find(d6==max(d6))),max(d6),'r')
stem(xcenters(find(d7==max(d7))),max(d7),'b')
text(9,0.2,['t_5 =  ' num2str(xcenters(find(d5==max(d5)))) 's'], 'HorizontalAlignment', 'right', 'Color','k')
text(9,0.18,['t_6 =  ' num2str(xcenters(find(d6==max(d6)))) 's'], 'HorizontalAlignment', 'right', 'Color','r')
text(9,0.16,['t_7 =  ' num2str(xcenters(find(d7==max(d7)))) 's'], 'HorizontalAlignment', 'right', 'Color','b')
title('Diff cum prob spon-OMR')

% Plot cum proba spontaneous and OMR 5 dpf
figure
plot(xcenters, m5, 'k')
hold on
patch([xcenters fliplr(xcenters)], [m5+stde5 fliplr(m5-stde5)], 'k', 'FaceAlpha', 0.3, 'EdgeColor', 'none')
plot(xcenters, y5, 'r')
title('5 dpf')
ylim([0 1])

% Plot cum proba spontaneous and OMR 6 dpf
figure
plot(xcenters, m6, 'k')
hold on
patch([xcenters fliplr(xcenters)], [m6+stde6 fliplr(m6-stde6)], 'k', 'FaceAlpha', 0.3, 'EdgeColor', 'none')
plot(xcenters, y6, 'r')
title('6 dpf')
ylim([0 1])

% Plot cum proba spontaneous and OMR 7 dpf
figure
plot(xcenters, m7, 'k')
hold on
patch([xcenters fliplr(xcenters)], [m7+stde7 fliplr(m7-stde7)], 'k', 'FaceAlpha', 0.3, 'EdgeColor', 'none')
plot(xcenters, y7, 'r')
title('7 dpf')
ylim([0 1])