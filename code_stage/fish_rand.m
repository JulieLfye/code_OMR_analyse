function [counts]=fish_rand(lum,nb_bins,fig)
%% Comments
% Show the angle histogram of a random fish (uniform angle distribution)
% according to a certain luminosity profile
%Inputs -----
% lum: luminosity profile
% nb_bins: nb of bins for the histogram
% fig: if fig=0, don't plot, if fig=1, plot
%Outputs -----
% counts: value of the histogram for each bins

%% Code
centerlum = linspace(1/(nb_bins*2),1-1/(nb_bins*2),nb_bins);
Pmax = max(lum(:,2));
ang = rand(10000,1)*360;
ang = 180 - abs(180-ang);

lum = interp1(lum(:,1),lum(:,2),ang);
if fig == 1
    [counts,center]=hist(ang,100);
    subplot(2,2,1)
    hist(ang,100)
    title('Hist of uniform angle distribution')
    subplot(2,2,2)
    plot(center,cumsum(counts)/sum(counts))
    title('Cumulative probability')
end
[counts,~]=hist(lum/Pmax,centerlum);
if fig == 1
    subplot(2,2,3)
    hist(lum,100)
    title('Hist of angles for the lum profile')
    subplot(2,2,4)
    plot(centerlum,cumsum(counts)/sum(counts))
    title('Cumulative probability')
end