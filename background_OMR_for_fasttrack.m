% day background for fasttrack

clc;
close all;
clear

a = exist('path','var');

if  a == 0
    disp('Select one frame for creating background file')
    [file, path] = uigetfile('*.pgm',[],'D:\free_swimming_fish\OMR_acoustic\');
    im = imread(fullfile(path,file));
end

return

T = adaptthresh(im,0.67);
imshow(T)
ROIdish = [(1280-1300)/2, (1024-1300)/2, 1300, 1300];
h = imellipse(gca, ROIdish);
maskbw = createMask(h);
maskbw = uint8(maskbw);

background = uint8(T*255).*maskbw;
imshow(background)

p = 'D:\OMR_acoustic_experiments\background_fasttrack';
im_name = ['background_',path(end-21:end-14),'.pgm'];

imwrite(background,fullfile(p,im_name));

close all
clear