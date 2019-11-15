tic
a = dir('D:\embedded_OMR_acoustic\2_camera_test\camera_behavior\for_time');

i = 1;
tbeha = nan(size(a,1)-2,1);
for i = 1:size(a,1)-2
    im = imread(fullfile(a(1,1).folder,a(2+i,1).name));
    timestamp = im(1,1:4);
    tbeha(i) = fast_extract_timestamp(timestamp);
end

a = dir('D:\embedded_OMR_acoustic\2_camera_test\camera_stim\for_time');

i = 1;
tstim = nan(size(a,1)-2,1);
for i = 1:size(a,1)-2
    im = imread(fullfile(a(1,1).folder,a(2+i,1).name));
    timestamp = im(1,1:4);
    tstim(i) = fast_extract_timestamp(timestamp);
end
toc