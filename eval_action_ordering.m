clear;
addpath(genpath('../packages'));

%%
OUT_dir = '../output/action-ordering';
DS_dir = '../data/BF2AO';
fea_str = 'hist_dt_l2pn_c64';
% fea_str = 'hist_h3d_c30';
splits = 1:4;

% load clips_test

%%
result_ordering = cell(size(splits));
result_svm = cell(size(splits));

for split = splits
   datapath = fullfile(DS_dir, sprintf('%s_s%d.mat', fea_str, split));
   outpath = fullfile(OUT_dir, sprintf('%s_s%d.mat', fea_str, split)); 
   try
       load(outpath);
       load(datapath, 'Xtest', 'Ytest', 'clips_test');
   catch ME
       warning(ME.message);
       continue;
   end
   
   Ztest = Xtest*ordering.w;
   [~, z_idx] = max(Ztest, [], 2);
   [~, y_idx] = max(Ytest, [], 2);
   
   units_recog_perFrame_ordering = mat2cell(z_idx', 1, clips_test);
   units_ref_perFrame = mat2cell(y_idx', 1, clips_test);
   [~, ~, ~, result_ordering{split}] = get_results_units_func( units_recog_perFrame_ordering, units_ref_perFrame );
   
   [z_idx_svm] = liblinear_predict(y_idx, sparse(Xtest), models_sup.model_svm);
   
   units_recog_perFrame_svm = mat2cell(z_idx_svm', 1, clips_test);
   [~, ~, ~, result_svm{split}] = get_results_units_func( units_recog_perFrame_svm, units_ref_perFrame );
   
end

[res_merged_ordering, accuracy_ordering] = merge_results(result_ordering);
[res_merged_svm, accuracy_svm] = merge_results(result_svm);