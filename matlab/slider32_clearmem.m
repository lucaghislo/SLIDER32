clearvars -except start stop iFolder folder_name type
% clc
addpath('matlab/functions_matlab/');

channels_to_not_consider = [];

%folder_name = '';
%% PEDESTALS VARIABLES
plot_normal_PEDESTALS_hist  = 1; %2 
plot_normal_PEDESTALS_byTime = 1; %3
plot_normal_PEDESTALS_byTime_ZOOM = 1; %4

plot_mean_PEDESTALS_hist  = 1; %5
plot_mean_PEDESTALS_byTime = 1; %6
plot_mean_PEDESTALS_byTime_ZOOM = 1; %7

plot_fit_PEDESTALS_hist  = 1; %8
plot_fit_PEDESTALS_byTime = 1; %9
plot_fit_PEDESTALS_byTime_ZOOM = 1; %10
plot_fit_normal_vs_mean = 1; %11

%1
calculate_mean_pedestals = plot_mean_PEDESTALS_hist || plot_mean_PEDESTALS_byTime || plot_mean_PEDESTALS_byTime_ZOOM || plot_fit_PEDESTALS_hist || plot_fit_PEDESTALS_byTime || plot_fit_PEDESTALS_byTime_ZOOM || plot_fit_normal_vs_mean;

calculate_fit = plot_fit_PEDESTALS_hist || plot_fit_PEDESTALS_byTime || plot_fit_PEDESTALS_byTime_ZOOM || plot_fit_normal_vs_mean;
plot_PEDESTALS = [calculate_mean_pedestals, plot_normal_PEDESTALS_hist, plot_normal_PEDESTALS_byTime, plot_normal_PEDESTALS_byTime_ZOOM, plot_mean_PEDESTALS_hist, plot_mean_PEDESTALS_byTime, plot_mean_PEDESTALS_byTime_ZOOM, plot_fit_PEDESTALS_hist, plot_fit_PEDESTALS_byTime, plot_fit_PEDESTALS_byTime_ZOOM, plot_fit_normal_vs_mean];

%% PLOT PEDESTALS FFT
plot_Pedestals_FFT = 1;

%% WAVEFORM SCAN
plot_Waveform_PT = 1;
plot_Waveform_CH = 1;

%% TRANSFER FUNCTION
plot_HIGH_GAIN = 1;
plot_TransferFunction_PT = 1; 
plot_TransferFunction_CH = 1;

%% ENC VARIABLES
plot_ENC_PT = 1; %1
plot_ENC_CH = 1; %2

plot_ENC_PT_wo_mean = 1; %3
plot_ENC_CH_wo_mean = 1; %4

plot_ENC_PT_wo_fit = 1; %5
plot_ENC_CH_wo_fit = 1; %6

plot_ENC = [plot_ENC_PT, plot_ENC_CH, plot_ENC_PT_wo_mean, plot_ENC_CH_wo_mean, plot_ENC_PT_wo_fit, plot_ENC_CH_wo_fit];

%% THRESHOLD SCAN VARIABLES
plot_ThresholdScan_CH_PT = 1; 
plot_ThresholdScan_PT_FTHR = 1;
plot_Dispersion_Minimization = 1;
plot_ThresholdScan_PT_FTHR_fitted = 1;
injected_CAL_Voltage = 1000; % \\\ questo valore sarebbe da tirar fuori da importAll
statistic_used = 'mean';

%% SELF TRIGGER
plot_self_trigger_hist = 1;
plot_self_trigger_byTime = 1;
plot_self_trigger_byTime_ZOOM = 1;
plot_SELF_TRIGGER = [plot_self_trigger_hist, plot_self_trigger_byTime, plot_self_trigger_byTime_ZOOM];

%%
[transfer_function_mean_values,pedestals_channel_out_ADC_codes,pedestals_channel_out_occurencies,pedestals_mean_values,waveform_mean_values,threshold_mean_values, pedestals_mean_values_wo_mean, pedestals_channel_out_ADC_codes2, pedestalAllData, pedestal_data_for_ch_mean, pedestalMeanData, self_trigger_mean_values, allDataSelfTrigger, self_trigger_channel_out_ADC_codes] = importAll(folder_name, plot_PEDESTALS);
if ~isempty(waveform_mean_values)
	real_peaking_times = find_peaking_times(waveform_mean_values, statistic_used, folder_name);
	disp('plot WAVEFORM SCAN - START');
    plot_WaveformScan(waveform_mean_values, injected_CAL_Voltage, real_peaking_times,  plot_Waveform_PT, plot_Waveform_CH, statistic_used, folder_name);
    disp('plot WAVEFORM SCAN - END');
else
    disp('Warning: WAVEFORM SCAN not found!');
end
clear waveform_mean_values real_peaking_times 

if ~isempty(transfer_function_mean_values)
    disp('plot TRANSFER FUNCTION - START');
	plot_TransferFunction(transfer_function_mean_values, plot_TransferFunction_PT, plot_TransferFunction_CH, statistic_used, folder_name);
	disp('plot TRANSFER FUNCTION - END');
    disp('calculate and plot HIGH GAIN - START');
    slopes_and_interceptes = find_low_energy_gain(transfer_function_mean_values, plot_HIGH_GAIN, statistic_used, folder_name);
    disp('plot HIGH GAIN - END');
else
    disp('Warning: TRANSFER FUNCTION not found!');
end
clear transfer_function_mean_values 

if ~isempty(pedestals_mean_values)
    disp('plot PEDESTAL - START');
    plot_Pedestals(pedestals_mean_values, pedestals_channel_out_ADC_codes, pedestals_mean_values_wo_mean, pedestals_channel_out_ADC_codes2, pedestalAllData, pedestalMeanData, pedestal_data_for_ch_mean, plot_PEDESTALS, channels_to_not_consider, folder_name)
    disp('plot PEDESTAL - END');
    if (calculate_fit == 1)
        [~,pedestals_mean_values_wo_fit] = pedestal_fit(pedestalAllData,pedestal_data_for_ch_mean, channels_to_not_consider, plot_PEDESTALS, folder_name);
    end
    if ~isempty(slopes_and_interceptes)
        disp('plot ENC - START');
        ENC(slopes_and_interceptes,pedestals_mean_values, plot_ENC, channels_to_not_consider, folder_name);
        disp('plot ENC - END');
        if calculate_mean_pedestals==1
            disp('plot ENC without mean - START');
            ENC_Pedestal_wo_mean(slopes_and_interceptes,pedestals_mean_values_wo_mean, plot_ENC, channels_to_not_consider, folder_name);
            disp('plot ENC without mean - END');
        end
        if calculate_fit == 1
            disp('plot ENC without fit - START');
            ENC_Pedestal_wo_fit(slopes_and_interceptes,pedestals_mean_values_wo_fit, plot_ENC, channels_to_not_consider, folder_name);
            disp('plot ENC without mean - END');
        end
    else
        disp('Warning: ENC can not be computed since TRANSFER FUNCTION was not found!');
    end
    if plot_Pedestals_FFT == 1 
        disp('plot FFT - START');
        plot_fft(pedestalAllData, folder_name)
        disp('plot FFT - END');
    end
else
    disp('Warning: PEDESTAL not found!');
end
clear pedestals_mean_values_wo_fit pedestals_mean_values pedestals_channel_out_occurencies pedestals_mean_values_wo_mean pedestal_data_for_ch_mean pedestals_channel_out_ADC_codes pedestals_channel_out_ADC_codes2 pedestalAllData pedestalMeanData slopes_and_interceptes

if ~isempty(threshold_mean_values)
	fitParameters = fit_ThresholdScan(threshold_mean_values, folder_name);
    disp('plot Threshold Scan - START');
	[graph_min, graph_max, threshold_dispersions] = plot_ThresholdScan(threshold_mean_values, fitParameters, plot_ThresholdScan_CH_PT, plot_ThresholdScan_PT_FTHR, plot_ThresholdScan_PT_FTHR_fitted, folder_name);
    disp('plot Threshold Scan - END');
    disp('plot Threshold Minimization - START');
    thresholdDispersionMinimization(fitParameters, threshold_dispersions, plot_Dispersion_Minimization, plot_ThresholdScan_PT_FTHR_fitted, graph_min, graph_max, statistic_used, folder_name)
    disp('plot Threshold Minimization - END');
else
    disp('Warning: Threshold Scan not found!');
end
clear fitParameters threshold_dispersions threshold_mean_values 

if ~isempty(self_trigger_mean_values)
    disp('plot Self Trigger - START');
    plot_SelfTrigger(self_trigger_mean_values, self_trigger_channel_out_ADC_codes, allDataSelfTrigger, plot_SELF_TRIGGER, channels_to_not_consider, folder_name)
    disp('plot Self Trigger - END');
else
    disp('Warning: Self Trigger not found!');
end
clear self_trigger_channel_out_ADC_codes self_trigger_mean_values allDataSelfTrigger