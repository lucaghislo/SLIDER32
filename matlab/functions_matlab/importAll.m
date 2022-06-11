function [transfer_function_mean_values,pedestals_channel_out_ADC_codes,pedestals_channel_out_occurencies,pedestals_mean_values,waveform_mean_values,threshold_mean_values, pedestals_mean_values_wo_mean, pedestals_channel_out_ADC_codes2, allData, pedestal_data_for_ch_mean, meanData, self_trigger_mean_values, allDataSelfTrigger, self_trigger_channel_out_ADC_codes] = importAll(folder_name, plot_PEDESTALS)

transfer_function_mean_values = [];
pedestals_channel_out_ADC_codes = [];
pedestals_channel_out_occurencies = [];
pedestals_mean_values_wo_mean = [];
pedestals_mean_values = [];
waveform_mean_values = [];
threshold_mean_values = [];
self_trigger_mean_values = [];
allDataSelfTrigger = [];
self_trigger_channel_out_ADC_codes = [];
pedestals_channel_out_ADC_codes2 = [];
allData = [];
pedestal_data_for_ch_mean = [];
meanData = [];

transfer_function_file_name = [folder_name 'data/TransferFunction_fast_tau'];
transfer_function_file_data = [folder_name 'data/TransferFunction.dat'];

pedestals_file_name = [folder_name 'data/Pedestals_tau'];
pedestals_file_data = [folder_name 'data/Pedestals.dat'];

waveform_scan_file_name = [folder_name 'data/WaveformScan_fast_tau'];
waveform_scan_file_data = [folder_name 'data/WaveformScan.dat'];

threshold_scan_file_name = [folder_name 'data/ThresholdScan_fthr'];
threshold_scan_file_data = [folder_name 'data/ThresholdScan.dat'];

self_trigger_file_name = [folder_name 'data/SelfTrigger_ch'];
self_trigger_file_data = [folder_name 'data/SelfTrigger.dat'];

%% TRANSFER FUNCTION
if exist(transfer_function_file_data,'file')
   transfer_function_mean_values=readmatrix(transfer_function_file_data);
else
    ne=1;
    for pt=0:7
    tf_file = [transfer_function_file_name int2str(pt) '.dat'];
        if ~exist(tf_file,'file')
            ne=0;
        end
 
    end
    if(ne)
        [transfer_function_mean_values] = import_TransferFunction(transfer_function_file_name, transfer_function_file_data);
    end
    
end

clear transfer_function_file_name transfer_function_file_data

%% PEDESTALS
% if (exist(pedestals_file_data,'file') && plot_PEDESTALS(1) == 0)
%     pedestals_mean_values=readmatrix(pedestals_file_data);
%     pedestals_channel_out_occurencies = pedestals_mean_values(:,10:end);
%     
%     pedestal_read_table=readtable(pedestals_file_data,'PreserveVariableNames',true);
%     x=string(pedestal_read_table.Properties.VariableNames);
%     x=x(10 : end);
%     x=split(x,"#");
%     pedestals_channel_out_ADC_codes=double(x(:,:,2));
%     clear pedestal_read_table x
% else
ne=1;
for pt=0:7
    tf_file = [pedestals_file_name int2str(pt) '.dat'];
    if ~exist(tf_file,'file')
        ne=0;
    end
    
end
if(ne)
    [pedestals_mean_values, pedestals_channel_out_ADC_codes, pedestals_mean_values_wo_mean, pedestals_channel_out_ADC_codes2, allData, pedestal_data_for_ch_mean, meanData] = import_Pedestals(pedestals_file_name, pedestals_file_data, plot_PEDESTALS(1));
    pedestals_channel_out_occurencies = pedestals_mean_values(:,10:end);
end
%
% end

clear pedestals_file_name pedestals_file_data

%% WAVEFORM SCAN
if exist(waveform_scan_file_data,'file')
   waveform_mean_values=readmatrix(waveform_scan_file_data);
else
    ne=1;
    for pt=0:7
    wf_file = [waveform_scan_file_name int2str(pt) '.dat'];
        if ~exist(wf_file,'file')
            ne=0;
        end
 
    end
    if(ne)
        [waveform_mean_values] = import_WaveformScan(waveform_scan_file_name, waveform_scan_file_data);
    end
    
end

clear waveform_scan_file_name waveform_scan_file_data

%% THRESHOLD SCAN
if exist(threshold_scan_file_data,'file')
    threshold_mean_values = readmatrix(threshold_scan_file_data);
else
    ne = 1;
    for pt = 0:7
        for fthr = 0:7
            ts_file = [threshold_scan_file_name int2str(fthr) '_tau' int2str(pt) '.dat'];
            if ~exist(ts_file,'file')
                ne = 0;
            end
        end
    end
    if(ne)
        [threshold_mean_values] = import_ThresholdScan(threshold_scan_file_name, threshold_scan_file_data);
    end
    
end

clear threshold_scan_file_name threshold_scan_file_data

%% SELF TRIGGER
if (exist(self_trigger_file_data,'file'))
    [self_trigger_mean_values, self_trigger_channel_out_ADC_codes, allDataSelfTrigger] = import_SelfTrigger(self_trigger_file_name, self_trigger_file_data);
else
    ne = 1;
    for ch = 0:31
        ts_file = [self_trigger_file_name int2str(ch) '.dat'];
        if ~exist(ts_file,'file')
            ne = 0;
        end
        
    end
    if(ne)
        [self_trigger_mean_values, self_trigger_channel_out_ADC_codes, allDataSelfTrigger] = import_SelfTrigger(self_trigger_file_name, self_trigger_file_data);
    end
end

