function [real_peaking_times] = find_peaking_times(waveform_mean_values, statistic_used, folder_name)
%% INPUT
% waveform_mean_values: dati mediati ottenuti dai file originali
% statistic_used: scegliere che tipo di peaking time utilizzare nei
%       plot: 'mean' usa i valori mediati, 'median' usa la mediana dei
%       dati, 'mean_wo_out' usa i valori mediati senza outliers
% folder_name: cartella della misura -> la cartella deve contenere le
%              cartelle data e analysis_matlab.


% \\\ se esiste già il file peaking_times
%% CREAZIONE CARTELLE PER PLOT DATI
if ~exist([folder_name 'analysis_matlab/WaveformScan'],'dir' )
    mkdir([folder_name 'analysis_matlab/WaveformScan']);
end

%% FIND PEAKING TIMES
channels = unique(waveform_mean_values(:,1));
peaking_times = unique(waveform_mean_values(:,2));
length_channels = length(channels);
length_peaking_times = length(peaking_times);

number_of_stats = 6;
% tempi di picco calolati sulla mediana, sulla media e sulla media senza
% outliers dei dati
peaking_times_median = zeros(length_peaking_times,length_channels + number_of_stats);
peaking_times_mean = zeros(length_peaking_times,length_channels + number_of_stats);
peaking_times_mean_wo_outliers = zeros(length_peaking_times,length_channels + number_of_stats);

max_values_median = zeros(length_peaking_times,length_channels + number_of_stats);
max_values_mean = zeros(length_peaking_times,length_channels + number_of_stats);
max_values_mean_wo_outliers = zeros(length_peaking_times,length_channels + number_of_stats);

for ch = channels'
    for pt = peaking_times'
        [max_val_median,idx_median] = max(waveform_mean_values(waveform_mean_values(:,1)==ch & waveform_mean_values(:,2)==pt,6));
        [max_val_mean,idx_mean] = max(waveform_mean_values(waveform_mean_values(:,1)==ch & waveform_mean_values(:,2)==pt,4));
        [max_val_mean_wo_outliers,idx_mean_wo_outliers] = max(waveform_mean_values(waveform_mean_values(:,1)==ch & waveform_mean_values(:,2)==pt,8));    
        peaking_times_median(pt + 1, ch + 1) = waveform_mean_values(idx_median,3)/48;
        peaking_times_mean(pt + 1, ch + 1) = waveform_mean_values(idx_mean,3)/48;
        peaking_times_mean_wo_outliers(pt + 1, ch + 1) = waveform_mean_values(idx_mean_wo_outliers,3)/48;
        max_values_median(pt + 1, ch + 1) = max_val_median;
        max_values_mean(pt + 1, ch + 1) = max_val_mean;
        max_values_mean_wo_outliers(pt + 1, ch + 1) = max_val_mean_wo_outliers;
    end
end

%% MAX VALUES MEDIAN
for pt = 0:7
    data = (max_values_median(pt + 1,1:length_channels));
    data_mean = mean(data);
    data_std = std(data);
    data_median = median(data);
    [data_without_outliers, boolean_outliers] = rmoutliers(data);
    data_mean_wout_outliers = mean(data_without_outliers);
    data_std_wout_outliers = std(data_without_outliers);
    outliers = data(boolean_outliers);
    value = [data_mean data_std data_median length(outliers) data_mean_wout_outliers data_std_wout_outliers];
    max_values_median(pt + 1,length_channels + 1:end) = value;
end

%% MAX VALUES MEAN
for pt = 0:7
    data = (max_values_mean(pt + 1,1:length_channels));
    data_mean = mean(data);
    data_std = std(data);
    data_median = median(data);
    [data_without_outliers, boolean_outliers] = rmoutliers(data);
    data_mean_wout_outliers = mean(data_without_outliers);
    data_std_wout_outliers = std(data_without_outliers);
    outliers = data(boolean_outliers);
    value = [data_mean data_std data_median length(outliers) data_mean_wout_outliers data_std_wout_outliers];
    max_values_mean(pt + 1,length_channels + 1:end) = value;
end

%% MAX VALUES MEAN WITHOUT OUTLIERS
for pt = 0:7
    data = (max_values_mean_wo_outliers(pt + 1,1:length_channels));
    data_mean = mean(data);
    data_std = std(data);
    data_median = median(data);
    [data_without_outliers, boolean_outliers] = rmoutliers(data);
    data_mean_wout_outliers = mean(data_without_outliers);
    data_std_wout_outliers = std(data_without_outliers);
    outliers = data(boolean_outliers);
    value = [data_mean data_std data_median length(outliers) data_mean_wout_outliers data_std_wout_outliers];
    max_values_mean_wo_outliers(pt + 1,length_channels + 1:end) = value;
end

%% PEAKING TIMES MEDIAN
for pt = 0:7
    data = (peaking_times_median(pt + 1,1:length_channels));
    data_mean = mean(data);
    data_std = std(data);
    data_median = median(data);
    [data_without_outliers, boolean_outliers] = rmoutliers(data);
    data_mean_wout_outliers = mean(data_without_outliers);
    data_std_wout_outliers = std(data_without_outliers);
    outliers = data(boolean_outliers);
    value = [data_mean data_std data_median length(outliers) data_mean_wout_outliers data_std_wout_outliers];
    peaking_times_median(pt + 1,length_channels + 1:end) = value;
end

%% PEAKING TIMES MEAN
for pt = 0:7
    data = (peaking_times_mean(pt + 1,1:length_channels));
    data_mean = mean(data);
    data_std = std(data);
    data_median = median(data);
    [data_without_outliers, boolean_outliers] = rmoutliers(data);
    data_mean_wout_outliers = mean(data_without_outliers);
    data_std_wout_outliers = std(data_without_outliers);
    outliers = data(boolean_outliers);
    value = [data_mean data_std data_median length(outliers) data_mean_wout_outliers data_std_wout_outliers];
    peaking_times_mean(pt + 1,length_channels + 1:end) = value;
end

%% PEAKING TIMES MEAN WITHOUT OUTLIERS
for pt = 0:7
    data = (peaking_times_mean_wo_outliers(pt + 1,1:length_channels));
    data_mean = mean(data);
    data_std = std(data);
    data_median = median(data);
    [data_without_outliers, boolean_outliers] = rmoutliers(data);
    data_mean_wout_outliers = mean(data_without_outliers);
    data_std_wout_outliers = std(data_without_outliers);
    outliers = data(boolean_outliers);
    value = [data_mean data_std data_median length(outliers) data_mean_wout_outliers data_std_wout_outliers];
    peaking_times_mean_wo_outliers(pt + 1,length_channels + 1:end) = value;
end

%% CHOOSE WHICH TYPE OF PEAKING TIMES TO PLOT
if strcmp(statistic_used,'mean')
    real_peaking_times = peaking_times_mean(:,1:32);
elseif strcmp(statistic_used,'median')
    real_peaking_times = peaking_times_median(:,1:32);    
else
    real_peaking_times = peaking_times_mean_wo_outliers(:,1:32); 
end

peaking_times_mean_wo_outliers = round(peaking_times_mean_wo_outliers,4);
peaking_times_mean = round(peaking_times_mean,4);
peaking_times_median = round(peaking_times_median,4);

%% SAVE FILE
lines = '';
for i = 1:250
    lines = strcat(lines,'-');
end 

% SAVE FILE - Peaking Times based on Mean without Outliers
fileID = fopen([folder_name 'analysis_matlab/WaveformScan/Peaking_Times.dat'],'w');
first_line = sprintf('%4s\t',strcat('#',string(channels)));
fprintf(fileID,'%s\r\n','Peaking Times - based on Mean values without Outliers [us]');
fprintf(fileID,'%s',first_line);
fprintf(fileID,'%s\t%s\t%s\t%s\t%s\t%s\r\n','mean','std','median','outliers','mean_w/o_out','std_w/o_out');
format = '';
for i = 1:length_channels
    format = strcat(format,'%5.4f\t');
end
format = strcat(format,'%5.4f\t%5.4f\t%5.4f\t%3d\t%5.4f\t%5.4f\r\n');
fprintf(fileID,format,peaking_times_mean_wo_outliers');
fprintf(fileID,'%s\r\n',lines);


% SAVE FILE - Peaking Times based on Mean with outliers
first_line = sprintf('%4s\t',strcat('#',string(channels)));
fprintf(fileID,'%s\r\n','Peaking Times - based on Mean values with outliers [us]');
fprintf(fileID,'%s',first_line);
fprintf(fileID,'%s\t%s\t%s\t%s\t%s\t%s\r\n','mean','std','median','outliers','mean_w/o_out','std_w/o_out');
format = '';
for i = 1:length_channels
    format = strcat(format,'%5.4f\t');
end
format = strcat(format,'%5.4f\t%5.4f\t%5.4f\t%3d\t%5.4f\t%5.4f\r\n');
fprintf(fileID,format,peaking_times_mean');
fprintf(fileID,'%s\r\n',lines);


% SAVE FILE - Peaking Times based on Median
first_line = sprintf('%4s\t',strcat('#',string(channels)));
fprintf(fileID,'%s\r\n','Peaking Times - based on Median values [us]');
fprintf(fileID,'%s',first_line);
fprintf(fileID,'%s\t%s\t%s\t%s\t%s\t%s\r\n','mean','std','median','outliers','mean_w/o_out','std_w/o_out');
format = '';
for i = 1:length_channels
    format = strcat(format,'%5.4f\t');
end
format = strcat(format,'%5.4f\t%5.4f\t%5.4f\t%3d\t%5.4f\t%5.4f\r\n');
fprintf(fileID,format,peaking_times_median');
fprintf(fileID,'%s\r\n',lines);


% SAVE FILE - Max Values based on Mean without outliers
first_line = sprintf('%4s\t',strcat('#',string(channels)));
fprintf(fileID,'%s\r\n','Channel_out values at peaking time - based on Mean values without Outliers [ADC code]');
fprintf(fileID,'%s',first_line);
fprintf(fileID,'%s\t%s\t%s\t%s\t%s\t%s\r\n','mean','std','median','outliers','mean_w/o_out','std_w/o_out');
format = '';
for i = 1:length_channels
    format = strcat(format,'%6.2f\t');
end
format = strcat(format,'%6.2f\t%5.3f\t%6.2f\t%3d\t%6.2f\t%5.3f\r\n');
fprintf(fileID,format,max_values_mean_wo_outliers');
fprintf(fileID,'%s\r\n',lines);


% SAVE FILE - Max Values based on Mean with outliers
first_line = sprintf('%4s\t',strcat('#',string(channels)));
fprintf(fileID,'%s\r\n','Channel_out values (ADC code) at peaking time - based on Mean values with Outliers [ADC code]');
fprintf(fileID,'%s',first_line);
fprintf(fileID,'%s\t%s\t%s\t%s\t%s\t%s\r\n','mean','std','median','outliers','mean_w/o_out','std_w/o_out');
format = '';
for i = 1:length_channels
    format = strcat(format,'%6.2f\t');
end
format = strcat(format,'%6.2f\t%5.3f\t%6.2f\t%3d\t%6.2f\t%5.3f\r\n');
fprintf(fileID,format,max_values_mean');
fprintf(fileID,'%s\r\n',lines);

% SAVE FILE - Max Values based on Median
first_line = sprintf('%4s\t',strcat('#',string(channels)));
fprintf(fileID,'%s\r\n','Channel_out values (ADC code) at peaking time - based on Median values [ADC code]');
fprintf(fileID,'%s',first_line);
fprintf(fileID,'%s\t%s\t%s\t%s\t%s\t%s\r\n','mean','std','median','outliers','mean_w/o_out','std_w/o_out');
format = '';
for i = 1:length_channels
    format = strcat(format,'%6.2f\t');
end
format = strcat(format,'%6.2f\t%5.3f\t%6.2f\t%3d\t%6.2f\t%5.3f\r\n');
fprintf(fileID,format,max_values_median');
fclose(fileID);

end


