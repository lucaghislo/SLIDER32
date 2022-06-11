function [transfer_function_mean_values] = import_TransferFunction(transfer_function_file_name,transfer_function_file_data )

transfer_function_file = [transfer_function_file_name int2str(0) '.dat'];
transfer_function_data = readmatrix(transfer_function_file);
transfer_function_data = transfer_function_data(:,1:5);
transfer_function_data(any(isnan(transfer_function_data),2), :) = [];


peaking_times = 0:7;
length_peaking_times = length(peaking_times);

% tc, CAL_Voltage, tt, ch, data
CAL_Voltage = unique(transfer_function_data(:,2));
length_CAL_Voltage = length(CAL_Voltage);
channels = unique(transfer_function_data(:,4));
length_channels = length(channels);

% ch, pt, CAL_Voltage, y_axis_mean, y_axis_std, y_axis_median, outliers,
% y_axis_mean (without outliers), y_axis_std (without outliers), samples
transfer_function_mean_values = zeros(length_CAL_Voltage * length_channels * length_peaking_times, 10);


for pt = peaking_times
    transfer_function_file = [transfer_function_file_name int2str(pt) '.dat'];

    % tc, CAL_Voltage, tt, ch, data
    transfer_function_data = readmatrix(transfer_function_file);
    transfer_function_data(all(isnan(transfer_function_data),2), :) = [];
 
    for ch = channels'
        CAL_Voltage_count = 1;
        for x = CAL_Voltage'
            data = (transfer_function_data(transfer_function_data(:,2)==x & transfer_function_data(:,4)==ch & (transfer_function_data(:,3)==0 | transfer_function_data(:,3)==10),5));
            data_mean = mean(data);
            data_std = std(data);
            data_median = median(data);
            [data_without_outliers, boolean_outliers] = rmoutliers(data);
            data_mean_wout_outliers = mean(data_without_outliers);
            data_std_wout_outliers = std(data_without_outliers);
            outliers = data(boolean_outliers);
            pos = ch*(length_CAL_Voltage)*(length_peaking_times) + pt*(length_CAL_Voltage) + CAL_Voltage_count;
            CAL_Voltage_count = CAL_Voltage_count + 1;
            value = [ch pt x data_mean data_std data_median length(outliers) data_mean_wout_outliers data_std_wout_outliers length(data)];
            transfer_function_mean_values(pos,:) = value; 
        end
    end
end

%% SAVE FILE
fileID = fopen(transfer_function_file_data,'w');
fprintf(fileID,'%2s/t%2s/t%4s/t%4s/t%3s/t%6s/t%8s/t%12s/t%11s/t%7s/r/n','ch','pt','CAL_V','mean','std','median','outliers','mean_w/o_out', 'std_w/o_out','samples');
fprintf(fileID,'%2d/t%2d/t%5d/t%7.2f/t%6.3f/t%5.1f/t%3d/t%7.2f/t%6.3f/t%4d/r/n',transfer_function_mean_values');
fclose(fileID);
end

