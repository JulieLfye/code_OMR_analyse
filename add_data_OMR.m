% -- Add data to all data file

clear;
clc;
close all;

warning off

nb = [nan, nan];
no_rawdata = [];
file = 'tracking.txt';

F = Focus_OMR();
F.cycle = '10_mm';
F.speed = '20_mm_s';

disp('Select the folder with the movie to analyze');
selpath = uigetdir('D:\OMR_acoustic_experiments\OMR\');
disp('Movie to analyse?');
nb(1) = input('from ??     ');
nb(2) = input('to ??       ');

tic
wb = waitbar(0,sprintf('Extract bout, movie 1 / %d', nb(2)-nb(1)+1));
for k = nb(1):nb(2)
    
    d = floor(k/10);
    u = floor(k-d*10);
    run = ['run_', num2str(d), num2str(u)];
    path = fullfile(selpath,run);
    
    if isfile(fullfile(path, 'raw_data.mat')) == 1
        
        load(fullfile(path,'raw_data.mat'));
        path = fullfile(selpath,run);
        F.dpf = P.fish(4);
        F.dpf = [F.dpf '_dpf'];
        
        return
        
        clear IBI
        
        if nb_frame == 1650
            % -- Determine OMR IBI
            IBI = nan(1,size(fish_to_consider,2));
            for i = 1:size(fish_to_consider,2)
                f = fish_to_consider(i);
                if sum(sum(indbout{f}(:,:))) ~= 0
                    b = find(indbout{f}(1,:)>150);
                    IBI(i) = mean(diff(indbout{f}(1,b)))/fps;
                end
            end
        elseif nb_frame == 1500
            % -- Determine OMR IBI
            IBI = nan(1,size(fish_to_consider,2));
            for i = 1:size(fish_to_consider,2)
                f = fish_to_consider(i);
                if sum(sum(indbout{f}(:,:))) ~= 0
                    b = find(indbout{f}(1,:)>1);
                    IBI(i) = mean(diff(indbout{f}(1,b)))/fps;
                end
            end
        end
        save(fullfile(path, 'raw_data.mat'), 'ang_body', 'angle_OMR',...
            'f_remove', 'file', 'fish_to_consider', 'fps', 'IBI', 'indbout',...
            'nb_detected_object', 'nb_frame', 'OMR_angle', 'P', 'path', 'seq',...
            'xbody', 'ybody','lat_im','lat_ms','mat_turn');
        disp('Raw data saved')
        
        ib = IBI;
        %  save data on the data folder
        if isfolder(F.path) == 0
            mkdir(F.path);
        end
        
        if isfile(fullfile(F.path,'data_latency.mat')) == 1
            D = F.load('data_latency.mat');
            a = isfield(D,'IBI');
            latency_im = [D.latency_im lat_im];
            latency_ms = [D.latency_ms lat_ms];
            bout_direction = [D.bout_direction] ;
                
            if a == 0
            IBI = ib;
            n_fish = size(fish_to_consider,2));
            save(fullfile(F.path,'data_latency.mat'),'latency_im','latency_ms','bout_direction','IBI','n_fish');
            else
                IBI = [D.IBI ib];
                save(fullfile(F.path,'data_latency.mat'),'latency_im','latency_ms','bout_direction','IBI');
            end
        end
    else
        no_rawdata = [no_rawdata, k];
    end
    
    waitbar((k-nb(1)+1)/(nb(2)-nb(1)+1),wb,sprintf('Extract bout, movie %d / %d', k-nb(1)+1, nb(2)-nb(1)+1));
end

if isempty(no_rawdata) == 0
    X = ['No tracking for run ', num2str(no_rawdata)];
    disp(X);
end

close(wb)
close all;
path