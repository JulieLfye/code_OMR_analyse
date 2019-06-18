% test forward

% test
% plot bout direction in function of 1st OMR latency

clear;
close all;
clc;

F = Focus_OMR();
F.cycle = '10_mm';
F.speed = '20_mm_s';
ml = 2.1;
ne = ml*1/0.1;
xc = linspace(ml/ne,ml,ne)-ml/(2*ne);
pagainst = nan(3,size(xc,2));
pforward = pagainst;
ptoward = pagainst;
m = pagainst;
m2 = m;
nf = zeros(3,4);

for j = 1:3
    if j==1
        F.dpf = '5_dpf';
        D5 = F.load('data.mat');
        nf(j,4) = sum(D5.n_fish);
        
        btall5  = [];
        for i = 1:size(D5.bout_direction,2)
            btall5 = [btall5 D5.bout_direction{i}(:,1)'];
        end
        latall5  = [];
        for i = 1:size(D5.latency_ms,2)
            latall5 = [latall5 D5.latency_ms{i}];
        end
        latall5(isnan(latall5)==1) = [];
        btall5(isnan(btall5)==1) = [];
        
        lat1 = latall5;
        bt1 = btall5;
        
        for i = 1:ne
            f = find(lat1 <= xc(i)+ml/(2*ne));
            m(j,i) = mean(bt1(f));
            p1 = find(bt1(f)==-1);
            nf(j,1) = nf(j,1) + size(p1,2);
            pagainst(j,i) = size(p1,2)/size(f,2);
            p2 = find(bt1(f)==0);
            nf(j,2) = nf(j,2) + size(p2,2);
            pforward(j,i) = size(p2,2)/size(f,2);
            p3 = find(bt1(f)==1);
            nf(j,3) = nf(j,3) + size(p3,2);
            ptoward(j,i) = size(p3,2)/size(f,2);
            m2(j,i) = mean([bt1(f(p1)) bt1(f(p3))]);
            lat1(f) = [];
            bt1(f) = [];
        end
    elseif j == 2
        F.dpf = '6_dpf';
        D6 = F.load('data.mat');
        nf(j,4) = sum(D6.n_fish);
        
        btall6  = [];
        for i = 1:size(D6.bout_direction,2)
            btall6 = [btall6 D6.bout_direction{i}(:,1)'];
        end
        latall6  = [];
        for i = 1:size(D6.latency_ms,2)
            latall6 = [latall6 D6.latency_ms{i}];
        end
        latall6(isnan(latall6)==1) = [];
        btall6(isnan(btall6)==1) = [];
        
        lat1 = latall6;
        bt1 = btall6;
        for i = 1:ne
            f = find(lat1 <= xc(i)+ml/(2*ne));
            m(j,i) = mean(bt1(f));
            p1 = find(bt1(f)==-1);
            nf(j,1) = nf(j,1) + size(p1,2);
            pagainst(j,i) = size(p1,2)/size(f,2);
            p2 = find(bt1(f)==0);
            nf(j,2) = nf(j,2) + size(p2,2);
            pforward(j,i) = size(p2,2)/size(f,2);
            p3 = find(bt1(f)==1);
            nf(j,3) = nf(j,3) + size(p3,2);
            ptoward(j,i) = size(p3,2)/size(f,2);
            m2(j,i) = mean([bt1(f(p1)) bt1(f(p3))]);
            lat1(f) = [];
            bt1(f) = [];
        end
    elseif j == 3
        F.dpf = '7_dpf';
        D7 = F.load('data.mat');
        nf(j,4) = sum(D7.n_fish);
        
        btall7  = [];
        for i = 1:size(D7.bout_direction,2)
            btall7 = [btall7 D7.bout_direction{i}(:,1)'];
        end
        latall7  = [];
        for i = 1:size(D7.latency_ms,2)
            latall7 = [latall7 D7.latency_ms{i}];
        end
        latall7(isnan(latall7)==1) = [];
        btall7(isnan(btall7)==1) = [];
        
        lat1 = latall7;
        bt1 = btall7;
        
        for i = 1:ne
            f = find(lat1 <= xc(i)+ml/(2*ne));
            m(j,i) = mean(bt1(f));
            p1 = find(bt1(f)==-1);
            nf(j,1) = nf(j,1) + size(p1,2);
            pagainst(j,i) = size(p1,2)/size(f,2);
            p2 = find(bt1(f)==0);
            nf(j,2) = nf(j,2) + size(p2,2);
            pforward(j,i) = size(p2,2)/size(f,2);
            p3 = find(bt1(f)==1);
            nf(j,3) = nf(j,3) + size(p3,2);
            ptoward(j,i) = size(p3,2)/size(f,2);
            m2(j,i) = mean([bt1(f(p1)) bt1(f(p3))]);
            lat1(f) = [];
            bt1(f) = [];
        end
    end
end


for i = 1:3
    if i == 1
        color = 'k';
    elseif i ==2
        color = 'r';
    elseif i == 3
        color = 'b';
    end
    figure(1)
    hold on
    plot(xc,pagainst(i,:),color)
    
    figure(2)
    hold on
    plot(xc,pforward(i,:),color)
    
    figure(3)
    hold on
    plot(xc,ptoward(i,:),color)
    
    figure(4)
    hold on
    plot(xc,m(i,:),color)
    
    figure(5)
    hold on
    plot(xc,m2(i,:),color)
    
    if i==3
        figure(1)
        hold on
        plot(xc,mean(pagainst,'omitnan'),'g','Linewidth',2)
        xlim([0 ml+0.1])
        ylim([0 1])
        title('proba against')
        
        figure(2)
        hold on
        xlim([0 ml+0.1])
        ylim([0 1])
        plot(xc,mean(pforward,'omitnan'),'g','Linewidth',2)
        title('proba forward')
        
        figure(3)
        hold on
        xlim([0 ml+0.1])
        ylim([0 1])
        plot(xc,mean(ptoward,'omitnan'),'g','Linewidth',2)
        title('proba toward')
        
        figure(4)
        hold on
        xlim([0 ml+0.1])
        ylim([-1 1])
        plot(xc,mean(m,'omitnan'),'g','Linewidth',2)
        plot(xlim,[0 0],'k')
        title('proba mean')
        
        figure(5)
        hold on
        xlim([0 ml+0.1])
        ylim([-1 1])
        plot(xc,mean(m2,'omitnan'),'g','Linewidth',2)
        plot(xlim,[0 0],'k')
        title('proba mean no forward')
    end
end

for i = 1:3
    figure(i)
    hold on
    text(max(xlim)*0.8,max(ylim)*0.95,['5 dpf n = ' num2str(nf(1,i))],'Color','k')
    text(max(xlim)*0.8,max(ylim)*0.85,['6 dpf n = ' num2str(nf(2,i))],'Color','r')
    text(max(xlim)*0.8,max(ylim)*0.75,['7 dpf n = ' num2str(nf(3,i))],'Color','b')
    xlabel('First bout latency (s)')
    ylabel('Probabilities')
end
figure(4)
hold on
text(max(xlim)*0.7,max(ylim)*0.95,['5 dpf n = ' num2str(sum(nf(1,1:3))) '/' num2str(nf(1,4))],'Color','k')
text(max(xlim)*0.7,max(ylim)*0.85,['6 dpf n = ' num2str(sum(nf(2,1:3))) '/' num2str(nf(2,4))],'Color','r')
text(max(xlim)*0.7,max(ylim)*0.75,['7 dpf n = ' num2str(sum(nf(3,1:3))) '/' num2str(nf(3,4))],'Color','b')
xlabel('First bout latency (s)')
ylabel('Against OMR - Toward OMR')

figure(5)
hold on
text(max(xlim)*0.7,max(ylim)*0.95,['5 dpf n = ' num2str(nf(1,1)+nf(1,3)) '/' num2str(nf(1,4))],'Color','k')
text(max(xlim)*0.7,max(ylim)*0.85,['6 dpf n = ' num2str(nf(2,1)+nf(2,3)) '/' num2str(nf(2,4))],'Color','r')
text(max(xlim)*0.7,max(ylim)*0.75,['7 dpf n = ' num2str(nf(3,1)+nf(3,3)) '/' num2str(nf(3,4))],'Color','b')
xlabel('First bout latency (s)')
ylabel('Against OMR - Toward OMR')

% figure
% hold on
% plot(xc,mean(pagainst,'omitnan'),'r')
% plot(xc,mean(pforward,'omitnan'),'k')
% plot(xc,mean(ptoward,'omitnan'),'b')