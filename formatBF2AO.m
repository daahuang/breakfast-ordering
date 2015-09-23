function [ X_out, Y_out, ANNOT_out ] = formatBF2AO( features, segfile, unit_list )
%FORMATBF2AO convert breakfast dataset data to action ordering (ECCV14)
%format
%   Detailed explanation goes here

X_out = cell2mat(features');

K = length(unit_list);
num_vid = length(segfile);
Y_out = cell(num_vid, 1);
ANNOT_out = cell(1, num_vid);

empty_a = unit_list{end}; % the last action unit is empty

for k = 1:num_vid
    numFrames = size(features{k}, 1);
    y = zeros(numFrames, K);
    seg = segfile{k};
    start_t = seg.segmentation;
    end_t = seg.segmentation_end;
    seg_name = seg.segment_name;
    
    for i = 1:length(seg_name)
        a_idx = find(strcmp(seg_name{i}, unit_list));
        if isempty(a_idx)
            warning('segment_name not found vid: %d, seg: %d', k, i);
        else
            y(start_t(i):end_t(i), a_idx) = 1
        end
    end
    Y_out{k} = y;
    
    annot = seg_name;
    annot(strcmp(empty_a, annot)) = [];
    ANNOT_out{k} = cellfun(@(x) find(strcmp(x, unit_list)), annot)';
end

end

