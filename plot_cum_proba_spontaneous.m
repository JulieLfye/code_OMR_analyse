clc;
clear;
close all;


%% plot
F = Focus_spontaneous();

% Experiment Protocol background
% r = 'whole_illumination_asus_projo'; 
% r = 'whole_illumination'; 
r = 'OMR_fixed'; 

F.Root = fullfile('D:\OMR_acoustic_experiments',r,'spontaneous\data\');

F.dpf = '5_dpf';
D = F.load('data.mat');

lat_ms = D.latency_ms_spon;

s = size(lat_ms,2);

for i = 1:s
    if size(lat_ms{i},1) > 1
        lat_ms{i} = reshape(lat_ms{i},1,[]);
    end
    
    [counts,centers] = hist(lat_ms{i},100);
    xcp(i,:) = [0, centers];
    ycp(i,:) = [0, cumsum(counts)/sum(counts)];
end

xcenters = linspace(0,10,101);
d = diff(xcenters);
xcenters = cumsum(d)-d(1)/2;

% figure
for i = 1:s
    [counts,centers] = hist(lat_ms{i},xcenters');
    yc(i,:) = [0, cumsum(counts)/sum(counts)];
    hold on
    plot([0, xcenters],yc(i,:))
end
title('Cum Proba spontaneous, all curve')
text(9,0.9, ['n_{trial} = ' num2str(size(yc,1))], 'HorizontalAlignment', 'right')

m = mean(yc);
stde = std(yc)/sqrt(size(yc,1));
std = std(yc);

xcenters = [0 xcenters];
figure,
plot(xcenters, m, 'b')
hold on
patch([xcenters fliplr(xcenters)], [m+stde fliplr(m-stde)], 'b', 'FaceAlpha', 0.3, 'EdgeColor', 'none')
ylim([0 1])
xlabel('First bout latency (s)')
ylabel('Cumulative probability')
title('Cum Proba spontaneous')
text(9,0.9, ['n_{trial} = ' num2str(size(yc,1))], 'HorizontalAlignment', 'right')

% figure,
% plot(xcenters, m, 'b')
% hold on
% patch([xcenters fliplr(xcenters)], [m+std fliplr(m-std)], 'b', 'FaceAlpha', 0.3, 'EdgeColor', 'none')
% ylim([0 1])
% xlabel('First bout latency (s)')
% ylabel('Cumulative probability')
% title('Cum Proba spontaneous')
% text(9,0.9, ['n_{trial} = ' num2str(size(yc,1))], 'HorizontalAlignment', 'right')