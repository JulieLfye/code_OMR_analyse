% Analyse OMR
% by folder

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


tic
w = waitbar(0,'Analysing');
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
            F.cycle = ['cycle_0' num2str(cycle) 'mm'];
        else
            F.cycle = ['cycle_' num2str(cycle) 'mm'];
        end
        F.speed = ['speed_' num2str(speed) 'mm_s'];
        F.date = date;
        F.dpf = [P.fish(4) '_dpf'];
        
        % analyse
        [IBI1, latency_K1, latency_J1] = extract_OMR_latency(nb_detected_object,...
            seq, xbody, ybody, angle, fps) ;
        nb_fish_considered1 = 0;
        for i = 1:fps/2
            f = find(isnan(xbody(:,i))==0);
            if size(f,1) > nb_fish_considered1
                nb_fish_considered1 = size(f,1);
            end
        end
        
        % create date folder if not existing
        if isfolder(F.path) == 0
            mkdir(F.path);
        end
        
        % save data for the movie
        save(fullfile(F.path,['data_OMR_', num2str(dp), num2str(up) , '.mat']), 'IBI1',...
            'latency_K1', 'latency_J1', 'nb_fish_considered1');
        
        % save all data of this date
        if isfile(fullfile(F.path,'data_OMR.mat')) == 1
            D = F.load('data_OMR.mat');
            IBI = [D.IBI IBI1];
            latency_K = [D.latency_K latency_K1];
            latency_J = [D.latency_J latency_J1];
            nb_fish_considered = [D.nb_fish_considered nb_fish_considered1];
            save(fullfile(F.path,'data_OMR.mat'),'IBI', 'latency_K', 'latency_J', 'nb_fish_considered');
        else
            IBI = IBI1;
            latency_K = latency_K1;
            latency_J = latency_J1;
            nb_fish_considered = nb_fish_considered1;
            save(fullfile(F.path,'data_OMR.mat'),'IBI', 'latency_K', 'latency_J', 'nb_fish_considered');
        end
        
    else
        no_raw_data = [no_raw_data, k];
    end
    waitbar((k-nb(1)+1)/(nb(2)-nb(1)+1),w);
end
toc

if isempty(no_raw_data) == 0
    X = ['No raw data for run ', num2str(no_raw_data)];
    disp(X);
end

close(w);
% ff = find(isnan(seq(1,:))==1);
% fps = 150;
% time = 0:1/fps:10-1/fps;

% plot the evolution of the angle to OMR
% ang_ev = mod(angle,2*pi);
% a = find(ang_ev>pi);
% ang_ev(a) = ang_ev(a) - 2*pi;
% m = mean(abs(ang_ev),'omitnan');
% plot(time,m)
