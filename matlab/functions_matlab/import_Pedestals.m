function  [pedestals_mean_values, pedestals_channel_out_ADC_codes1, pedestals_mean_values_wo_mean, pedestals_channel_out_ADC_codes2, allData, pedestal_data_for_ch_mean, meanData] = import_Pedestals(pedestals_file_name, pedestals_file_data, calculate_mean_pedestals)

peaking_times = 0:7;
length_peaking_times = length(peaking_times);
pedestal_max = -2^11;
pedestal_min = 2^11;
number_of_pedestals = 1000;

for pt = peaking_times
    pedestals_file = [pedestals_file_name int2str(pt) '.dat'];
    pedestals_data = readmatrix(pedestals_file);
    pedestals_data(all(isnan(pedestals_data),2), :) = [];
    
    file_max = max(pedestals_data(:,5));
    file_min = min(pedestals_data(:,5));
    
    if(file_min < pedestal_min)
        pedestal_min = file_min;
    end
    
    if(file_max > pedestal_max)
        pedestal_max = file_max;
    end
end


%% ELABORATE DATA FOR SAVING FILE
pedestals_channel_out_ADC_codes1 = pedestal_min:file_max;
length_channel_out_ADC_code1 = length(pedestals_channel_out_ADC_codes1);

% tc, CAL_Voltage, tt, ch, data
channels = unique(pedestals_data(:,4));
length_channels = length(channels);

% ch, pt, Channel_Out_mean, Channel_Out_std, Channel_Out_median, outliers,
% Channel_Out_mean (without outliers), Channel_Out_std (without outliers),
% samples, single values occurencies...
pedestals_mean_values = zeros(length_channels * length_peaking_times, 9 + length_channel_out_ADC_code1);
allData = zeros(number_of_pedestals,  length_channels, length_peaking_times);

for pt = peaking_times
    pedestals_file = [pedestals_file_name int2str(pt) '.dat'];
    
    % tbtyvc, CAL_Voltage, tt, ch, data
    pedestals_data = readmatrix(pedestals_file);
    pedestals_data(all(isnan(pedestals_data),2), :) = [];

    for ch = channels'       
        data = (pedestals_data(pedestals_data(:,4)==ch & (pedestals_data(:,3)==0 | pedestals_data(:,3)==10),5));
        count_occurencies = histcounts(data,[pedestals_channel_out_ADC_codes1, pedestal_max + 1]);
        data_mean = mean(data);
        data_std = std(data);
        data_median = median(data);
        [data_without_outliers, boolean_outliers] = rmoutliers(data);
        data_mean_wout_outliers = mean(data_without_outliers);
        data_std_wout_outliers = std(data_without_outliers);
        outliers = data(boolean_outliers);
        pos = ch * length_peaking_times + pt + 1;
        
        value = [ch pt data_mean data_std data_median length(outliers) data_mean_wout_outliers data_std_wout_outliers length(data) count_occurencies];
        pedestals_mean_values(pos,:) = value;

        disp(pedestals_file)
        allData(:,ch + 1,pt + 1) = data;

    end
    
end

%% ELABORATE DATA FOR SAVING FILE WITHOUT MEAN
if calculate_mean_pedestals == 1
    
    pedestal_data_for_ch_mean = zeros(number_of_pedestals,length_peaking_times);
    pedestal_min_2 = 2^11;
    pedestal_max_2 = -2^11;
    
    meanData = zeros(number_of_pedestals,  length_channels, length_peaking_times);
    
    for pt = peaking_times
        pt_data = allData(:,:,pt + 1);
        columnMeans = mean(pt_data, 2);
        pedestal_data_for_ch_mean(:,pt + 1) = columnMeans; % AAA
        new_pt_data = pt_data - columnMeans;
        meanData(:,:,pt + 1) = new_pt_data; % AAA
        
        file_max = max(new_pt_data(:,:),[],'all');
        file_min = min(new_pt_data(:,:),[],'all');
        
        file_max = ceil(file_max);
        file_min = floor(file_min);
        
        if(file_min < pedestal_min_2)
            pedestal_min_2 = file_min;
        end
        
        if(file_max > pedestal_max_2)
            pedestal_max_2 = file_max;
        end
    end
    
    pedestals_channel_out_ADC_codes2 = pedestal_min_2:pedestal_max_2;
    length_channel_out_ADC_code2 = length(pedestals_channel_out_ADC_codes2);
    % ch, pt, Channel_Out_mean, Channel_Out_std, Channel_Out_median, outliers,
    % Channel_Out_mean (without outliers), Channel_Out_std (without outliers),
    % samples, single values occurencies...
    pedestals_mean_values_wo_mean = zeros(length_channels * length_peaking_times, 9 + length_channel_out_ADC_code2);
    
    %% CREATE FILE TO SAVE FOR PEDESTALS WITHOUT MEAN VALUES
    for pt = peaking_times
        for ch = channels'
            data_for_plot = (meanData(:,ch + 1, pt + 1));
            %mean_data = data - pedestal_data_for_ch_mean(:, pt + 1);
            count_occurencies = histcounts(data_for_plot,[pedestals_channel_out_ADC_codes2, pedestal_max_2 + 1]-0.5);
            data_mean = mean(data_for_plot);
            data_std = std(data_for_plot);
            data_median = median(data_for_plot);
            [data_without_outliers, boolean_outliers] = rmoutliers(data_for_plot);
            data_mean_wout_outliers = mean(data_without_outliers);
            data_std_wout_outliers = std(data_without_outliers);
            outliers = meanData(boolean_outliers);
            pos = ch * length_peaking_times + pt + 1;
            
            value = [ch pt data_mean data_std data_median length(outliers) data_mean_wout_outliers data_std_wout_outliers length(data) count_occurencies];
            pedestals_mean_values_wo_mean(pos,:) = value;
        end
        
    end
else
    pedestals_mean_values_wo_mean = [];
    pedestals_channel_out_ADC_codes2 = [];
    pedestal_data_for_ch_mean = [];
    meanData = [];
end

%% SAVE REGULAR FILE
fileID = fopen(pedestals_file_data,'w');
fprintf(fileID,'%2s/t%2s/t%4s/t%4s/t%3s/t%6s/t%8s/t%12s/t%11s/t%7s','ch','pt','mean','std','median','outliers','mean_w/o_out', 'std_w/o_out','samples');
first_line = sprintf('%4s/t',strcat('#',string(pedestals_channel_out_ADC_codes1)));
first_line = first_line(1:end-1);
fprintf(fileID,'%s/r/n',first_line);

max_size = length_channels * length_peaking_times;
for line = 1 : max_size
    fprintf(fileID,'%2d/t%2d/t%7.2f/t%7.2f/t%6.1f/t%4d/t%7.2f/t%6.2f/t%4d',pedestals_mean_values(line,1:9)');  
    line_string = sprintf('%4s/t',string(pedestals_mean_values(line,10:end)));
    line_string = line_string(1:end-1);
    fprintf(fileID,'%s/r/n',line_string);
end
fclose(fileID);

%% SAVE MEAN FILE
if calculate_mean_pedestals == 1
    pedestals_file_data2 = split(pedestals_file_data,'.dat');
    pedestals_file_data2 = pedestals_file_data2{1};
    pedestals_file_data2 = [pedestals_file_data2 '_mean.dat'];
    fileID = fopen(pedestals_file_data2,'w');
    fprintf(fileID,'%2s/t%2s/t%4s/t%4s/t%3s/t%6s/t%8s/t%12s/t%11s/t%7s','ch','pt','mean','std','median','outliers','mean_w/o_out', 'std_w/o_out','samples');
    first_line = sprintf('%4s/t',strcat('#',string(pedestals_channel_out_ADC_codes2)));
    first_line = first_line(1:end-1);
    fprintf(fileID,'%s/r/n',first_line);
    
    max_size = length_channels * length_peaking_times;
    for line = 1 : max_size
        fprintf(fileID,'%2d/t%2d/t%7.2f/t%7.2f/t%6.1f/t%4d/t%7.2f/t%6.2f/t%4d',pedestals_mean_values_wo_mean(line,1:9)');
        line_string = sprintf('%4s/t',string(pedestals_mean_values_wo_mean(line,10:end)));
        line_string = line_string(1:end-1);
        fprintf(fileID,'%s/r/n',line_string);
    end
    fclose(fileID);
end
