% To do at the beginning of each analysis !!!
% Copy, paste at the beginning of the analysis code

%% To do first for the experiment analysis
clearvars -except D 
close all
% work for exponential luminosity and sinusoidale luminosity without angle0
% sets at 90 !!

% ----- Name the variables -----
angle_lab = D.experiment.angle;
angle_source = D.experiment.angleCum;
angle_filtered = D.experiment.angleFiltered;
framerate = D.experiment.framerate;
coordinates = D.experiment.coordinates;
luminosity = D.experiment.luminosity;

% ----- Select the luminosity profile and the % -----
%lum_th = luminosity_exponentielle(0.3);
lum_th = luminosity_sinus(0.6);

% ----- Remove the short sequences -----
timemin = 10; % sequence minimal time in sec
[seq_remove,sequence,angle_lab,angle_source,angle_filtered,framerate,...
    coordinates,luminosity]=remove_sequence(D,timemin);
