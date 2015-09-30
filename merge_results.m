function [ results_merged, accuracy ] = merge_results( results )
%MERGED_RESULTS Summary of this function goes here
%   Detailed explanation goes here

results_merged = results{1};
names = fieldnames(results_merged);
for i = 2:length(results)
    res = results{i};
    if isempty(res)
        continue;
    end
    for j = 1:length(names)
        name = names{j};
        eval(sprintf('results_merged.%s = cat(2, results_merged.%s, res.%s);', name, name, name));       
    end
end

% get fields to workspace
cellfun(@(f) evalin('caller',[f ' = results_merged.' f ';']), fieldnames(results_merged))

% compute accuracies
accuracy_units_perFrames_all  = (sum(cell2mat(test_label_units_perFrames) == cell2mat(predicted_label_units_perFrames)))/length(cell2mat(predicted_label_units_perFrames));
acc_sequence_all = mean(accuracy_sequence_dtw);
acc_units_all = mean(accuracy_units_dtw);
acc_units_perFrames = mean(accuracy_units_perFrames_all);

accuracy.acc_unit_parsing = acc_sequence_all;
accuracy.acc_unit_rec = acc_units_all;
accuracy.acc_units_perFrames = acc_units_perFrames;

end

