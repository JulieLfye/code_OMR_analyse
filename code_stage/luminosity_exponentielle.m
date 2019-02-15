function [lum_exp,theta0]=luminosity_exponentielle(percPm)

theta = linspace(0,5);
i=1;
lum5 = 1;
load ('F:\Projects\Julie\code\illumination\op_lum_08112017.mat')
Pm = max(lum_op_for_interpolation(:,2));
ang = linspace(0,180,181);
while lum5 > 0.02*Pm
    i=i+1;
    lum5 = (exp(5/180*theta(i))*exp(-theta(i))*Pm*percPm);
end
theta0 = theta(i);

lum_exp(:,1) = ang;
lum_exp(:,2) = (exp(ang/180*theta0)*exp(-theta0)*Pm*percPm);
for i = 1:5
    lum_exp(i,2) = (i-1)*lum_exp(6,2)/5;
end
lum_exp(:,3) = interp1(lum_op_for_interpolation(:,2),lum_op_for_interpolation(:,1),lum_exp(:,2));

% plot(lum_op_for_interpolation(:,1),lum_op_for_interpolation(:,2),'k')
% hold on
% plot(lum_exp(:,3),lum_exp(:,2),'r')

% figure
% percPm = linspace(0.02,1);
% for i = 2:100
%     j=1;
%     lum5(i)=1;
%     while lum5(i) > 0.02*Pm
%         j=j+1;
%         lum5(i) = (exp(5/180*theta(j))*exp(-theta(j))*Pm*percPm(i));
%     end
%     
% end
% plot(percPm(1:100),lum5)