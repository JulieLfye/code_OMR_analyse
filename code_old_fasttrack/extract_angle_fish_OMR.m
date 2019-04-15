function [ang_body] = extract_angle_fish_OMR(nb_detected_object, nb_frame, w, h,...
    xbody, ybody, file, path, fig,k ,nb)

wb = waitbar(0,sprintf('Extract angle, movie %d / %d', k, nb));
ang_body = nan(nb_detected_object,nb_frame);
for f = 1:nb_detected_object
    for i = 1:nb_frame
        wa = w;
        ha = h;
        if isnan(xbody(f,i)) == 0
            [p,fi] = frame_open(file,path,i+1);
            im = imread(fullfile(p,fi));
            [im_bw] = cropped_im(xbody(f,i),ybody(f,i),wa,ha,im);
            se = strel('square',2);
            im_bw = imdilate(im_bw,se);
            [~,n] = bwlabel(im_bw);
            if n ~= 0
                while n > 1 && wa >= 0 && ha >=0
                    wa = wa - 10;
                    ha = ha - 10;
                    [im_bw] = cropped_im(xbody(f,i),ybody(f,i),wa,ha,im);
                    se = strel('square',2);
                    im_bw = imdilate(im_bw,se);
                    [~,n] = bwlabel(im_bw);
                end
                [~,~,ang] = get_orientation_distmap(im_bw);
                ang_body(f,i) = ang*pi/180; 
            end
        end
        waitbar((((f-1)*nb_frame)+i)/(nb_detected_object*nb_frame),wb);
    end
    if fig ==1
        hold on
        plot(ang_body(f,:));
    end
end

close(wb);