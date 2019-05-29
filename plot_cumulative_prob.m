% plot cumulative probability OMR latency (ie first bout)


F = Focus_OMR();
F.dpf = '5_dpf';
F.cycle = '10_mm';
F.speed = '20_mm_s';

D = F.load('data_latency');
bout_dir = D.bout_direction;

%% -- Plot orientation first bout with forward bout
figure
a = size(bout_dir,2);
b = 0;
for i = 1:a
    b1 = size(bout_dir{i},2);
    if b1>b
        b = b1;
    end
end

% a: number of run - i, line
% b: number of bout - j, column

m = nan(a,b);
for i = 1:a
    bd = bout_dir{i};
    b1 = size(bd,2);
    for j = 1:b1
        m(i,j) = mean(bd(:,j),'omitnan');
    end
end

mm = mean(m,1,'omitnan');
s = nan(1,b);
p = s;
for j = 1:b
    if isnan(mm(j))==0
        n = size(find(isnan(m(:,j))==0)',2);
        s(j) = std(m(:,1),1,'omitnan')/sqrt(n);
        [~,p(j)] = ttest(m(:,j));
        if p(j) < 0.001
            text(j,mm(j)+s(j)+0.02,'***','FontSize',14,'HorizontalAlignment','center')
        elseif p(j) < 0.01
            text(j,mm(j)+s(j)+0.02,'**','FontSize',14,'HorizontalAlignment','center')
        elseif p(j) < 0.05
            text(j,mm(j)+s(j)+0.02,'*','FontSize',14,'HorizontalAlignment','center')
        end
    end
end
hold on
plot(mm,'-bo')
errorbar(mm,s,'b')
xlim([0 12])
plot(xlim,[0 0],'k')
title({F.dpf 'with forward bout'})
ylim([-0.3 0.3])

return


%% -- Plot orientation first bout without forward bout
figure
a = size(bout_dir,2);
b = 0;
for i = 1:a
    b1 = size(bout_dir{i},2);
    if b1>b
        b = b1;
    end
end

% a: number of run - i, line
% b: number of bout - j, column

m = nan(a,b);
for i = 1:a
    bd = bout_dir{i};
    b1 = size(bd,2);
    for j = 1:b1
        c = bd(:,j);
        c(c==0) = [];
        m(i,j) = mean(c,'omitnan');
    end
end

mm = mean(m,1,'omitnan');
s = nan(1,b);
p = s;
for j = 1:b
    if isnan(mm(j))==0
        n = size(find(isnan(m(:,j))==0)',2);
        s(j) = std(m(:,1),1,'omitnan')/sqrt(n);
        [~,p(j)] = ttest(m(:,j));
        if p(j) < 0.001
            text(j,mm(j)+s(j)+0.02,'***','FontSize',14,'HorizontalAlignment','center')
        elseif p(j) < 0.01
            text(j,mm(j)+s(j)+0.02,'**','FontSize',14,'HorizontalAlignment','center')
        elseif p(j) < 0.05
            text(j,mm(j)+s(j)+0.02,'*','FontSize',14,'HorizontalAlignment','center')
        end
    end
end
hold on
plot(mm,'-bo')
errorbar(mm,s,'b')
xlim([0 12])
plot(xlim,[0 0],'k')
title({F.dpf 'without forward bout'})