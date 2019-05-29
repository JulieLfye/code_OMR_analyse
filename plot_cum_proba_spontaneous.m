% code test

clc;
close all;

% nb = [nan, nan];
% no_tracking = [];
% file = 'tracking.txt';
% 
% disp('Select the folder with the movie to analyze');
% selpath = uigetdir('D:\OMR_acoustic_experiments\spontaneous');
% disp('Movie to analyse?');
% nb(1) = input('from ??     ');
% nb(2) = input('to ??       ');
% 
% F = Focus_spontaneous();
% 
% for k = nb(1):nb(2)
%     
%     d = floor(k/10);
%     u = floor(k-d*10);
%     run = ['run_', num2str(d), num2str(u)];
%     path = fullfile(selpath,run);
%     
%     if isfile(fullfile(path, 'raw_data.mat')) == 1
%         
%         load(fullfile(path,'raw_data.mat'));
%         F.dpf = P.fish(4);
%         F.dpf = [F.dpf '_dpf'];
%         
%         lat1 = lat(isnan(lat)==0);
%         
%         if isfolder(F.path) == 0
%             mkdir(F.path);
%         end
%         
%         if isfile(fullfile(F.path,'data_latency.mat')) == 1
%             D = F.load('data_latency.mat');
%             latency_ms = D.latency_ms;
%             s = size(latency_ms,2);
%             latency_ms{s+1} = lat1;
%             save(fullfile(F.path,'data_latency.mat'),'latency_ms');
%         else
%             latency_ms{1} = lat1;
%             save(fullfile(F.path,'data_latency.mat'), 'latency_ms');
%         end
%     end
% end

%% plot
F = Focus_spontaneous();
F.dpf = '5_dpf';
D = F.load('data_latency.mat');

lat_ms = D.latency_ms;

s = size(lat_ms,2);
for i = 1:s
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

figure,
plot(xcenters, m, 'b')
hold on
patch([xcenters fliplr(xcenters)], [m+std fliplr(m-std)], 'b', 'FaceAlpha', 0.3, 'EdgeColor', 'none')
ylim([0 1])
xlabel('First bout latency (s)')
ylabel('Cumulative probability')
title('Cum Proba spontaneous')
text(9,0.9, ['n_{trial} = ' num2str(size(yc,1))], 'HorizontalAlignment', 'right')