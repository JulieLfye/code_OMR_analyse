% code test

% Extract IBI

clear
close all
clc

j = 1;
all_file = [];
all_path = [];
nb = 0;

while j~= 0
    
    disp('Select the raw_data.mat to analyze (spontaneous activity)');
    [f,p] = uigetfile('*.mat',[],'C:\Users\LJP\Documents\MATLAB\these\data_spontaneous\');
    
    all_file = [all_file '/' f];
    all_path = [all_path '/' p];
    nb = nb + 1;
    j = input('Other file to analyze? yes:1   no:0     ');
end

all_file = [all_file '/'];
all_path = [all_path '/'];

f_file = strfind(all_file,'/');
f_path = strfind(all_path,'/');

F = Focus_spontaneous();

for k = 1:nb
    file = all_file(f_file(k)+1:f_file(k+1)-1);
    path = all_path(f_path(k)+1:f_path(k+1)-1);
    
    load(fullfile(path,file));
    F.date = path(end-25:end-18);
    
    if isfile(fullfile(F.path,'all_data_IBI.mat')) == 0
        D.all_IBI = [];
        D.all_bout = [];
    else
        D = F.load('all_data_IBI.mat');
    end
    
    
    % code
    ff = find(isnan(seq(1,:))==1);
    bout_indexes = [];
    nb_bout = [];
    IBI = [];
    fps = 150;
    for f = 1:nb_detected_object
        if f == 1
            ind_seq = seq(:,1:ff(f)-1);
        else
            ind_seq = seq(:,ff(f-1)+1:ff(f)-1);
        end
        
        while isempty(ind_seq) == 0
            cx = xbody(f,ind_seq(1,1):ind_seq(2,1));
            cy = ybody(f,ind_seq(1,1):ind_seq(2,1));
            
            % determine IBI with x, y (I don't use the angle)
            [boutind, minh, nbouts] = BoutSpot_julie(cx, cy, fps, 0);
            bout_indexes = [bout_indexes, boutind, nan];
            nb_bout = [nb_bout, nbouts, nan];
            IBI = [IBI, diff(boutind)/fps, nan];
            
            ind_seq(:,1) = [];
        end
    end
    
    all_IBI = [D.all_IBI IBI(isnan(IBI)==0)];
    all_bout = [D.all_bout sum(nb_bout,'omitnan')];
    
    
    %save all_data_IBI
    run = path(end-12:end-11);
    p = ['run_' run '_IBI_data' '.mat'];
    save(fullfile(F.path,'all_data_IBI.mat'), 'all_IBI', 'all_bout');
    save(fullfile(F.path,p), 'bout_indexes', 'nb_bout', 'IBI');
    
    
    figure,
    [counts,centers] = hist(IBI,50);
    bar(centers,counts/sum(nb_bout,'omitnan'),1)
    hold on
    med = median(IBI,'omitnan');
    me = mean(IBI,'omitnan');
    plot([med med], ylim, 'k', 'LineWidth', 2)
    plot([me me], ylim, 'r', 'LineWidth', 2)
    xli = xlim;
    xlim([0 xli(2)])
    xli = xlim;
    yli = ylim;
    text(xli(2)*0.7, yli(2)*0.9, ['mean = ' num2str(me,'%#5.2f') ' sec'])
    text(xli(2)*0.7, yli(2)*0.8, ['median = ' num2str(med,'%#5.2f') ' sec'])
    text(xli(2)*0.7, yli(2)*0.7, ['n bout = ' num2str(sum(nb_bout,'omitnan'))])
    title(['PDF IBI for run ' run])
    
end