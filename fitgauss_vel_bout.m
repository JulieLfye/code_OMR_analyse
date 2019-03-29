function [f,x,y, corr] = fitgauss_vel_bout(prewindow, postwindow, Indpeak, Indpeakvel, i, boutind, velocity, im)

% boutind = indbout;
% Indpeak = peakIndsvel1;
% velocity = vel;
% Indpeakvel = peakIndsvel;


gaussEqn = 'a*exp(-(x-mu)^2/(2*sig^2))';

prebout = Indpeak(i) - prewindow : Indpeak(i) - 1;
if i==1
    prebout(prebout<=0) = [];
else
    prebout(prebout<boutind(2,i-1)) = [];
end
postbout = Indpeak(i) + 1 : Indpeak(i) + postwindow - 1;
if i == size(Indpeak,2)
    a = find(Indpeakvel>Indpeak(i),1);
    if isempty(a) == 1
    postbout(postbout>=size(velocity,2)) = [];
    else
        postbout(postbout>=Indpeakvel(a)-10) = [];
    end
else
    postbout(postbout>=Indpeak(i+1)-15) = [];
end

x = prebout(1):1:postbout(end);
y = velocity(x);
startPoints = [max(y) Indpeak(i) 1];
f = fit(x',y',gaussEqn,'Start', startPoints);
fitcurve = f.a*exp(-(x-f.mu).^2/(2*f.sig^2));
corr = min(corrcoef(y,fitcurve),[],1);
corr = corr(1);

if im == 1
    figure
    plot(x,y)
    hold on
    plot(f,x,y)
    xli = xlim;
    yli = ylim;
    text((xli(2)-xli(1)+1)*0.98 + xli(1),yli(2)*0.70, ['bout = ' num2str(6*f.sig/150*1000,3) 'ms'], 'HorizontalAlignment', 'right')
    text((xli(2)-xli(1)+1)*0.98 + xli(1),yli(2)*0.65, ['corr = ' num2str(corr,3)], 'HorizontalAlignment', 'right')
end