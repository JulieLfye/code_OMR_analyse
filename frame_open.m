function [path, file] = frame_open(file,path,im_nb)

im_nb = im_nb-1;
m = floor(im_nb/1000);
c = floor((im_nb-m*1000)/100);
d = floor((im_nb-m*1000-c*100)/10);
u = floor(im_nb-m*1000-c*100-d*10);
s = size(file,2);
file(s-7) = num2str(m);
file(s-6) = num2str(c);
file(s-5) = num2str(d);
file(s-4) = num2str(u);
