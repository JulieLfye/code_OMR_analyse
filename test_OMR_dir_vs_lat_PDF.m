% test forward

% test
% plot PDF bout direction in function of 1st OMR latency

clear;
close all;
clc;
%% -- OMR
F = Focus_OMR();
F.cycle = '10_mm';
F.speed = '20_mm_s';
ml = 2.1;
ne = ml*1/0.1;
% xc = linspace(ml/ne,ml,ne)-ml/(2*ne);
xc = [0.7 2.1];

pforward = nan(size(xc));
pagainst = pforward;
ptoward = pforward;

F.dpf = '5_dpf';
D = F.load('data.mat');

btall  = [];
for i = 1:size(D.bout_direction,2)
    btall = [btall D.bout_direction{i}(:,1)'];
end
latall  = [];
for i = 1:size(D.latency_ms,2)
    latall = [latall D.latency_ms{i}];
end
latall(isnan(latall)==1) = [];
btall(isnan(btall)==1) = [];

lat1 = latall;
bt1 = btall;

nf = 0;
na = 0;
nt = 0;
for i = 1:size(xc,2)
%     f = find(lat1 <= xc(i)+ml/(2*ne));
    f = find(lat1 <= xc(i));
    % - forward
    pf = find(bt1(f)==0);
    nf = nf + size(pf,2);
    pforward(i) = size(pf,2);
    % - against
    pa = find(bt1(f)==-1);
    na = na + size(pa,2);
    pagainst(i) = size(pa,2);
    % - toward
    pt = find(bt1(f)==1);
    nt = nt + size(pt,2);
    ptoward(i) = size(pt,2);
    
    lat1(f) = [];
    bt1(f) = [];
end
% pforward = pforward/nf;
% pagainst = pagainst/na;
% ptoward = ptoward/nt;
% forward
plot(xc,pforward,'r')
title('PDF forward')

% - against
figure
plot(xc,pagainst,'r')
title('PDF against')
% - toward
figure
plot(xc,ptoward,'r')
title('PDF toward')


%% -- Spontaneous
Fs = Focus_spontaneous();
Fs.dpf = F.dpf;
Ds = Fs.load('data.mat');

btalls  = [];
for i = 1:size(Ds.first_bout_dir,2)
    btalls = [btalls Ds.first_bout_dir{i}];
end
latalls  = [];
for i = 1:size(Ds.latency_ms_spon,2)
    latalls = [latalls Ds.latency_ms_spon{i}];
end
latalls(isnan(latalls)==1) = [];
btalls(isnan(btalls)==1) = [];

lat1 = latalls;
bt1 = btalls;

nf = 0;
nt = 0;
for i = 1:size(xc,2)
%     f = find(lat1 <= xc(i)+ml/(2*ne));
    f = find(lat1 <= xc(i));
    % - forward
    pf = find(bt1(f)==0);
    nf = nf + size(pf,2);
    pforwards(i) = size(pf,2);
    % - turn
    pt = find(bt1(f)==1);
    nt = nt + size(pt,2);
    pturns(i) = size(pt,2);
    
    lat1(f) = [];
    bt1(f) = [];
end

pforwards = pforwards/nf;
pturns = pturns/nt;
forward
figure(1)
hold on
plot(xc,pforwards,'k')
% - turn
figure(2)
hold on
plot(xc,pturns,'k')
figure(3)
hold on
plot(xc,pturns,'k')


% difference
figure
plot(xc-ml/(2*ne),(pforward-pforwards)./pforwards)
hold on
plot(xlim,[0 0],'k')
figure
hold on
plot(xc-ml/(2*ne),(pagainst-pturns)./pturns)
plot(xlim,[0 0],'k')
figure
hold on
plot(xc-ml/(2*ne),(ptoward-pturns)./pturns)
plot(xlim,[0 0],'k')