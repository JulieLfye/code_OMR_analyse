% plot IBI data for spontaneous activity

% disp('Select the IBI data to plot');
% [file,path] = uigetfile('*.mat',[],'C:\Users\LJP\Documents\MATLAB\these\data_spontaneous\data');
% load(fullfile(path,file));

figure,
[counts,centers] = hist(IBI,50);
bar(centers,counts/sum(nb_bout,'omitnan'),1)
mIBI = mean(IBI,'omitnan');
hold on
med = median(IBI,'omitnan');
me = mean(IBI,'omitnan');
plot([med med], ylim, 'k', 'LineWidth', 2)
plot([me me], ylim, 'r', 'LineWidth', 2)
xli = xlim;
xlim([0 xli(2)])
xli = xlim;
yli = ylim;
text(xli(2)*0.7, yli(2)*0.9, ['mean = ' num2str(me,'%#5.2f') ' sec'])
text(xli(2)*0.7, yli(2)*0.8, ['median = ' num2str(med,'%#5.2f') ' sec'])