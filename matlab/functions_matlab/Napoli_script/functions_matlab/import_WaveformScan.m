function [waveform_scan_mean_values] = import_WaveformScan(waveform_file_name, waveform_file_data)
%   Detailed explanation goes here
waveform_scan_file = [waveform_file_name int2str(0) '.dat'];
waveform_scan_data = readmatrix(waveform_scan_file);
waveform_scan_data(all(isnan(waveform_scan_data),2), :) = [];

% tc, CAL_Voltage, tt, ch, data
tc = unique(waveform_scan_data(:,1));
length_tc = length(tc);
channels = unique(waveform_scan_data(:,4));
length_channels = length(channels);
peaking_times = 0:7;
length_peaking_times = length(peaking_times);

% ch, pt, CAL_Voltage, y_axis_mean, y_axis_std, y_axis_median, outliers,
% y_axis_mean (without outliers), y_axis_std (without outliers), samples
values = zeros(length_tc * length_channels * length_peaking_times, 10);


for pt = peaking_times
    waveform_scan_file = [waveform_file_name int2str(pt) '.dat'];

    % tc, CAL_Voltage, tt, ch, data
    waveform_scan_data = readmatrix(waveform_scan_file);
    waveform_scan_data(all(isnan(waveform_scan_data),2), :) = [];
 
    for ch = channels'
        tc_count = 1;
        for x = tc'
            data = (waveform_scan_data(waveform_scan_data(:,1)==x & waveform_scan_data(:,4)==ch & (waveform_scan_data(:,3)==0 | waveform_scan_data(:,3)==10),5));
            data_mean = mean(data);
            data_std = std(data);
            data_median = median(data);
            [data_without_outliers, boolean_outliers] = rmoutliers(data);
            data_mean_wout_outliers = mean(data_without_outliers);
            data_std_wout_outliers = std(data_without_outliers);
            outliers = data(boolean_outliers);
            pos = ch*(length_tc)*(length_peaking_times) + pt*(length_tc) + tc_count;
            tc_count = tc_count + 1;
            value = [ch pt x data_mean data_std data_median length(outliers) data_mean_wout_outliers data_std_wout_outliers length(data)];
            values(pos,:) = value; 
        end
    end
end

%% SAVE FILE
fileID = fopen(waveform_file_data,'w');
fprintf(fileID,'%2s\t%2s\t%2s\t%4s\t%3s\t%6s\t%8s\t%12s\t%11s\t%7s\r\n','ch','pt','tc','mean','std','median','outliers','mean_w/o_out', 'std_w/o_out','samples');
fprintf(fileID,'%2d\t%2d\t%3d\t%7.2f\t%6.3f\t%5.1f\t%3d\t%7.2f\t%6.3f\t%4d\r\n',values');
fclose(fileID);

%% Deal with output requests
if nargout > 0
    waveform_scan_mean_values = values;
end

end

