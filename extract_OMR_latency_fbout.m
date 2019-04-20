function [fbout, fish_to_consider] = extract_OMR_latency_fbout(xbody,indbout,fps)

fish_to_consider = find(isnan(xbody(:,130)) == 0)';
fbout = nan(size(fish_to_consider));

i = 1;
for i = 1:size(fish_to_consider,2)
    f = fish_to_consider(i);
    if sum(sum(indbout{f}(:,:))) ~= 0
        % determine first bout after OMR beginning
        a = find(indbout{f}(1,:) > 150,1);
        if isempty(a) == 0
            fbout(i) = (indbout{f}(1,a) - 150)/fps;
        end
    end
end