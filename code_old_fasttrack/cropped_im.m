function [im_bw] = cropped_im(xc,yc,w,h,im)


lmin = round(yc)-round(h/2);
if lmin <= 0
    lmin = 1;
end
lmax = round(yc)+round(h/2);
if lmax > size(im,1)
    lmax = size(im,1);
end
cmin = round(xc)-round(w/2);
if cmin <= 0
    cmin = 1;
end
cmax = round(xc)+round(w/2);
if cmax > size(im,2)
    cmax = size(im,2);
end

im_bw = im(lmin:lmax,cmin:cmax);