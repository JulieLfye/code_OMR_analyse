%% convert movie into binarize movie (0-255)
% by folder

clear;
clc;
close all;

nb = [nan, nan];
no_movie = [];
movie_bin = [];

disp('Select the folder with the movie to analyze');
selpath = uigetdir('C:\Users\LJP\Documents\MATLAB\these\');
disp('Movie to analyse?');
nb(1,1) = input('from ??     ');
nb(1,2) = input('to ??       ');


tic
for k = nb(1,1):nb(1,2)
    
    d = floor(k/10);
    u = floor(k-d*10);
    run = ['run_', num2str(d), num2str(u)];
    path = fullfile(selpath,run);
    
    if isfolder(fullfile(path, 'movie')) == 1
        if isfolder(fullfile(path, 'movie_bin')) == 0
            
            path = fullfile(path,'movie');
            l = dir(path);
            file = l(3).name;
            
            im = imread(fullfile(path,file));
            movie = zeros(size(im,1),size(im,2));
            
            imshow(movie);
            
            mkdir(path(1:end-6),'movie_bin');
            a = fullfile(path(1:end-6),'movie_bin');
            im_name = 'movie_bin_0000.tif';
            imwrite(movie,fullfile(a,im_name));
            
            w = waitbar(0,sprintf('Conversion, movie %d / %d', k-nb(1,1)+1, nb(1,2)-nb(1,1)+1));
            b = l(end).name;
            n = b(end-7:end-4);
            n = str2num(n);
            
            for j = 1:n+1
                [p, f] = frame_open(file,path,j);
                im = imread(fullfile(p,f));
                movie = uint8(frame_process(im)*255);
                
                m = floor(j/1000);
                c = floor((j-m*1000)/100);
                d = floor((j-m*1000-c*100)/10);
                u = floor(j-m*1000-c*100-d*10);
                s = size(im_name,2);
                im_name(s-7) = num2str(m);
                im_name(s-6) = num2str(c);
                im_name(s-5) = num2str(d);
                im_name(s-4) = num2str(u);
                imwrite(movie,fullfile(a,im_name));
                delete(fullfile(p,f));
                waitbar(j/n,w); 
            end
            
            
            close(w);
            close all
            rmdir(p)
            
        else
            movie_bin = [movie_bin k];
        end
        
    else
        no_movie = [no_movie k];
    end
end
toc