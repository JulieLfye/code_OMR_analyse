% ----- Analysis of the recording and lost sequence ----

clearvars -except D
close all


framerate = D.experiment.framerate;
framerate(:,1:2) = framerate(:,1:2)/60;
timeLost = D.experiment.timeLost;
timeLost = timeLost/60;

xlim([0 D.experiment.timeth/60])
for i = 1:size(framerate,1)
    plot(framerate(i,1:2),[1 1],'r','LineWidth',20)
    hold on
end
for i = 1:size(timeLost,1)
    plot(timeLost(i,1:2),[1 1],'k','LineWidth',20)
end

% ----- time lost analysis -----
% remove empty sequence
seq_remove = [];
for seq = 1:size(timeLost,1)
    a = sum(timeLost(seq,:));
    if a == 0
        seq_remove = [seq_remove seq];
    end
end
timeLost(seq_remove,:) = [];

analysis_timeLost(1) = size(timeLost,1);
analysis_timeLost(2) = round(100*mean(timeLost(:,3)))/100;
analysis_timeLost(3) = round(100*std(timeLost(:,3)))/100;
analysis_timeLost(4) = round(100*max(timeLost(:,3)))/100;
analysis_timeLost(5) = round(min(timeLost(:,3)))*60;
analysis_timeLost = analysis_timeLost';

% ----- recording time analysis -----
% remove empty sequence
seq_remove = [];
for seq = 1:size(framerate,1)
    a = sum(framerate(seq,:));
    if a == 0
        seq_remove = [seq_remove seq];
    end
end
framerate(seq_remove,:) = [];
t = framerate(:,2) - framerate(:,1);
analysis_recording(1) = size(framerate,1);
analysis_recording(2) = round(100*mean(t))/100;
analysis_recording(3) = round(100*std(t))/100;

%remove sequence less than 10 s
timemin = 10/60;
seq_remove = [];
for i = 1:size(framerate,1)
    if t(i) < timemin
        seq_remove = [seq_remove i];
    end
end
framerate(seq_remove,:)=[];
t = framerate(:,2) - framerate(:,1);
analysis_recording(5) = size(framerate,1);
analysis_recording(6) = round(100*mean(t))/100;
analysis_recording(7) = round(100*std(t))/100;
analysis_recording(8) = round(100*max(t))/100;
analysis_recording = analysis_recording';