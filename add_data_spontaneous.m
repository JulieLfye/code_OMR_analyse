%% ----- Extract raw data for spontaneous activity movie -----
% New Fasttrack

clear;
clc;
close all;

warning off

nb = [nan, nan];
no_tracking = [];
file = 'tracking.txt';
F = Focus_spontaneous();

disp('Select the folder with the movie to analyze');
selpath = uigetdir('D:\OMR_acoustic_experiments\spontaneous');
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
    
    if isfolder(fullfile(path, 'movie','Tracking_Result')) == 1
        if isfile(fullfile(path,'raw_data.mat')) == 0
            display(['no raw data for run ' num2str(d) num2str(u)])
        else
            load(fullfile(path,'raw_data.mat'));
            F.dpf = P.fish(4);
            F.dpf = [F.dpf '_dpf'];
        end
        
        % -- Determine IBI
        fish_to_consider = find(isnan(xbody(:,1)) == 0)';
        IBI = nan(1,size(fish_to_consider,2));
        for i = 1:size(fish_to_consider,2)
            f = fish_to_consider(i);
            if sum(sum(indbout{f}(:,:))) ~= 0
                IBI(i) = mean(diff(indbout{f}(1,:)))/fps;
            end
        end
        % -- Determine latency first bout with moving window
        lat = nan(size(fish_to_consider,2),nb_frame);
        first_mat_turn = lat;
        for p = 1:nb_frame
            fish_to_consider = find(isnan(xbody(:,p)) == 0)';
            for i = 1:size(fish_to_consider,2)
                f = fish_to_consider(i);
                indbt = indbout{f};
                % - latency first bout
                t = find(indbt(1,:) > p,1);
                if isempty(t) == 0
                    lat(i,p) = (indbt(1,t)-p)/150;
                    % - direction first bout
                    turn = angle(f,indbt(2,t))-angle(f,indbt(1,t));
                    if abs(turn) > 20*pi/180
                        first_mat_turn(i,p) = 1;
                    else
                        first_mat_turn(i,p) = 0;
                    end
                end
            end
        end        
        
    else
        no_tracking = [no_tracking, k];
    end
    
    if isfolder(F.path) == 0
        mkdir(F.path);
    end
    
    if isfile(fullfile(F.path,'data.mat')) == 1
        D = F.load('data.mat');
        
        a = size(D.IBI_spon,2);
        D.latency_ms_spon{a+1} = lat;
        D.first_bout_dir{a+1} = first_mat_turn;
        D.IBI_spon{a+1} = IBI;
        D.n_fish = [D.n_fish size(fish_to_consider,2)];
        latency_ms_spon = D.latency_ms_spon;
        first_bout_dir = D.first_bout_dir;
        IBI_spon = D.IBI_spon;
        n_fish = D.n_fish;
        save(fullfile(F.path,'data.mat'),'latency_ms_spon','first_bout_dir',...
            'IBI_spon', 'n_fish');
    else
        latency_ms_spon{1} = lat;
        first_bout_dir{1} = first_mat_turn;
        IBI_spon{1} = IBI;
        n_fish = size(fish_to_consider,2);
        save(fullfile(F.path,'data.mat'),'latency_ms_spon','first_bout_dir',...
            'IBI_spon', 'n_fish');
    end
    
    
    waitbar((k-nb(1)+1)/(nb(2)-nb(1)+1),wb,sprintf('Extract bout, movie %d / %d', k-nb(1)+2, nb(2)-nb(1)+1));
end

if isempty(no_tracking) == 0
    X = ['No tracking for run ', num2str(no_tracking)];
    disp(X);
end

close(wb)
close all;
path