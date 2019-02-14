% convert movie into binarize movie (0-255)
clear;
clc;

disp('Select the first frame');
[file,path] = uigetfile('*.pgm',[],'C:\Users\LJP\Documents\MATLAB\these\data_OMR\');
n = input('Number of frame to open? ');
im = imread(fullfile(path,file));
movie = zeros(size(im,1),size(im,2));

imshow(movie);

mkdir(path(1:end-6),'movie_bin');
a = fullfile(path(1:end-6),'movie_bin');
im_name = 'movie_bin_0000.tif';
imwrite(movie,fullfile(a,im_name));

w = waitbar(0,'Conversion');

tic
for i = 1:n
    im = frame_open(file,path,i);
    movie = uint8(frame_process(im)*255);
    
    c = floor(i/100);
    d = floor((i-c*100)/10);
    u = floor(i-c*100-d*10);
    s = size(im_name,2);
    im_name(s-6) = num2str(c);
    im_name(s-5) = num2str(d);
    im_name(s-4) = num2str(u);
    imwrite(movie,fullfile(a,im_name));
    
    waitbar(i/n,w);
end
close(w);
toc