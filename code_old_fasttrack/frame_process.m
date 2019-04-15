function im_bw = frame_process(im)

T = adaptthresh(im,0.67);
a = uint8(T*255)-im;
imshow(a);
b =imadjust(a);
ROIdish = [(1280-1300)/2, (1024-1300)/2, 1300, 1300];
h = imellipse(gca, ROIdish);
maskbw = createMask(h);
maskbw = uint8(maskbw);
imc = b.*maskbw;
ima = bwareaopen(imc, 60,4);
se = strel('square',2);
im_bw = imdilate(ima,se);