% -- Plot hist IBI for spontaneous data and OMR

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

F.dpf = '7_dpf';
F.cycle = '10_mm';
F.speed = '20_mm_s';

D = F.load('data.mat');

% load spontaneous data
Fs = Focus_spontaneous();
Fs.dpf = F.dpf;
Fs.Root = fullfile('D:\OMR_acoustic_experiments',r,'spontaneous\data\');
Ds = Fs.load('data.mat');

%% Hist IBI
% -- OMR IBI
IBI = D.IBI;
ne = 100;
xc = linspace(5/ne,5,ne)-5/(2*ne);

% ib1 = [];
% for i = 1:size(IBI,2)
%     ib1 = [ib1 IBI{i}];
% end
% ib1(isnan(ib1)==1) = [];
% [cib,~] = hist(ib1,xc);
% cib = cib/size(ib1,2);
% % bar(xc,cib,1)
% % hold on
% % y = ylim;
% % plot([mean(ib1) mean(ib1)],y,'r')

% per run
mib = nan(1,size(IBI,2));
pb_ib = nan(size(IBI,2),size(xc,2));
for i = 1:size(IBI,2)
    ib = IBI{i};
    ib(isnan(ib)==1) = [];
    [counts, ~] = hist(ib,xc);
    pb_ib(i,:) = counts/size(ib,2);
    mib(i) = mean(ib);
end

ib = [];
for i = 1:size(IBI,2)
    ib = [ib IBI{i}];
end

m = mean(pb_ib);
s = std(pb_ib)/sqrt(size(IBI,2));

bar(xc,m,1,'FaceColor', [0.5 0.5 0.5])
hold on
y1 = ylim;
plot([mean(mib) mean(mib)],y1,'r')
xlow = [mean(mib)-std(mib)/sqrt(size(IBI,2)) mean(mib)-std(mib)/sqrt(size(IBI,2))];
xup = [mean(mib)+std(mib)/sqrt(size(IBI,2)) mean(mib)+std(mib)/sqrt(size(IBI,2))];
patch([xlow fliplr(xup)], [y1 fliplr(y1)], 'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none')
ylim([y1(1) y1(2)])
% xlim([0 3])
text(max(xlim)*0.7, max(ylim)*0.9, ['m = ' num2str(mean(mib),3) ' s'])
text(max(xlim)*0.7, max(ylim)*0.8, ['ste = ' num2str(std(mib)/sqrt(size(IBI,2)),1) ' s'])
text(max(xlim)*0.7, max(ylim)*0.7, ['n_{run} = ' num2str(size(IBI,2))])
text(max(xlim)*0.7, max(ylim)*0.6, ['n_{fish} = ' num2str(sum(D.n_fish))])
title(['OMR IBI - ' num2str(F.dpf(1)) ' dpf'])

% plot([median(mib) median(mib)],y,'k')
% xlow = [median(mib)-std(mib)/sqrt(size(IBI,2)) median(mib)-std(mib)/sqrt(size(IBI,2))];
% xup = [median(mib)+std(mib)/sqrt(size(IBI,2)) median(mib)+std(mib)/sqrt(size(IBI,2))];
% patch([xlow fliplr(xup)], [y fliplr(y)], 'k', 'FaceAlpha', 0.3, 'EdgeColor', 'none')

% -- spontaneous IBI
IBIs = Ds.IBI_spon;

% per run
mibs = nan(1,size(IBIs,2));
pb_ibs = nan(size(IBIs,2),size(xc,2));
for i = 1:size(IBIs,2)
    ibs = IBIs{i};
    ibs(isnan(ibs)==1) = [];
    [counts, ~] = hist(ibs,xc);
    pb_ibs(i,:) = counts/size(ibs,2);
    mibs(i) = mean(ibs);
end

ibs = [];
for i = 1:size(IBIs,2)
    ibs = [ibs IBIs{i}];
end

ms = mean(pb_ibs);
ss = std(pb_ibs)/sqrt(size(IBIs,2));

[h,p] = ttest2(mib,mibs);
mean(mib);
mean(mibs);

figure
bar(xc,ms,1)
hold on
y2 = ylim;
plot([mean(mibs) mean(mibs)],y2,'r')
xlow = [mean(mibs)-std(mibs)/sqrt(size(IBIs,2)) mean(mibs)-std(mibs)/sqrt(size(IBIs,2))];
xup = [mean(mibs)+std(mibs)/sqrt(size(IBIs,2)) mean(mibs)+std(mibs)/sqrt(size(IBIs,2))];
patch([xlow fliplr(xup)], [y2 fliplr(y2)], 'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none')
ylim([y2(1) y2(2)])
% xlim([0 3])
text(max(xlim)*0.7, max(ylim)*0.9, ['m = ' num2str(mean(mibs),3) ' s'])
text(max(xlim)*0.7, max(ylim)*0.8, ['ste = ' num2str(std(mibs)/sqrt(size(IBIs,2)),1) ' s'])
text(max(xlim)*0.7, max(ylim)*0.7, ['n_{run} = ' num2str(size(IBIs,2))])
text(max(xlim)*0.7, max(ylim)*0.6, ['n_{fish} = ' num2str(sum(Ds.n_fish))])
text(max(xlim)*0.7, max(ylim)*0.5, ['p_{spon/OMR} = ' num2str(p,3)])
title(['spontaneous IBI - ' num2str(F.dpf(1)) 'dpf'])

