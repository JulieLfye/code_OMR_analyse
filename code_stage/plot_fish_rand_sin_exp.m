%% Comments
% Make a figure with the angle histogram (left) and the cumulative
% probability (right)
% The red curve is the mathematical way to obtain the cumulative
% probability. The cumulative probability shown here can be considered as
% the "reference" to compare the fish cumulatitve probability


%% Code
lum_exp = luminosity_exponentielle(0.3);
lum_sin = luminosity_sinus(0.6);

nb_bins = 20;
centerlum = linspace(1/(nb_bins*2),1-1/(nb_bins*2),nb_bins);
Pmexp = max(lum_exp(:,2));
Pmsin = max(lum_sin(:,2));
ang = rand(10000,1)*360;
ang = 180 - abs(180-ang);
lum = linspace(0,1,181);
lumexp = interp1(lum_exp(:,1),lum_exp(:,2),ang);
lumsin = interp1(lum_sin(:,1),lum_sin(:,2),ang);

% plot the random angle distribution
subplot(3,2,1)
[counts,center]=hist(ang,100);
hist(ang,100)
title('Random angle')
subplot(3,2,2)
plot(center,cumsum(counts)/sum(counts))
hold on
title('Cumulative probability')

% plot the sinusoidal luminosity distribution
subplot(3,2,3)
[counts,~]=hist(lumsin/Pmsin,centerlum);
hist(lumsin/Pmsin,100)
title('Sinusoidal luminosity from the random angle')
subplot(3,2,4)
hold on
plot([0 centerlum+centerlum(1)],[0 cumsum(counts)/sum(counts)])
refsinlum = 2/pi*asin(lum);
plot(lum,refsinlum,'r')

% plot the exponential luminosity distribution
subplot(3,2,5)
[counts,~]=hist(lumexp/Pmexp,centerlum);
hist(lumexp/Pmexp,100)
title('Exponential luminosity from the random angle')
subplot(3,2,6)
hold on
plot([0 centerlum+centerlum(1)],[0 cumsum(counts)/sum(counts)])
refsinexp30 = log(lum(12:end))/2.8283+1;
plot([0 lum(12:end)],[0 refsinexp30],'r')