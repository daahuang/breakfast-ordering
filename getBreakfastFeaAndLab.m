clear;
% BF for breakfast
BF_root = '/home/deanh/Documents/MATLAB/Breakfast_dataset';

BF_func_dir = fullfile(BF_root, 'demo_bundle', 'functions');
addpath(genpath(BF_func_dir));

BF_fea_root = fullfile(BF_root, 'hist_h3d_c30');
BF_seg_dir = fullfile(BF_root, 'segmentation');

config.file_ending = '.txt';
config.normalization = 'std_frame';
config.noSIL = '';

% numSplits = 4;

% The splits for testing and training are:
% s1: P03 – P15
% s2: P16 – P28
% s3: P29 – P41
% s4: P42 – P52 (should be 54?)

Vid_test{1} = 3:15;
Vid_test{2} = 16:28;
Vid_test{3} = 29:41;
Vid_test{4} = 42:54;
Vid_all = [];

for k = 1:length(Vid_test)
    Vid_all = union(Vid_all, Vid_test{k});
end
Vid_all = Vid_all';

% % regular expression for test data (first split)
% pattern_test= '(P03_|P04_|P05_|P06_|P07_|P08_|P09_|P10_|P11_|P12_|P13_|P14_|P15_)';
% % regular expression for training data (second split)
% pattern_train = '(P16_|P17_|P18_|P19_|P20_|P21_|P22_|P23_|P24_|P25_|P26_|P27_|P28_|P29_|P30_|P31_|P32_|P33_|P34_|P35_|P36_|P37_|P38_|P39_|P40_|P41_|P42_|P43_|P44_|P45_|P46_|P47_|P48_|P49_|P50_|P51_|P52_|P53_|P54_)';
for s = 1:length(Vid_test)
    v_test = Vid_test{s};
    v_train = setdiff(Vid_all, v_test);
    
    pattern(s).test = array2regexp(v_test);
    pattern(s).train = array2regexp(v_train);  
end

for s = 1:length(pattern)
    features_dir = fullfile(BF_fea_root, sprintf('s%d', s));
    [features_test, labels_test, segfile_test] = load_features_with_segmentation(features_dir, BF_seg_dir, config.file_ending, config.normalization, 0, pattern(s).test, config.noSIL);
    disp(['found ' num2str(length(labels_test)) ' test sets']);
end


