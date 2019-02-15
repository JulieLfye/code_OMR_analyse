function [lum_sin] = luminosity_sinus(percPm)

load ('F:\Projects\Julie\code\illumination\op_lum_08112017.mat')
Pm = max(lum_op_for_interpolation(:,2));
ang = linspace(0,180,181);

lum_sin(:,1) = ang;

lum_sin(:,2) = percPm*Pm*sin(ang/180*pi/2);
lum_sin(:,3) = interp1(lum_op_for_interpolation(:,2),lum_op_for_interpolation(:,1),lum_sin(:,2));

%plot(lum_sin(:,1),lum_sin(:,2))