% test 2

% je dois couper les séquences en fonction de si fasttrack réassigne un
% numéro de poisson déjà assigner avant
% Mais je dois faire attention si un poisson "clignote"

% poisson qui clignote

% clearvars -except xbody ybody file path
close all
clc

f = 1 + 0;

cx = xbody(f,:);
cy = ybody(f,:);
plot(cx)
hold on
plot(cy)


fxy = find(isnan(cx)==0);
d = diff(fxy);
ff = find(d > 1);

gp_before = [];
ind_seq = nan(2,size(ff,2)+1);

for i = 1:size(ff,2)+1
    % group of nan index
    if i == 1
        gp = unique(fxy(1:ff(1)));
    elseif i == size(ff,2)+1
        gp = unique(fxy(ff(i-1)+1:end));
    else
        gp = fxy(ff(i-1)+1:ff(i));
    end
    ind_seq(:,i) = [min(gp); max(gp)];
end

% study x and y discontinuity for each sequence
seq = [];
start_seq = ind_seq(1,1);
for i = 1:size(ind_seq,2) - 1
    dcx = abs(cx(ind_seq(1,i+1))-cx(ind_seq(2,i)));
    dcy = abs(cy(ind_seq(1,i+1))-cy(ind_seq(2,i)));
    if dcx > 50 || dcy > 50
        seq = [seq, [start_seq; ind_seq(2,i)]];
        start_seq = ind_seq(1,i+1);
    end
    if i == size(ind_seq,2) - 1
        seq = [seq, [start_seq; ind_seq(2,end)]];
    end
end

% correct nan value into sequence
fx = cx-100;
fy = cy-100;
for i = 1:size(seq,2)
    f = find(isnan(cx(seq(1,i):seq(2,i)))==1)+seq(1,i)-1;
    while isempty(f) == 0
        fx(1,f(1)) = fx(1,f(1)-1);
        fy(1,f(1)) = fy(1,f(1)-1);
        f(1) = [];
    end
end

plot(fx)
plot(fy)