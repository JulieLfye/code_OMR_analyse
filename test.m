% code test

% Analyse OMR

clear
close all
clc

nb = [nan, nan];
no_raw_data = [];

disp('Select the folder with the movie to analyze');
selpath = uigetdir('C:\Users\LJP\Documents\MATLAB\these\data_OMR\');
disp('Movie to analyse?');
nb(1,1) = input('from ??     ');
nb(1,2) = input('to ??       ');

F = Focus_OMR();


for k = nb(1,1):nb(1,2)
    
    dp = floor(k/10);
    up = floor(k-dp*10);
    run = ['run_', num2str(dp), num2str(up)];
    path = fullfile(selpath,run);
    
    if isfile(fullfile(path,'raw_data.mat')) == 1
        file = 'raw_data.mat';
        load(fullfile(path,file));
        
        cycle = P.OMR.cycle_mm;
        speed = P.OMR.speed;
        date = path(end-25:end-18);
        if cycle == 6
            F.cyle = ['cycle_0' num2str(cycle) 'mm'];
        else
            F.cycle = ['cycle_' num2str(cycle) 'mm'];
        end
        F.speed = ['speed_' num2str(speed) 'mm_s'];
        F.date = date;
        
        % analyse
        
        
        % create date folder if not existing
        if isfolder(F.path) == 0
            mkdir(F.path);
        end
        
        % save data for the movie
        
        % save all data of this date
        
        
    else
         no_raw_data = [no_raw_data, k];
    end
end

if isempty(no_raw_data) == 0
    X = ['No raw data for run ', num2str(no_raw_data)];
    disp(X);
end


ff = find(isnan(seq(1,:))==1);
fps = 150;
time = 0:1/fps:10-1/fps;

% plot the evolution of the angle to OMR
ang_ev = mod(angle,2*pi);
a = find(ang_ev>pi);
ang_ev(a) = ang_ev(a) - 2*pi;
m = mean(abs(ang_ev),'omitnan');
plot(time,m)

% try to find the latency, I define it as the first bout which change
% orientation toward OMR [-30,+30] , I take only the fish that were present
% at t = 0

f = 1;
% for f = 1:nb_detected_object
    if f == 1
        ind_seq = seq(:,1:ff(f)-1);
    else
        ind_seq = seq(:,ff(f-1)+1:ff(f)-1);
    end
    
ind = ind_seq(:,1);
cx = xbody(f,ind(1,1):ind(2,1));
cy = ybody(f,ind(1,1):ind(2,1));
