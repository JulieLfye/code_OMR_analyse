% code test

ff = find(isnan(seq(1,:))==1);
bout_indexes = [];
nb_bout = [];
IBI = [];
fps = 150;
for f = 1:nb_detected_object
    if f == 1
        ind_seq = seq(:,1:ff(f)-1);
    else
        ind_seq = seq(:,ff(f-1)+1:ff(f)-1);
    end
    
    while isempty(ind_seq) == 0
        cx = xbody(f,ind_seq(1,1):ind_seq(2,1));
        cy = ybody(f,ind_seq(1,1):ind_seq(2,1));
        
        % determine IBI with x, y (I don't use the angle)
        [boutind, minh, nbouts] = BoutSpot_julie(cx, cy, fps, 0);
        bout_indexes = [bout_indexes, boutind, nan];
        nb_bout = [nb_bout, nbouts, nan];
        IBI = [IBI, diff(boutind)/fps, nan];
        
        ind_seq(:,1) = [];
    end
end


figure,
[counts,centers] = hist(IBI,50);
bar(centers,counts/sum(nb_bout,'omitnan'),1)
mIBI = mean(IBI,'omitnan');
hold on
med = median(IBI,'omitnan');
me = mean(IBI,'omitnan');
plot([med med], ylim, 'k', 'LineWidth', 2)
plot([me me], ylim, 'r', 'LineWidth', 2)
xli = xlim;
xlim([0 xli(2)])
xli = xlim;
yli = ylim;
text(xli(2)*0.7, yli(2)*0.9, ['mean = ' num2str(me,'%#5.2f') ' sec'])
text(xli(2)*0.7, yli(2)*0.8, ['median = ' num2str(med,'%#5.2f') ' sec'])