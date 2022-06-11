function [transfer_function_mean_values,pedestals_channel_out_ADC_codes,pedestals_channel_out_occurencies,pedestals_mean_values,waveform_mean_values,threshold_mean_values] = importAll(folder_name)

transfer_function_mean_values = [];
pedestals_channel_out_ADC_codes = [];
pedestals_channel_out_occurencies = [];
pedestals_mean_values = [];
waveform_mean_values = [];
threshold_mean_values = [];

transfer_function_file_name = [folder_name 'data\TransferFunction_fast_tau'];
transfer_function_file_data = [folder_name 'data\TransferFunction.dat'];

pedestals_file_name = [folder_name 'data\Pedestals_tau'];
pedestals_file_data = [folder_name 'data\Pedestals.dat'];

waveform_scan_file_name = [folder_name 'data\WaveformScan_fast_tau'];
waveform_scan_file_data = [folder_name 'data\WaveformScan.dat'];

threshold_scan_file_name = [folder_name 'data\ThresholdScan_fthr'];
threshold_scan_file_data = [folder_name 'data\ThresholdScan.dat'];

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
if (exist(pedestals_file_data,'file'))
    pedestals_mean_values=readmatrix(pedestals_file_data);
    pedestals_channel_out_occurencies = pedestals_mean_values(:,10:end);
    
    pedestal_read_table=readtable(pedestals_file_data,'PreserveVariableNames',true);
    x=string(pedestal_read_table.Properties.VariableNames);
    x=x(10 : end);
    x=split(x,"#");
    pedestals_channel_out_ADC_codes=double(x(:,:,2));
    clear pedestal_read_table x
else
    ne=1;
    for pt=0:7
    tf_file = [pedestals_file_name int2str(pt) '.dat'];
        if ~exist(tf_file,'file') 
            ne=0;
        end
 
    end
    if(ne)
        [pedestals_mean_values, pedestals_channel_out_ADC_codes1] = import_Pedestals(pedestals_file_name, pedestals_file_data, calculate_mean_pedestals);
		pedestals_channel_out_occurencies = pedestals_mean_values(:,10:end);
    end
    
end

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
end

