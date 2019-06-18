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
xc = [0.75 1.5];
F.dpf = '6_dpf';


%% -- Spontaneous
Fs = Focus_spontaneous();
Fs.dpf = F.dpf;
Ds = Fs.load('data.mat');


nf = nan(size(Ds.first_bout_dir));
nt = nf;
ns = nf;
pforwards = nan(size(Ds.first_bout_dir,2),size(xc,2));
pturns = pforwards;
for i = 1:size(Ds.first_bout_dir,2)
    bts  = Ds.first_bout_dir{i};
    bts = reshape(bts,1,[]);
    bts(isnan(bts)==1) = [];
    lats  = Ds.latency_ms_spon{i};
    lats = reshape(lats,1,[]);
    lats(isnan(lats)==1) = [];
    ns(i) = size(lats,2);
    
    bts1 = bts;
    lats1 = lats;
    
    for j = 1:size(xc,2)
        f = find(lats1 <= xc(j));
        % find forward bout
        pf = find(bts1(f)==0);
        pforwards(i,j) = size(pf,2);
        % find turn bout
        pt = find(bts1(f)==1);
        pturns(i,j) = size(pt,2);
        lats1(f) = [];
        bts1(f) = [];
    end
end
    



return 

lat1 = lats;
bt1 = bt;

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