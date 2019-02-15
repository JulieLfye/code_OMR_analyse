%% Comments
% Select the good sequences and create structure to save data
%Inputs
% D: the datafish
%Outputs
% -AngleLum: a structure which contains the angles and intensity of the
% fish. One line represents one sequence
% -Perfish: a strucutre which contains all the angles and all the intensity
% per fish. One line represents one fish. To add a nex fish, just change
% the line number, ie change fish (line 24)

% /!\ Don't forget to select the good illumination profile(line 35)


%% Code
clearvars -except D Perfish
close all
% work for exponential luminosity and sinusoidale luminosity without angle0
% sets at 90 !!


% TO CHANGE EVERY TIME IF YOU WANT TO CREATE ONE MATRIX WITH THE DATA PER
% FISH ----------------------------------------------------------------
fish = input('fish number?'); % change the number of the fish to do a matrix with all the fish (line Matrix per fish)
% ---------------------------------------------------------------------

% ----- Name the variables -----
angle_lab = D.experiment.angle;
angle_source = D.experiment.angleCum;
angle_filtered = D.experiment.angleFiltered;
framerate = D.experiment.framerate;
coordinates = D.experiment.coordinates;
luminosity = D.experiment.luminosity;

% ----- Select the luminosity profile and the % -----
lum_th = luminosity_exponentielle(0.6);
%lum_th = luminosity_sinus(0.6);

% ----- Remove the short sequences -----
timemin = 10; % sequence minimal time in sec
[seq_remove,sequence,angle_lab,angle_source,angle_filtered,framerate,...
    coordinates,luminosity]=remove_sequence(D,timemin);

% ----- Make the movmean of the angle -----
fig = 0;
[angle_lab,mangle_lab] = angle_lab_f(angle_lab,framerate,fig);
mangle_source = movmean(angle_source,10,2);


%%  ----- Find the bout -----
fig = 0; % if fig = 0, don't plot; if fig=1, plot
[~,ind_b_a_bout,~] = angular_velocity(angle_source,...
    framerate,mangle_source,lum_th,fig);

lum_bout = nan(size(ind_b_a_bout));
ang_bout_source = nan(size(ind_b_a_bout));
ang_bout_lab = nan(size(ind_b_a_bout));

for i = 1:size(ind_b_a_bout,1)
    f = find(ind_b_a_bout(i,:)==0,1)-1;
    if isempty(f) == 0
        lum_bout(i,1:f) = luminosity(i,ind_b_a_bout(i,1:f));
        ang_bout_source(i,1:f) = mangle_source(i,ind_b_a_bout(i,1:f));
        ang_bout_lab(i,1:f) = mangle_lab(i,ind_b_a_bout(i,1:f));
    else
        lum_bout(i,:) = luminosity(i,ind_b_a_bout(i,:));
        ang_bout_source(i,:) = mangle_source(i,ind_b_a_bout(i,:));
        ang_bout_lab(i,:) = mangle_lab(i,ind_b_a_bout(i,:));
    end
end

%% ----- Make the data matrix per fish -----
% Create a matrix where each line represents a fish
if fish==1
    Perfish.ang_bout_lab = [];
    Perfish.ang_bout_source = [];
    Perfish.ang_time_lab = [];
    Perfish.ang_time_source = [];
    Perfish.lum_bout = [];
    Perfish.lum_time = [];
end
if size(lum_bout,1) > 1
    % Matrix of all the bout angles in the lab reference
    pfish_ang_bout_lab = matrix_per_fish_reshape(Perfish.ang_bout_lab,one_sequence(ang_bout_lab),fish);
    % Matrix of all the bout angles in the source reference
    pfish_ang_bout_source = matrix_per_fish_reshape(Perfish.ang_bout_source,one_sequence(ang_bout_source),fish);
    % Matrix of all the time angles in the lab reference
    pfish_ang_time_lab = matrix_per_fish_reshape(Perfish.ang_time_lab,one_sequence(mangle_lab),fish);
    % Matrix of all the time angles in the source refernece
    pfish_ang_time_source = matrix_per_fish_reshape(Perfish.ang_time_source,one_sequence(mangle_source),fish);
    % Matrix of all the bout luminosity
    pfish_lum_bout = matrix_per_fish_reshape(Perfish.lum_bout,one_sequence(lum_bout),fish);
    % Matrix of all the time luminosity
    pfish_lum_time = matrix_per_fish_reshape(Perfish.lum_time,one_sequence(luminosity),fish);
elseif size(lum_bout,1) == 1
    % Matrix of all the bout angles in the lab reference
    pfish_ang_bout_lab = matrix_per_fish_reshape(Perfish.ang_bout_lab,ang_bout_lab,fish);
    % Matrix of all the bout angles in the source reference
    pfish_ang_bout_source = matrix_per_fish_reshape(Perfish.ang_bout_source,ang_bout_source,fish);
    % Matrix of all the time angles in the lab reference
    pfish_ang_time_lab = matrix_per_fish_reshape(Perfish.ang_time_lab,mangle_lab,fish);
    % Matrix of all the time angles in the source refernece
    pfish_ang_time_source = matrix_per_fish_reshape(Perfish.ang_time_source,mangle_source,fish);
    % Matrix of all the bout luminosity
    pfish_lum_bout = matrix_per_fish_reshape(Perfish.lum_bout,lum_bout,fish);
    % Matrix of all the time luminosity
    pfish_lum_time = matrix_per_fish_reshape(Perfish.lum_time,luminosity,fish);
end

Perfish.ang_bout_lab = pfish_ang_bout_lab;
Perfish.ang_bout_source = pfish_ang_bout_source;
Perfish.ang_time_lab = pfish_ang_time_lab;
Perfish.ang_time_source = pfish_ang_time_source;
Perfish.lum_bout = pfish_lum_bout;
Perfish.lum_time = pfish_lum_time;

AngleLum.ang_bout_lab = ang_bout_lab;
AngleLum.ang_bout_source = ang_bout_source;
AngleLum.ang_time_lab = angle_lab;
AngleLum.ang_time_source = angle_source;
AngleLum.lum_bout = lum_bout;
AngleLum.lum_time = luminosity;

clearvars -except D Perfish AngleLum