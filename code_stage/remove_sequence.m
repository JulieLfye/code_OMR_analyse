function [seq_remove,sequence,angle_lab,angle_source,angle_filtered,framerate,...
    coordinates,luminosity]=remove_sequence(D,timemin)
%% Comments
% Select the sequences to analyse. Remove the empty sequences and the
% sequence shorter than time
%Inputs -----
% D: structure from the experiment
% time: time minimal of the sequence for analysing, in seconds
%Outputs -----
% seq_remove: list of the sequences which have been removed
% sequence: list of the remaining sequences
% framerate, coordinates, angle: data with only the remaining sequences

% /!\ Specific for the experiment analysis

%% Code
angle_lab = D.experiment.angle;
angle_source = D.experiment.angleCum;
angle_filtered = D.experiment.angleFiltered;
framerate = D.experiment.framerate;
coordinates = D.experiment.coordinates;
luminosity = D.experiment.luminosity;

seq_remove = [];
sequence = linspace(1,size(angle_source,1),size(angle_source,1));
for seq = 1:size(angle_source,1)
    % ----- remove empty sequence -----
    a = sum(angle_source(seq,:));
    if a == 0
        seq_remove = [seq_remove seq];
    else
        endseq = framerate(seq,4);
        if endseq > size(angle_source,2)
            endseq = size(angle_source,2);
        end
        angle_lab(seq,endseq:end) = nan;
        angle_source(seq,endseq:end) = nan;
        angle_filtered(seq,endseq:end) = nan;
        coordinates(endseq:end,:,seq) = nan;
        luminosity(seq,endseq:end) = nan;
        
    end
    % ----- remove sequence shorter than time second -----
    t = framerate(seq,2) - framerate(seq,1);
    if t < timemin
        seq_remove = [seq_remove seq];
    end
end

seq_remove = unique(seq_remove);
sequence = setdiff(sequence,seq_remove);

angle_lab(seq_remove,:) = [];
angle_source(seq_remove,:) = [];
angle_filtered(seq_remove,:) = [];
coordinates(:,:,seq_remove) = [];
luminosity(seq_remove,:) = [];
framerate(seq_remove,:) = [];