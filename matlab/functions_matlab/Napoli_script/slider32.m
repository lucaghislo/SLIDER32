clear all
clc
addpath('./functions_matlab/');

folder_name = '01\';
nc_channels = [29];

%% PEDESTALS VARIABLES
plot_PEDESTALS = zeros(1,11);

%% ENC VARIABLES
plot_ENC_PT = 1; %1
plot_ENC_CH = 1; %2

plot_ENC = [plot_ENC_PT, plot_ENC_CH, 0, 0, 0, 0];

%% CODICE
injected_CAL_Voltage = 1000;
statistic_used = 'mean';

[transfer_function_mean_values,pedestals_channel_out_ADC_codes,pedestals_channel_out_occurencies,pedestals_mean_values,waveform_mean_values,threshold_mean_values] = importAll(folder_name);

if ~isempty(transfer_function_mean_values)
	slopes_and_interceptes = find_low_energy_gain(transfer_function_mean_values, statistic_used, folder_name);
end

if ~isempty(pedestals_mean_values)
    if exist('transfer_function_mean_values','var')
        ENCs = ENC(slopes_and_interceptes,pedestals_mean_values, plot_ENC, nc_channels, folder_name);
    end
end
