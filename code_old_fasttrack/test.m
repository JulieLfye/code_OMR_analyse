a = dir('D:\embedded_fish\OKR_acoustic\OKR_fixed\OKR_acoustic\19-11-06\fish_01\run_01\movie');
path = 'D:\embedded_fish\OKR_acoustic\OKR_fixed\OKR_acoustic\19-11-06\fish_01\run_01\movie';
mkdir(path(1:end-6),'movie_filt');

im_name = 'movie_0000.tif';
tic
for i = 1:size(a,1)-2
    im = imread(fullfile(a(1,1).folder,a(2+i,1).name));
    movie = imnlmfilt(im);
    m = floor((i-1)/1000);
    c = floor(((i-1)-m*1000)/100);
    d = floor(((i-1)-m*1000-c*100)/10);
    u = floor((i-1)-m*1000-c*100-d*10);
    s = size(im_name,2);
    im_name(s-7) = num2str(m);
    im_name(s-6) = num2str(c);
    im_name(s-5) = num2str(d);
    im_name(s-4) = num2str(u);
    imwrite(movie,fullfile(path(1:end-6),'movie_filt',im_name));
end
toc
close all