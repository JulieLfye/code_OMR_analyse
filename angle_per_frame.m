function angle= angle_per_frame(d)

%% Comments
% Input -----
% d is the difference between the angle(i+1) and angle(i)
% d = angle(i+1)-angle(i);

% Output -----
% angle: difference between angle(i+1) ang angle(i) without the 0/360 edge
% most of the time, in the main code, you have to do:
% d = angle_real(i+1)-angle_real(i);
% angle_without_edge(i+1) = angle_real(i) + angle_per_frame(d); 

%% Function
if d >= 0 && d < 180
    angle = d;
    
elseif d >= 180
    angle = -(360-d);
    
elseif d < 0 && d > -180
    angle = d;
    
elseif d <= -180
    angle = mod(d,360);
    
end

