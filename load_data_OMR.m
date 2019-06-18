% load data

F = Focus_OMR();
F.cycle = '10_mm';
F.speed = '20_mm_s';
F.dpf = '5_dpf';
Do = F.load('data.mat');

lato = [];
for i = 1:size(Do.latency_ms,2)
    lato = [lato Do.latency_ms{i}];
end
lato = [];
for i = 1:size(Do.latency_ms,2)
    lato = [lato Do.latency_ms{i}];
end

lato(isnan(latOMR)==1) = [];

t = 500; % ms

a = find(latOMR < 500);
