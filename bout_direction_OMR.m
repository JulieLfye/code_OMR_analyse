% add new raw_data_OMR

clear;
clc;
close all;

warning off

nb = [nan, nan];

F = Focus_OMR();
F.cycle = '20_mm';
F.speed = '10_mm_s';

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
        
        fps = 150;
        OMR_angle = P.OMR.angle*pi/180;
        F.dpf = P.fish(4);
        F.dpf = [F.dpf '_dpf'];
        D = F.load('data_latency.mat');
        
        % calcul new parameter
        % First bout OMR orientation
        
        % -- determine fish that are present from the OMR beginning
        fish_to_consider = find(isnan(xbody(:,150)) == 0)';
        a = 0;
        for i = 1:size(fish_to_consider,2)
            f = fish_to_consider(i);
            indbt = indbout{f};
            t = find(indbt(1,:) > 150);
            a1 = size(t,2);
            if a1 > a
                a = a1;
            end
        end
        
        % -- Determine direction of bouts
        mat_turn = nan(size(fish_to_consider,2),a);
        
        i = 3;
        for i = 1:size(fish_to_consider,2)
            f = fish_to_consider(i);
            indbt = indbout{f};
            t = find(indbt(1,:) > 150);
            j = 1;
            if isempty(t) == 0
                while j <= size(t,2)
                    ang_b = mean(angle_OMR(f,indbt(1,t(j))-10:indbt(1,t(j))));
                    ang_b = mod(ang_b, 2*pi);
                    if ang_b > pi
                        ang_b = ang_b - 2*pi;
                    end
                    turn = angle_OMR(f,indbt(2,t(j)))-angle_OMR(f,indbt(1,t(j)));
                    if abs(turn) > 20*pi/180
                        mat_turn(i,j) = -sign(ang_b)*sign(turn);
                    else
                        mat_turn(i,j) = 0;
                    end
                    j = j+1;
                end
            end
        end
        
        % mat_turn
        % line: fish
        % column: bout
        
        
        save(fullfile(path, 'raw_data.mat'), 'ang_body', 'angle_OMR',...
            'f_remove', 'file', 'fish_to_consider', 'fps', 'IBI', 'indbout', 'mat_turn',...
            'nb_detected_object', 'nb_frame', 'OMR_angle', 'P', 'path', 'seq',...
            'xbody', 'ybody','lat_im','lat_ms');
        disp('Raw data saved')
        
        D = F.load('data_latency.mat');
        latency_im = D.latency_im;
        latency_ms = D.latency_ms;
        bout_direction = D.bout_direction;
        
        a = size(bout_direction{1},2);
        if a > 1
            b = size(bout_direction,2);
            if b > 0
                bout_direction{b+1} = mat_turn;
            end
        else
            bout_direction{1} = mat_turn;
        end
        
        save(fullfile(F.path,'data_latency.mat'),'latency_im','latency_ms','bout_direction');
        
        waitbar(k/nb(2)-nb(1)+1,wb,sprintf('Extract bout, movie %d / %d', k, nb(2)-nb(1)+1));
    end
end
close(wb)
close all;
path