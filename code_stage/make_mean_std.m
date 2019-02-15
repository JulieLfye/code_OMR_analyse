%% Comments
% Add 2 columns at f: the first one is the mean and the second one the
% standard deviation

%% Code
close all

f = proba_lum_bout_sin;

for i=1:size(f,1)
    m(i,1) = mean(f(i,2:end));
    m(i,2) = std(f(i,2:end));
end

mproba_lum_bout_sin = m;

figure
hold on
for i = 2:size(f,2)
    plot(f(:,1),f(:,i))
end
plot(f(:,1),m(:,1),'k','Linewidth',2)
clear i f m