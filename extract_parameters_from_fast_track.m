function [nb_frame, nb_detected_object, xbody, ybody, ang_body, ang_tail]...
    = extract_parameters_from_fast_track(s)

% determine number of tracked object
nb_detected_object = max(s(:,end))+1;

% determine number of frame
nb_frame = max(s(:,end-1))+1;

% extract parameters of interest
xbody = nan(nb_detected_object,nb_frame);
ybody = xbody;
ang_body = xbody;
ang_tail = xbody;

i = 1;
for i = 1:nb_frame
    f = find(s(:,end-1) == i-1);
    fi = s(f,end)+1;
    xbody(fi,i) = s(f,7);
    ybody(fi,i) = s(f,8);
    ang_body(fi,i) = s(f,9);
    ang_tail(fi,i) = s(f,6);
end