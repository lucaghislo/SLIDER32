function [slopes_and_interceptes] = find_low_energy_gain(transfer_function_mean_values, Plot_HIGH_GAIN, statistic_used, folder_name)
%% INPUT
% transfer_function_mean_values: dati mediati ottenuti dai file originali
% statistic_used: scegliere che tipo di peaking time utilizzare nei
%       plot: 'mean' usa i valori mediati, 'mean_wo_out' usa i valori 
%       mediati senza outliers, (median non è stato implementato, al posto
%       di median viene usato mean_wo_outliers)
% plot_HIGH_GAIN: booleano per scegliere se plottare i dati per PT
% folder_name: cartella della misura -> la cartella deve contenere le
%              cartelle data e analysis_matlab.

% \\\ AGGIUNGERE IL CARICAMENTO DA FILE DEI GUADAGNI (SE SON GIà STATI
% \\\ CALCOLATI.
%% PLOT
min_fit_value = 50;
max_fit_value = 100;
min_fit_value_cubica = 0;
max_fit_value_cubica = 500;

w = linspace(0,max_fit_value_cubica,1000); % servono per i plot dei fit

channels = unique(transfer_function_mean_values(:,1));
length_channels = length(channels);

peaking_times = unique(transfer_function_mean_values(:,2));
length_peaking_times = length(peaking_times);

% channel, peaking_time, slope_mean, intercept_mean, R^2_mean,
% residui_mean, slope_mean_wo_outliers, intercept_mean_wo_outliers, 
% R^2_mean_wo_outliers, residui_mean_wo_outliers, slope_cubica_mean,
% intercept_cubica_mean, estimated_R^2_cubica_mean,
% estimated_R^2_cubica_mean_wo_outliers
slopes_and_interceptes = zeros(length_channels*length_peaking_times,18);

%% CREAZIONE CARTELLE PER PLOT DATI
if ~exist([folder_name 'analysis_matlab/TransferFunction'],'dir' )
    mkdir([folder_name 'analysis_matlab/TransferFunction']);
    if(Plot_HIGH_GAIN)
        mkdir([folder_name 'analysis_matlab/TransferFunction/Plot_High_Gain']);
    end
else
    if(Plot_HIGH_GAIN && ~exist([folder_name 'analysis_matlab/TransferFunction/Plot_High_Gain'],'dir' ))
       mkdir([folder_name 'analysis_matlab/TransferFunction/Plot_High_Gain']);
    end  
end

%% FIND SLOPES AND PLOT
for ch = channels'
    for pt = peaking_times'
        % ----------------------------------------------------------------
        % DATI PER FIT LINEARE (Sia MEAN che MEAN_WO_OUTLIERS)
        data = transfer_function_mean_values(transfer_function_mean_values(:,1)==ch & transfer_function_mean_values(:,2)==pt & transfer_function_mean_values(:,3) < max_fit_value & transfer_function_mean_values(:,3) > min_fit_value,:);
        x = data(:,3);
        
        % DATI PER IL FIT LINEARE - BASATO SUI MEAN
        % I fit vengono eseguiti nel range [min_fit_value, max_fit_value]
        y_mean = data(:,4);
        [m_q_mean, fit_results_mean] = polyfit(x,y_mean,1);
        yfit_mean = polyval(m_q_mean, x);
        yresid_mean = y_mean - yfit_mean;
        SSresid_mean = sum(yresid_mean.^2);
        SStotal_mean = (length(y_mean)-1) * var(y_mean);
        rsq_mean = 1 - SSresid_mean/SStotal_mean;
        linear_fit_mean = [m_q_mean(1), m_q_mean(2), rsq_mean, fit_results_mean.normr];
        
        % DATI PER IL FIT LINEARE - BASATO SUI MEAN WITHOUT OUTLIERS
        % I fit vengono eseguiti nel range [min_fit_value, max_fit_value]        
        y_mean_wo_out = data(:,8);
        [m_q_mean_wo_out, fit_results_mean_wo_out] = polyfit(x,y_mean_wo_out,1);
        yfit_mean_wo_out = polyval(m_q_mean_wo_out,x);
        yresid_mean_wo_out = y_mean_wo_out - yfit_mean_wo_out;
        SSresid_mean_wo_out = sum(yresid_mean_wo_out.^2);
        SStotal_mean_wo_out = (length(y_mean_wo_out)-1) * var(y_mean_wo_out);
        rsq_mean_wo_out = 1 - SSresid_mean_wo_out/SStotal_mean_wo_out;
        linear_fit_mean_wo_out = [m_q_mean_wo_out(1), m_q_mean_wo_out(2), rsq_mean_wo_out, fit_results_mean_wo_out.normr];
        % ----------------------------------------------------------------
      
        
        % ----------------------------------------------------------------        
        % DATI PER FIT CON CUBICA (Sia MEAN che MEAN_WO_OUTLIERS)
        data3 = transfer_function_mean_values(transfer_function_mean_values(:,1)==ch & transfer_function_mean_values(:,2)==pt & transfer_function_mean_values(:,3) < max_fit_value_cubica & transfer_function_mean_values(:,3) > min_fit_value_cubica,:);
        x3 = data3(:,3);  
        
        % DATI PER IL FIT CON UNA CUBICA - BASATO SUI MEAN
        % I fit vengono eseguiti nel range [min_fit_value_cubica, max_fit_value_cubica].     
        y3_mean = data3(:,4);
        [m_q_mean3, fit_results_mean3] = polyfit(x3(2:end),y3_mean(2:end),3);
        y3fit_mean = polyval(m_q_mean3, x3);
        y3resid_mean = y3_mean - y3fit_mean;
        SSresid3_mean = sum(y3resid_mean.^2);
        SStotal3_mean = (length(y3_mean)-1) * var(y3_mean);
        % rsq3_mean = 1 - SSresid3_mean/SStotal3_mean;        
        rsq3_adj_mean = 1 - SSresid3_mean/SStotal3_mean * (length(y3_mean)-1)/(length(y3_mean)-length(m_q_mean3));
        cubic_fit_mean = [m_q_mean3(3), m_q_mean3(4), rsq3_adj_mean, fit_results_mean3.normr];
        
        % DATI PER IL FIT CON UNA CUBICA - BASATO SUI MEAN WITHOUT OUTLIERS
        % I fit vengono eseguiti nel range [min_fit_value_cubica, max_fit_value_cubica].     
        y3_mean_wo_outliers = data3(:,8);
        [m_q_mean3_wo_outliers, fit_results_mean3_wo_outliers] = polyfit(x3(2:end),y3_mean_wo_outliers(2:end),3);
        y3fit_mean_wo_outliers = polyval(m_q_mean3_wo_outliers, x3);
        y3resid_mean_wo_outliers = y3_mean_wo_outliers - y3fit_mean_wo_outliers;
        SSresid3_mean_wo_outliers = sum(y3resid_mean_wo_outliers.^2);
        SStotal3_mean_wo_outliers = (length(y3_mean_wo_outliers)-1) * var(y3_mean_wo_outliers);
        % rsq3_mean = 1 - SSresid3_mean/SStotal3_mean;        
        rsq3_adj_mean_wo_outliers = 1 - SSresid3_mean_wo_outliers/SStotal3_mean_wo_outliers * (length(y3_mean_wo_outliers)-1)/(length(y3_mean_wo_outliers)-length(m_q_mean3_wo_outliers));        
        cubic_fit_mean_wo_outliers = [m_q_mean3_wo_outliers(3), m_q_mean3_wo_outliers(4), rsq3_adj_mean_wo_outliers, fit_results_mean3_wo_outliers.normr];       
        % ----------------------------------------------------------------

        
        % ----------------------------------------------------------------        
        % DATI PER I PLOT
        % I dati vengono plottati da 0 a max_fit_value_cubica.
        data_to_plot = transfer_function_mean_values(transfer_function_mean_values(:,1)==ch & transfer_function_mean_values(:,2)==pt & transfer_function_mean_values(:,3) < max_fit_value_cubica,:);
        x_to_plot = data_to_plot(:,3);
        y_to_plot = data_to_plot(:,4);
        % ----------------------------------------------------------------
        
        
        pos = ch*length_peaking_times + pt + 1;
        value = [ch, pt, linear_fit_mean, linear_fit_mean_wo_out, cubic_fit_mean, cubic_fit_mean_wo_outliers];
        slopes_and_interceptes(pos,:) = value;
        
        if(Plot_HIGH_GAIN)
            f = figure('visible', 'off');
            scatter(x_to_plot,y_to_plot,'MarkerEdgeColor',[0 0.4470 0.7410])
            hold on
            grid on
            if strcmp(statistic_used,'mean')
                fun1 = @(x)m_q_mean3(1)*x.^3 + m_q_mean3(2).*x.^2 + m_q_mean3(3).*x + m_q_mean3(4);
                fun2 = @(x)m_q_mean(1)*x + m_q_mean(2);
                plot(w,fun2(w),'Color',[0.9290 0.6940 0.1250],'LineWidth',0.85);
                plot(w,fun1(w),'Color',[0.8500 0.3250 0.0980],'LineWidth',0.85);
            else
                fun1 = @(x)m_q_mean3_wo_outliers(1)*x.^3 + m_q_mean3_wo_outliers(2).*x.^2 + m_q_mean3_wo_outliers(3).*x + m_q_mean3_wo_outliers(4);
                fun2 = @(x)m_q_mean_wo_out(1)*x + m_q_mean_wo_out(2);
                plot(w,fun2(w),'Color',[0.9290 0.6940 0.1250],'LineWidth',0.85);
                plot(w,fun1(w),'Color',[0.8500 0.3250 0.0980],'LineWidth',0.85);                
            end
            title(['Low Energy Gain - Channel #' num2str(ch) ' - \tau_{' num2str(pt) '}']);
            xlabel('CAL\_Voltage [DAC\_inj code]')
            ylabel('Channel\_out [ADC code]')
            legend({'Original data','Linear fit', 'Cubic fit'},'Location','northwest')
            set(gcf, 'units', 'normalized');
            set(gcf, 'Position', [.15, .15, .7, .7]);
            str1 = sprintf('cubic fit: f(x) = %3.2e x^3 + %3.2e x^2 + %4.3f x + %4.3f', m_q_mean3);
            str2 = sprintf('linear fit: f(x) = %4.3f x + %4.3f', m_q_mean);
            str = {str2, str1};
            annotation('textbox', [.5 .075 .6 .175], 'String',str,'FitBoxToText','on')
            svg_to_save = [folder_name 'analysis_matlab/TransferFunction/Plot_High_Gain/Ch ' num2str(ch)  ' - Pt ' num2str(pt) '.pdf'];
            set(f, 'PaperUnits','centimeters');
            set(f, 'Units','centimeters');
            pos=get(f,'Position');
            set(f, 'PaperSize', [pos(3) pos(4)]);
            set(f, 'PaperPositionMode', 'manual');
            set(f, 'PaperPosition',[0 0 pos(3) pos(4)]);
            print(svg_to_save,'-dpdf')
            close
        end
    end
end

%% SAVE FILE - High Gain at Low Energies
fileID = fopen([folder_name 'analysis_matlab/TransferFunction/Low_Energy_Gain.dat'],'w');
fprintf(fileID,'%s\r\n','GAIN AT LOW ENERGIES');
fprintf(fileID,'-----------------------------------------------------------------\r\n');
fprintf(fileID,'Linear Fit in range [%s - %s] DAC_inj code\r\n',num2str(min_fit_value), num2str(max_fit_value));
fprintf(fileID,'Cubic Fit in range [%s - %s] DAC_inj code\r\n',num2str(min_fit_value_cubica), num2str(max_fit_value_cubica));
fprintf(fileID,'-----------------------------------------------------------------\r\n');
fprintf(fileID,'INDEX\r\n');
fprintf(fileID,'l_g_m: Gain obtained with linear fit and mean values\r\n');
fprintf(fileID,'l_i_m: Intercept obtained with linear fit and mean values\r\n');
fprintf(fileID,'l_r2_m: R^2 obtained with linear fit and mean values\r\n');
fprintf(fileID,'l_rs_m: Residuals obtained with linear fit and mean values\r\n');
fprintf(fileID,'l_g_mwo: Gain obtained with linear fit and mean values without outliers\r\n');
fprintf(fileID,'l_i_mwo: Intercept obtained with linear fit and mean values without outliers\r\n');
fprintf(fileID,'l_r2_mwo: R^2 obtained with linear fit and mean values without outliers\r\n');
fprintf(fileID,'l_rs_mwo: Residuals obtained with linear fit and mean values without outliers\r\n');

fprintf(fileID,'3_g_m: Gain obtained in x=0 with cubic fit and mean values\r\n');
fprintf(fileID,'3_i_m: Intercept obtained with cubic fit and mean values\r\n');
fprintf(fileID,'3_r2_m: Adjusted R^2 (adjusted for cubic fit) obtained with cubic fit and mean values\r\n');
fprintf(fileID,'3_rs_m: Residuals obtained with cubic fit and mean values\r\n');
fprintf(fileID,'3_g_mwo: Gain obtained in x=0 with cubic fit and mean values without outliers\r\n');
fprintf(fileID,'3_i_mwo: Intercept obtained with cubic fit and mean values without outliers\r\n');
fprintf(fileID,'3_r2_mwo: Adjusted R^2 (adjusted for cubic fit) obtained with cubic fit and mean values without outliers\r\n');
fprintf(fileID,'3_rs_mwo: Residuals obtained with cubic fit and mean values without outliers\r\n');
fprintf(fileID,'-----------------------------------------------------------------\r\n');
format = '';
for i = 1:18
    format = strcat(format,'%s\t');
end
format = format(1:length(format)-2);
format = strcat(format,'\r\n');
fprintf(fileID, format,'ch','pt', 'l_g_m', 'l_i_m', 'l_r2_m', 'l_rs_m', 'l_g_mwo', 'l_i_mwo', 'l_r2_mwo', 'l_rs_mwo', '3_g_m', '3_i_m', '3_r2_m', '3_rs_m', '3_g_mwo', '3_i_mwo', '3_r2_mwo', '3_rs_mwo');

format = '';
for i = 1:4
    format = strcat(format,'%5.3f\t%6.3f\t%5.4f\t%5.3f\t');
end
format = format(1:length(format)-2);
format = strcat(format,'\r\n');
format = strcat('%2d\t%2d\t',format);
fprintf(fileID,format,slopes_and_interceptes');
fclose(fileID);
end

