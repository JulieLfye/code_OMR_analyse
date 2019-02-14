function [nb_frame, nb_detected_object, xbody, ybody]...
    = extract_parameters_from_fast_track(s)

% determine number of frame
nb_frame = max(s(:,end));

% determine number of detected object
nb_detected_object = 0;
for i = 1:nb_frame
    f = 1;
    nb = 0;
    
    while f <= nb_tracked_object
        if isnan(s(i*nb_tracked_object + f,1)) == 0
            nb = nb + 1;
            f = f + 1;
        else
            f = f + 1;
        end
    end
    if nb > nb_detected_object
        nb_detected_object = nb;
    end
end

% extract parameters of interest
for f = 1:nb_detected_object
    for i = 1:nb_frame
        xbody(f,i) = s(i*nb_tracked_object + f, 7);
        ybody(f,i) = s(i*nb_tracked_object + f, 8);
    end
end