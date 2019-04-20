% Analyse OMR, extract first bout OMR

clear
close all
clc

nb = [nan, nan];
no_raw_data = [];

disp('Select the folder with the movie to analyze');
selpath = uigetdir('D:\OMR_acoustic_experiments\OMR');
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
        date = path(end-36:end-29);
        if cycle == 6
            F.cycle = ['cycle_0' num2str(cycle) 'mm'];
        else
            F.cycle = ['cycle_' num2str(cycle) 'mm'];
        end
        F.speed = ['speed_' num2str(speed) 'mm_s'];
        F.date = date;
        F.dpf = [P.fish(4) '_dpf'];
        
        % analyse
        [first_bout1, fish_to_consider1] = extract_OMR_latency_fbout(xbody,indbout,fps, date);
        IBI1 = IBI;
        
        % create date folder if not existing
        if isfolder(F.path) == 0
            mkdir(F.path);
        end
        
        % save data for the movie
        save(fullfile(F.path,['data_OMR_', num2str(dp), num2str(up) , '.mat']), 'IBI1',...
            'first_bout1', 'fish_to_consider1');
        
        % save all data of this date
        if isfile(fullfile(F.path,'data_OMR.mat')) == 1
            D = F.load('data_OMR.mat');
            IBI = [D.IBI IBI1];
            first_bout = [D.first_bout first_bout1];
            fish_to_consider = [D.fish_to_consider fish_to_consider1];
            save(fullfile(F.path,'data_OMR.mat'),'IBI', 'first_bout', 'fish_to_consider');
        else
            IBI = IBI1;
            first_bout = first_bout1;
            fish_to_consider = fish_to_consider1;
            save(fullfile(F.path,'data_OMR.mat'),'IBI', 'first_bout', 'fish_to_consider');
        end
        
    else
        no_raw_data = [no_raw_data, k];
    end
end

if isempty(no_raw_data) == 0
    X = ['No raw data for run ', num2str(no_raw_data)];
    disp(X);
end
