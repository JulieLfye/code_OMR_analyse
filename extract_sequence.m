function [seq, xbody, ybody, ang_body, ang_tail] = extract_sequence(nb_detected_object,...
    xbody, ybody, ang_body,ang_tail, fps)

seq = cell(1,nb_detected_object);

f = 10;
for f = 1:nb_detected_object
    
    cx = xbody(f,:);
    cy = ybody(f,:);
    ca = ang_body(f,:);
    cat = ang_tail(f,:);
    
    fa = find(isnan(xbody(f,:))==0);
    if isempty(fa) == 0
        
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
        start_seq = ind_seq(1,1);
        if size(ind_seq,2) == 1
            s = ind_seq(2,1) - start_seq;
            if s >= 0.2*fps
                seq{f} = [start_seq; ind_seq(2,1)];
            end
            
        else
            for i = 1:size(ind_seq,2) - 1
                dcx = abs(cx(ind_seq(1,i+1))-cx(ind_seq(2,i)));
                dcy = abs(cy(ind_seq(1,i+1))-cy(ind_seq(2,i)));
                if dcx > 50 || dcy > 50
                    s = ind_seq(2,i) - start_seq;
                    if s >= 0.2*fps
                        seq{f} = [start_seq; ind_seq(2,i)];
                        start_seq = ind_seq(1,i+1);
                    else
                        start_seq = ind_seq(1,i+1);
                    end
                end
                if i == size(ind_seq,2) - 1
                    s = ind_seq(2,end) - start_seq;
                    if s >= 0.2*fps
                        seq{f} = [start_seq; ind_seq(2,end)];
                    end
                end
            end
        end
        
        % correct nan value into sequence
        for i = 1:size(seq{f}(:,:),2)
            ft = find(isnan(cx(seq{f}(1,i):seq{f}(2,i)))==1)+seq{f}(1,i)-1;
            while isempty(ft) == 0
                cx(1,ft(1)) = cx(1,ft(1)-1);
                cy(1,ft(1)) = cy(1,ft(1)-1);
                ca(1,ft(1)) = ca(1,ft(1)-1);
                cat(1,ft(1)) = cat(1,ft(1)-1);
                ft(1) = [];
            end
        end
        xbody(f,:) = cx;
        ybody(f,:) = cy;
        ang_body(f,:) = ca;
        ang_tail(f,:) = cat;
    end
end