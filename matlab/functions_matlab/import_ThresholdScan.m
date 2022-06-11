function [threshold_scan_mean_values] = import_ThresholdScan(threshold_scan_file_name, threshold_scan_file_data)

threshold_scan_file = [threshold_scan_file_name int2str(0) '_tau' int2str(0) '.dat'];
threshold_scan_data = readmatrix(threshold_scan_file);
threshold_scan_data(all(isnan(threshold_scan_data),2), :) = [];
%threshold_scan_data = threshold_scan_data(41:end,1:5);

peaking_times = 0:7;
length_peaking_times = length(peaking_times);

fine_thresholds = 0:7;
length_fine_threshold = length(fine_thresholds);

% Threshold, CAL_Voltage, Events, Triggered, ch
discriminator_threshold = unique(threshold_scan_data(:,1));
length_discriminator_threshold = length(discriminator_threshold);

channels = unique(threshold_scan_data(:,5));
length_channels = length(channels);


% ch, pt, fine_thr, disc_thr, events, triggered
threshold_scan_mean_values = zeros(length_discriminator_threshold * length_channels * length_peaking_times * length_fine_threshold, 6);


for pt = peaking_times
    for fin_thr = fine_thresholds
        threshold_scan_file = [threshold_scan_file_name int2str(fin_thr) '_tau' int2str(pt) '.dat'];
        threshold_scan_data = readmatrix(threshold_scan_file);
        threshold_scan_data(all(isnan(threshold_scan_data),2), :) = [];
        threshold_scan_data = threshold_scan_data(1:end,1:5);
        threshold_scan_data_size = size(threshold_scan_data,1);
        for count = 1 : threshold_scan_data_size
            ch = threshold_scan_data(count,5);
            idx_ch = find(channels==ch);
            disc_thr = threshold_scan_data(count,1);
            idx_disc_thr = find(discriminator_threshold==disc_thr);
            trigg = threshold_scan_data(count,4);
            events = threshold_scan_data(count,3);
            
            
            value = [ch pt fin_thr disc_thr events trigg];
            pos = (idx_ch - 1)*length_fine_threshold*length_peaking_times*length_discriminator_threshold + pt*length_fine_threshold*length_discriminator_threshold + fin_thr*length_discriminator_threshold + idx_disc_thr;
            threshold_scan_mean_values(pos,:) = value;
        end
    end
end

%% SAVE FILE
fileID = fopen(threshold_scan_file_data,'w');
fprintf(fileID,'%2s/t%2s/t%8s/t%8s/t%6s/t%5s/r/n','ch','pt','fine_thr','disc_thr','events','trigg');
fprintf(fileID,'%2d/t%2d/t%2d/t%3d/t%5d/t%5d/r/n',threshold_scan_mean_values');
fclose(fileID);
end

