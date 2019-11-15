clc;
close all;
clear

a = exist('path','var');

if  a == 0
    disp('Select one frame for creating background file')
    [file, path] = uigetfile('*.pgm',[],'D:\embedded_fish\');
    im = imread(fullfile(path,file));
end

T = adaptthresh(im,0.6);
imshow(T)
background = uint8(T*255);
imshow(background)
d = background-im;
imshow(d)

p = 'D:\embedded_fish\OKR_acoustic\background';
p = [p, path(end-30:end-22)];

if isfolder(p) == 0
    mkdir(p)
end

im_name = ['background_',path(end-20:end-14),'.pgm'];

imwrite(background,fullfile(p,im_name));

close all
clear