function  [self_trigger_mean_values, self_trigger_channel_out_ADC_codes1, allData] = import_SelfTrigger(self_trigger_file_name, self_trigger_file_data)

%% 
channels = 0:31;
length_channels = length(channels);
self_trigger_max = -2^11;
self_trigger_min = 2^11;
number_of_pedestals = 1000;

for ch = channels
    self_trigger_file = [self_trigger_file_name int2str(ch) '.dat'];
    self_trigger_data = readmatrix(self_trigger_file);
    self_trigger_data(all(isnan(self_trigger_data),2), :) = [];
    
    file_max = max(self_trigger_data(self_trigger_data(:,4)==ch & self_trigger_data(:,3)==10,5));
    file_min = min(self_trigger_data(self_trigger_data(:,4)==ch & self_trigger_data(:,3)==10,5));
    
    if(file_min < self_trigger_min)
        self_trigger_min = file_min;
    end
    
    if(file_max > self_trigger_max)
        self_trigger_max = file_max;
    end
end


%% ELABORATE DATA FOR SAVING FILE
self_trigger_channel_out_ADC_codes1 = self_trigger_min:self_trigger_max;
length_channel_out_ADC_code1 = length(self_trigger_channel_out_ADC_codes1);

% ch, Channel_Out_mean, Channel_Out_std, Channel_Out_median, outliers,
% Channel_Out_mean (without outliers), Channel_Out_std (without outliers),
% samples, single values occurencies...
self_trigger_mean_values = zeros(length_channels, 8 + length_channel_out_ADC_code1);
allData = zeros(number_of_pedestals,  length_channels);

for ch = channels
    self_trigger_file = [self_trigger_file_name int2str(ch) '.dat'];
    
    % S, CAL_Voltage, tt, ch, data
    self_trigger_data = readmatrix(self_trigger_file);
    self_trigger_data(all(isnan(self_trigger_data),2), :) = [];
    
    data = (self_trigger_data(self_trigger_data(:,4)==ch & self_trigger_data(:,3)==10,5));
    count_occurencies = histcounts(data,[self_trigger_channel_out_ADC_codes1, self_trigger_max + 1]);
    data_mean = mean(data);
    data_std = std(data);
    data_median = median(data);
    [data_without_outliers, boolean_outliers] = rmoutliers(data);
    data_mean_wout_outliers = mean(data_without_outliers);
    data_std_wout_outliers = std(data_without_outliers);
    outliers = data(boolean_outliers);
    pos = ch + 1;
    
    value = [ch data_mean data_std data_median length(outliers) data_mean_wout_outliers data_std_wout_outliers length(data) count_occurencies];
    self_trigger_mean_values(pos,:) = value;
    
    if(size(data,1) ~= number_of_pedestals)
        last = zeros(number_of_pedestals - size(data,1), 1);
        allData(:,ch + 1) = [data;last];
    else
        allData(:,ch + 1) = data;
    end
end

%% SAVE REGULAR FILE
fileID = fopen(self_trigger_file_data,'w');
fprintf(fileID,'%2s/t%4s/t%4s/t%3s/t%6s/t%8s/t%12s/t%11s/t%7s','ch','pt','mean','std','median','outliers','mean_w/o_out', 'std_w/o_out','samples');
first_line = sprintf('%4s/t',strcat('#',string(self_trigger_channel_out_ADC_codes1)));
first_line = first_line(1:end-1);
fprintf(fileID,'%s/r/n',first_line);

max_size = length_channels;
for line = 1 : max_size
    fprintf(fileID,'%2d/t%7.2f/t%7.2f/t%6.1f/t%4d/t%7.2f/t%6.2f/t%4d',self_trigger_mean_values(line,1:9)');  
    line_string = sprintf('%4s/t',string(self_trigger_mean_values(line,10:end)));
    line_string = line_string(1:end-1);
    fprintf(fileID,'%s/r/n',line_string);
end
fclose(fileID);
end
