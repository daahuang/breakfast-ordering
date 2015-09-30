function [ acc_sequence_all, acc_units_all, acc_units_perFrames, res_all ] = get_results_units_func( units_recog_perFrame, units_ref_perFrame, visualisation_on )
%GET_RESULTS_UNITS_FUNC Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
    visualisation_on = 0;
end

try
    
% % get activity accuracy
% [accuracy_action , confmat_action, test_label_action, predicted_label_action ] =  ...
%     get_results_seq( config);

% [accuracy_action , confmat_action, test_label_action, predicted_label_action ] = get_results_seq_func();
    
% test for same length
test1= cellfun(@length, units_ref_perFrame);
test2= cellfun(@length, units_recog_perFrame);

disp(['Found ', num2str(size(units_ref_perFrame, 2)), ' files']);

test_label_units = {};
predicted_label_units = {};
accuracy_units_dtw = [];

test_label_sequence_dtw = {};
predicted_label_sequence_dtw = {};
accuracy_sequence_dtw = [];

test_label_units_perFrames = {};
predicted_label_units_perFrames = {};
accuracy_units_perFrames = [];

for i_files = 1:1:size(units_ref_perFrame, 2)

    % evaluate accuracy per sequence
    test_label_units{i_files} = [units_ref_perFrame{i_files}(units_ref_perFrame{i_files}(1:end-1)~=units_ref_perFrame{i_files}(2:end)), units_ref_perFrame{i_files}(end)];
    predicted_label_units{i_files} = [ units_recog_perFrame{i_files}(units_recog_perFrame{i_files}(1:end-1)~=units_recog_perFrame{i_files}(2:end)), units_recog_perFrame{i_files}(end)];
    % remove leading and trailing SIL
    if test_label_units{i_files}(1) == 1
        test_label_units{i_files} = test_label_units{i_files}(2:end);
    end
    if test_label_units{i_files}(end) == 1
        test_label_units{i_files} = test_label_units{i_files}(1:end-1);
    end
    if predicted_label_units{i_files}(1) == 1
        predicted_label_units{i_files} = predicted_label_units{i_files}(2:end);
    end
    if predicted_label_units{i_files}(end) == 1
        predicted_label_units{i_files} = predicted_label_units{i_files}(1:end-1);
    end
    if visualisation_on == 1
        figure(1)
        title('Predicted units')
        ax1 = subplot(2,1,1); imagesc([predicted_label_units{i_files}]);
        caxis manual;
        caxis([1 50]);
        for i_tmp = 1:1:length(predicted_label_units{i_files})
            text(i_tmp, 1, num2str(predicted_label_units{i_files}(i_tmp)), 'BackgroundColor', [0.9, 0.9, 0.9] );
        end
        ax2 = subplot(2,1,2); imagesc([test_label_units{i_files}]);
        title('Test units');
        caxis manual;
        caxis([1 50]);
        for i_tmp = 1:1:length(test_label_units{i_files})
            text(i_tmp, 1, num2str(test_label_units{i_files}(i_tmp)), 'BackgroundColor', [0.9, 0.9, 0.9] );
        end

        h = colorbar;
        set(h, 'Position', [0.8, 0.1, 0.05, 0.8]);
        pos=get(ax1, 'Position');
        set(ax1, 'Position', [pos(1), pos(2), 0.8*pos(3), pos(4)]);
        pos=get(ax2, 'Position');
        set(ax2, 'Position', [pos(1), pos(2), 0.8*pos(3), pos(4)]);
    end

    % evaluate accuracy per sequence
    [Dist,D,k,w]=dtw(predicted_label_units{i_files},test_label_units{i_files});
    test_label_sequence_dtw{i_files} = test_label_units{i_files}(w(:, 2)');
    predicted_label_sequence_dtw{i_files} = predicted_label_units{i_files}(w(:, 1)');
    accuracy_sequence_dtw(i_files) = (sum(test_label_sequence_dtw{i_files} == predicted_label_sequence_dtw{i_files})) / size(w, 1);

    if visualisation_on == 1
        figure(2)
        ax1 = subplot(2,1,1); imagesc([predicted_label_sequence_dtw{i_files}]);
        title('Predicted units after dtw');
        caxis manual;
        caxis([1 50]);
        for i_tmp = 1:1:length(predicted_label_sequence_dtw{i_files})
            text(i_tmp, 1, num2str(predicted_label_sequence_dtw{i_files}(i_tmp)), 'BackgroundColor', [0.9, 0.9, 0.9] );
        end
        ax2 = subplot(2,1,2); imagesc([test_label_sequence_dtw{i_files}]);
        title('Test units after dtw');
        caxis manual;
        caxis([1 50]);
        for i_tmp = 1:1:length(test_label_sequence_dtw{i_files})
            text(i_tmp, 1, num2str(test_label_sequence_dtw{i_files}(i_tmp)), 'BackgroundColor', [0.9, 0.9, 0.9] );
        end

        h = colorbar;
        set(h, 'Position', [0.8, 0.1, 0.05, 0.8]);
        pos=get(ax1, 'Position');
        set(ax1, 'Position', [pos(1), pos(2), 0.8*pos(3), pos(4)]);
        pos=get(ax2, 'Position');
        set(ax2, 'Position', [pos(1), pos(2), 0.8*pos(3), pos(4)]);

%             figure(3)
%             imagesc(D)
%             colormap gray;
%             hold on     
%             plot(w(:, 2), w(:, 1));
%             hold off
    end

    accuracy_units_dtw(i_files) = get_unit_acc(test_label_sequence_dtw{i_files}, predicted_label_sequence_dtw{i_files}, w);


    % evaluate accuracy per frame
    test_label_units_perFrames{i_files} = units_ref_perFrame{i_files};
    predicted_label_units_perFrames{i_files} = units_recog_perFrame{i_files};
    if visualisation_on == 1
        figure(4);
        imagesc([predicted_label_units_perFrames{i_files}; ...
            test_label_units_perFrames{i_files}; ...
            (predicted_label_units_perFrames{i_files} == test_label_units_perFrames{i_files}) ...
            ]);
    end
    accuracy_units_perFrames(i_files) = (sum(test_label_units_perFrames{i_files} == predicted_label_units_perFrames{i_files}))/length(predicted_label_units_perFrames{i_files});

end

accuracy_sequence_dtw_tmp  = mean(accuracy_sequence_dtw);
accuracy_units_dtw_tmp  = mean(accuracy_units_dtw);
accuracy_units_perFrames_all  = (sum(cell2mat(test_label_units_perFrames) == cell2mat(predicted_label_units_perFrames)))/length(cell2mat(predicted_label_units_perFrames));

[ confMat_units_perFrames, order ] = get_conf_matrix( cell2mat(predicted_label_units_perFrames), cell2mat(test_label_units_perFrames)  );
confMat_units_perFrames_all  = confMat_units_perFrames; 


% save the details
res_all.test_label_units  = test_label_units;
res_all.predicted_label_units  = predicted_label_units;
res_all.accuracy_units_dtw  = accuracy_units_dtw;

res_all.test_label_sequence_dtw  = test_label_sequence_dtw;
res_all.predicted_label_sequence_dtw  = predicted_label_sequence_dtw;
res_all.accuracy_sequence_dtw  = accuracy_sequence_dtw;

res_all.test_label_units_perFrames  = test_label_units_perFrames;
res_all.predicted_label_units_perFrames  = predicted_label_units_perFrames;
res_all.accuracy_units_perFrames  = accuracy_units_perFrames;

catch ME
    getReport(ME)
    accuracy_action  = 0;
    accuracy_sequence_dtw_tmp  = 0;
    accuracy_units_dtw_tmp  = 0;
    accuracy_units_perFrames_all  = 0;
    keyboard;
end

% % no activity accuracy rightnow
% res_all.accuracy_action = accuracy_action;
% res_all.confmat_action = confmat_action;
% res_all.test_label_action = test_label_action;
% res_all.predicted_label_action = predicted_label_action;
% acc_activity = mean(accuracy_action);


acc_sequence_all = mean(accuracy_sequence_dtw_tmp);
acc_units_all = mean(accuracy_units_dtw_tmp);
acc_units_perFrames = mean(accuracy_units_perFrames_all);

end

