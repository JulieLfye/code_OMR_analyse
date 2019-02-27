% % code test
% 
% % Analyse OMR
% 
% clear
% close all
% clc
% 
% j = 1;
% all_file = [];
% all_path = [];
% nb = 0;
% 
% while j~= 0
%     
%     disp('Select the raw_data.mat to analyze (OMR test)');
%     [f,p] = uigetfile('*.mat',[],'C:\Users\LJP\Documents\MATLAB\these\data_OMR\');
%     
%     all_file = [all_file '/' f];
%     all_path = [all_path '/' p];
%     nb = nb + 1;
%     j = input('Other file to analyze? yes:1   no:0     ');
% end
% 
% all_file = [all_file '/'];
% all_path = [all_path '/'];
% 
% f_file = strfind(all_file,'/');
% f_path = strfind(all_path,'/');
% 
% for k = 1:nb
%     file = all_file(f_file(k)+1:f_file(k+1)-1);
%     path = all_path(f_path(k)+1:f_path(k+1)-1);
%     
%     load(fullfile(path,file));
%     F.date = path(end-25:end-18);
%     
% end

ff = find(isnan(seq(1,:))==1);
fps = 150;
time = 0:1/fps:10-1/fps;

% plot the evolution of the angle to OMR
ang = mod(angle,2*pi);
a = find(ang>pi);
ang(a) = ang(a) - 2*pi;
m = mean(abs(ang),'omitnan');
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
% [boutindexes, minh, nbouts] = BoutSpot_julie(cx, cy, fps, 1);
% end