%% ----- Plot histogram OMR latencies -----
clear;
close all;
clc;

F = Focus_OMR();

F.cycle = 'cycle_10mm';
F.speed = 'speed_20mm_s';
F.dpf = '7_dpf';
p = F.path;
p = p(1:end-1);
l = dir(p(1:end-1));
a = size(l,1);

IBI = [];
latency_J = [];
latency_K = [];
nb_fish = [];

while a > 2
    F.date = l(a).name;
    Data = F.load('data_OMR');
    
    IBI = [IBI Data.IBI];
    latency_J = [latency_J Data.latency_J];
    latency_K = [latency_K Data.latency_K];
    nb_fish = [nb_fish Data.nb_fish_considered];
    
    clear Data
    a = a-1;
end


latency_K(isnan(latency_K)) = [];
[counts, centers] = hist(latency_K,50);
figure,
% bar(centers, counts/size(latency_K,2),1);
bar(centers, counts,1);
hold on
m_K = mean(latency_K, 'omitnan');
med_K = median(latency_K, 'omitnan');
plot([m_K m_K], ylim, 'r', 'Linewidth', 2)
plot([med_K med_K], ylim, 'k', 'Linewidth', 2)
y = ylim;
x = xlim;
xlim([0 x(2)]);
x = xlim;
text(x(2)*0.98,y(2)*0.95, ['mean = ' num2str(m_K,3) ' sec'], 'HorizontalAlignment', 'right')
text(x(2)*0.98,y(2)*0.90, ['ste = ' num2str(std(latency_K)/sqrt(size(latency_K,2)),1) ' sec'], 'HorizontalAlignment', 'right')
text(x(2)*0.98,y(2)*0.85, ['median = ' num2str(med_K,3) ' sec'], 'HorizontalAlignment', 'right')
text(x(2)*0.98,y(2)*0.80, ['n = ' num2str(sum(nb_fish))], 'HorizontalAlignment', 'right')
text(x(2)*0.98,y(2)*0.75, ['n_{resp} = ' num2str(size(latency_K,2))], 'HorizontalAlignment', 'right')
info = [F.dpf(1) 'dpf - ' F.cycle(end-3:end) ' - ' F.speed(end-5:end-2) '/s'];
title({'First bout after OMR starting', info})
pfit = fitdist(latency_K','normal');
gaussfit = max(counts)*exp(-((centers-pfit.mu).^2)/(2*pfit.sigma^2));
plot(centers,gaussfit, 'Linewidth',2)

latency_J(isnan(latency_J)) = [];
[counts, centers] = hist(latency_J,50);
figure,
% bar(centers, counts/size(latency_J,2),1)
bar(centers, counts,1)
hold on
m_J = mean(latency_J, 'omitnan');
med_J = median(latency_J, 'omitnan');
plot([m_J m_J], ylim, 'r', 'Linewidth', 2)
plot([med_J med_J], ylim, 'k', 'Linewidth', 2)
y = ylim;
x = xlim;
xlim([0 x(2)]);
x = xlim;
text(x(2)*0.98,y(2)*0.95, ['mean = ' num2str(m_J,3) ' sec'], 'HorizontalAlignment', 'right')
text(x(2)*0.98,y(2)*0.90, ['ste = ' num2str(std(latency_J)/sqrt(size(latency_J,2)),1) ' sec'], 'HorizontalAlignment', 'right')
text(x(2)*0.98,y(2)*0.85, ['median = ' num2str(med_J,3) ' sec'], 'HorizontalAlignment', 'right')
text(x(2)*0.98,y(2)*0.80, ['n = ' num2str(sum(nb_fish))], 'HorizontalAlignment', 'right')
text(x(2)*0.98,y(2)*0.75, ['n_{resp} = ' num2str(size(latency_J,2))], 'HorizontalAlignment', 'right')
title({'First bout with fish angle nearby OMR direction +-45°', info})
pfit = fitdist(latency_J','normal');
gaussfit = max(counts)*exp(-((centers-pfit.mu).^2)/(2*pfit.sigma^2));
plot(centers,gaussfit, 'Linewidth',2)

IBI(isnan(IBI)) = [];
[counts, centers] = hist(IBI,50);
figure,
bar(centers, counts,1);
hold on
m_IBI = mean(IBI, 'omitnan');
plot([m_IBI m_IBI], ylim, 'r', 'Linewidth', 2)
y = ylim;
x = xlim;
xlim([0 x(2)]);
x = xlim;
text(x(2)*0.98,y(2)*0.95, ['mean = ' num2str(m_IBI,3) ' sec'], 'HorizontalAlignment', 'right')
text(x(2)*0.98,y(2)*0.90, ['std = ' num2str(std(IBI)/sqrt(size(IBI,2)),1) ' sec'], 'HorizontalAlignment', 'right')
text(x(2)*0.98,y(2)*0.85, ['n = ' num2str(size(IBI,2))], 'HorizontalAlignment', 'right')
info = [F.dpf(1) 'dpf - ' F.cycle(end-3:end) ' - ' F.speed(end-5:end-2) '/s'];
title({'IBI', info})
pfit = fitdist(IBI','normal');
gaussfit = max(counts)*exp(-((centers-pfit.mu).^2)/(2*pfit.sigma^2));
plot(centers,gaussfit,'Linewidth',2)