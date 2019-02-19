function [seq, xbody, ybody, ang_body] = extract_sequence(nb_detected_object,...
    xbody, ybody, ang_body)

seq = [];
nb_seq_object = zeros(1,nb_detected_object);
for f = 1:nb_detected_object
    cx = xbody(f,:); 
    cy = ybody(f,:);  
    ca = ang_body(f,:);
    
    fxy = find(isnan(cx)==0);
    d = diff(fxy);
    ff = find(d > 1);
    
    ind_seq = nan(2,size(ff,2)+1);
    if isempty(ff) == 0
        for i = 1:size(ff,2)+1
            % group of nan index
            if i == 1
                gp = unique(fxy(1:ff(1)));
            elseif i == size(ff,2)+1
                gp = unique(fxy(ff(i-1)+1:end));
            else
                gp = fxy(ff(i-1)+1:ff(i));
            end
            ind_seq(:,i) = [min(gp); max(gp)];
        end
    else
        ind_seq = [min(fxy); max(fxy)];
    end
    
    % study x and y discontinuity for each sequence
    deb = size(seq,2);
    start_seq = ind_seq(1,1);
    if size(ind_seq,2) == 1
        seq = [seq, [start_seq; ind_seq(2,end)]];
        nb_seq_object(1,f) = nb_seq_object(1,f) + 1;
    else
        
        for i = 1:size(ind_seq,2) - 1
            dcx = abs(cx(ind_seq(1,i+1))-cx(ind_seq(2,i)));
            dcy = abs(cy(ind_seq(1,i+1))-cy(ind_seq(2,i)));
            if dcx > 50 || dcy > 50
                seq = [seq, [start_seq; ind_seq(2,i)]];
                start_seq = ind_seq(1,i+1);
                nb_seq_object(1,f) = nb_seq_object(1,f) + 1;
            end
            if i == size(ind_seq,2) - 1
                seq = [seq, [start_seq; ind_seq(2,end)]];
                nb_seq_object(1,f) = nb_seq_object(1,f) + 1;
            end      
        end
    end
    
    seq = [seq, [nan; nan]];
    
    % correct nan value into sequence
    for i = 1:nb_seq_object(1,f)
        ft = find(isnan(cx(seq(1,i+deb):seq(2,i+deb)))==1)+seq(1,i+deb)-1;
        while isempty(ft) == 0
            cx(1,ft(1)) = cx(1,ft(1)-1);
            cy(1,ft(1)) = cy(1,ft(1)-1);
            ca(1,ft(1)) = ca(1,ft(1)-1);
            ft(1) = [];
        end
    end
    xbody(f,:) = cx;
    ybody(f,:) = cy;
    ang_body(f,:) = ca;
end