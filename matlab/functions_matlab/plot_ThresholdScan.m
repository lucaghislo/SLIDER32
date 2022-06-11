function [graph_min, graph_max, threshold_dispersions] = plot_ThresholdScan(threshold_mean_values, fitParameters, plot_ThresholdScan_CH_PT, plot_ThresholdScan_PT_FTHR, plot_ThresholdScan_PT_FTHR_fitted, folder_name)
fun = fittype(@(a,b,x) 50 + 50*erf((x - a)/(sqrt(2)*b)));
%% INPUT
% threshold_mean_values: dati mediati ottenuti dai file originali
% fitParameters: dati ottenuti dai fit
% folder_name: cartella della misura -> la cartella deve contenere le
%              cartelle data e analysis_matlab.
% plot_ThresholdScan_CH_PT: booleano per scegliere se plottare i dati per CH e PT
% plot_ThresholdScan_PT_FTR: booleano per scegliere se plottare i dati per PT e FTR

%% OUTPUT
% graph_min: valore asse x che viene utilizzato per i plot con
%            minimizzazione della dispersione di soglia
% graph_max: valore asse x che viene utilizzato per i plot con
%            minimizzazione della dispersione di soglia
% threshold_dispersions: questa funzione ritorna una matrice
%            length_peaking_time*(length_fine_thr + 4) con riportata la
%            dispersione di soglia al variare del tempo di picco e del fine
%            threshold. Le ultime 4 colonne vengono riempite nella funzione
%            thresholdDispersionMinimization. Le ultime quattro colonne
%            infatti riportano la dispersione di soglia minimizzata al variare del
%            tempo di picco.

%% VARIABLES INITIALIZATION
channels = unique(fitParameters(:,1));
length_channels = length(channels);
peaking_times = unique(fitParameters(:,2));
length_peaking_times = length(peaking_times);
% length_peaking_times = length(peaking_times);
fine_thr = unique(fitParameters(:,3));
length_fine_thr = length(fine_thr);
[max_value, index_max_value] = max(fitParameters(:,4));
[min_value, index_min_value] = min(fitParameters(:,4));

% graph_min = round(min_value - 5*fitParameters(index_min_value,5));
% graph_max = min([round(max_value + 5*fitParameters(index_max_value,5)), 255]);

graph_min = max([round(min_value - 25), min(threshold_mean_values(4,:))]);
graph_max = min([round(max_value + 25), 255]);

% sulle colonne: fthr0....fthr7, mean optimized, mean optimized without
% outliers, outliers, mean without outliers optimized
threshold_dispersions = zeros(length_peaking_times,length_fine_thr + 4);

%% CREAZIONE CARTELLE PER PLOT DATI
if ~exist([folder_name 'analysis_matlab/ThresholdScan'],'dir' )
    mkdir([folder_name 'analysis_matlab/ThresholdScan']);
    if(plot_ThresholdScan_CH_PT)
        mkdir([folder_name 'analysis_matlab/ThresholdScan/Plot_CH_PT']);
    end
    if(plot_ThresholdScan_PT_FTHR)
        mkdir([folder_name 'analysis_matlab/ThresholdScan/Plot_PT_FTHR']);
    end
    if(plot_ThresholdScan_PT_FTHR_fitted)
        mkdir([folder_name 'analysis_matlab/ThresholdScan/Plot_PT_FTHR_fitted']);
    end    
else
    if(plot_ThresholdScan_CH_PT && ~exist([folder_name 'analysis_matlab/ThresholdScan/Plot_CH_PT'],'dir' ))
       mkdir([folder_name 'analysis_matlab/ThresholdScan/Plot_CH_PT']);
    end
    if(plot_ThresholdScan_PT_FTHR && ~exist([folder_name 'analysis_matlab/ThresholdScan/Plot_PT_FTHR'],'dir' ))
       mkdir([folder_name 'analysis_matlab/ThresholdScan/Plot_PT_FTHR']);
    end
    if(plot_ThresholdScan_PT_FTHR_fitted && ~exist([folder_name 'analysis_matlab/ThresholdScan/Plot_PT_FTHR_fitted'],'dir' ))
       mkdir([folder_name 'analysis_matlab/ThresholdScan/Plot_PT_FTHR_fitted']);
    end    
end

%% PLOT PER CANALI E PER TEMPI DI PICCO
if(plot_ThresholdScan_CH_PT)
    for ch = channels'
        for pt = peaking_times'
            f = figure('visible', 'off');
            hold on
            grid on
                for ftr = fine_thr'
                    data = threshold_mean_values(threshold_mean_values(:,1)==ch & threshold_mean_values(:,2)==pt & threshold_mean_values(:,3) == ftr,:);
                    plot(data(:,4),(data(:,6)./data(:,5))*100)
                end
        
            title(['Threshold Scan of Channel #' num2str(ch) ' - \tau_{' num2str(pt) '}']);
            xlabel('Discriminator Threshold [DAC\_thr code]');
            ylabel('% hits');
            xlim([graph_min graph_max]);
            ylim([0 100]);
            ax = gca;
            ax.XAxis.Exponent = 0;
            f.WindowState = 'maximized';
            
            % get the original size of figure before the legends are added
            set(gcf, 'unit', 'inches');
            figure_size =  get(gcf, 'position');
            
            str1 = repmat('fin\_thr: ', length(fine_thr),1);
            str2 = num2str(dec2bin(fine_thr),'%03d');
            str = [str1 str2];

            svg_to_save = [ folder_name 'analysis_matlab/ThresholdScan/Plot_CH_PT/Ch ' num2str(ch) ' - Pt ' num2str(pt) '.'];
            % add legends and get its handle
            lg = legend(str,'Location','northeastoutside');
            % set unit for legend size to inches
            set(lg, 'unit', 'inches')
            % get legend size
            legend_size = get(lg, 'position');
            % new figure width
            figure_size(3) = figure_size(3) + legend_size(3);
            % set new figure size
            set(gcf, 'position', figure_size)
            save_image(svg_to_save, 'pdf', f)
            close
        end
    end
end

%% PLOT PER PER TEMPI DI PICCO E FINE THRESHOLD TRIMMING
if(plot_ThresholdScan_PT_FTHR)
    for fthr = fine_thr'
        for pt = peaking_times'
            f = figure('visible', 'off');
            hold on
            grid on
                for ch = channels'
                    data = threshold_mean_values(threshold_mean_values(:,1)==ch & threshold_mean_values(:,2)==pt & threshold_mean_values(:,3) == fthr,:);
                    plot(data(:,4),(data(:,6)./data(:,5))*100)
                end
            
            title(['Threshold Scan at \tau_{' num2str(pt) '} - fin\_thr ' num2str(fthr)]);
            xlabel('Discriminator Threshold [DAC\_thr code]');
            ylabel('% hits');
            xlim([graph_min graph_max]);
            ylim([0 100]);
            ax = gca;
            ax.XAxis.Exponent = 0;
            f.WindowState = 'maximized';
            
            % get the original size of figure before the legends are added
            set(gcf, 'unit', 'inches');
            figure_size =  get(gcf, 'position');
            
            str1 = repmat('Ch #', length(channels),1);
            str2 = num2str(channels);
            str = [str1 str2];

            svg_to_save = [ folder_name 'analysis_matlab/ThresholdScan/Plot_PT_FTHR/Pt ' num2str(pt) ' - fthr ' num2str(fthr) '.'];
            % add legends and get its handle
            lg = legend(str,'Location','northeastoutside');
            lg.NumColumns = 2;
            % set unit for legend size to inches
            set(lg, 'unit', 'inches')
            % get legend size
            legend_size = get(lg, 'position');
            % new figure width
            figure_size(3) = figure_size(3) + legend_size(3);
            % set new figure size
            set(gcf, 'position', figure_size)
            save_image(svg_to_save, 'pdf', f)
            close
        end
    end
end

%% FITTED PLOT PER TEMPI DI PICCO E FINE THRESHOLD TRIMMING
% in questa parte della funzione viene anche calcolata la dispersione di
% soglia al variare del tempo di picco e del fin_thr
idx_thr = 1;
for fthr = fine_thr'
    idx_pt = 1;
    for pt = peaking_times'
        if(plot_ThresholdScan_PT_FTHR_fitted)
            f = figure('visible', 'off');
            hold on
            grid on
        end
        idx_channel = 1;
        a_for_threshold_disp = zeros(length_channels,1);
        b_for_threshold_disp = zeros(length_channels,1);
        for ch = channels'
            x = fitParameters(:,1) == ch & fitParameters(:,2) == pt & fitParameters(:,3)==fthr;
            a_b = fitParameters(x,:);
            a = a_b(4);
            b = a_b(5);
            a_for_threshold_disp(idx_channel,1) = a;
            b_for_threshold_disp(idx_channel,1) = b;
            if(plot_ThresholdScan_PT_FTHR_fitted)
                fitted_min_plot = a - 5*b;
                fitted_max_plot = a + 5*b;
                x_axis = [graph_min fitted_min_plot:0.1:fitted_max_plot graph_max];
                y_axis = fun(a,b,x_axis);
                plot(x_axis,y_axis)
            end
            idx_channel = idx_channel + 1;
        end
        
        threshold_dispersion = std(a_for_threshold_disp);
        threshold_dispersions(idx_pt,idx_thr) = threshold_dispersion;
        if(plot_ThresholdScan_PT_FTHR_fitted)
            annotation('textbox', [0.15 0.7 0.1 0.1], 'String', ['Threshold Dispersion: ', num2str(threshold_dispersion,'%5.3f'), ' [DAC\_thr code]'],'FitBoxToText','on', 'BackgroundColor','white')
            title(['Threshold Scan at \tau_{' num2str(pt) '} - fin\_thr ' num2str(fthr)]);
            xlabel('Discriminator Threshold [DAC\_thr code]');
            ylabel('% hits');
            xlim([graph_min graph_max]);
            ylim([0 100]);
            ax = gca;
            ax.XAxis.Exponent = 0;
            f.WindowState = 'maximized';
            
            % get the original size of figure before the legends are added
            set(gcf, 'unit', 'inches');
            figure_size =  get(gcf, 'position');
            
            str1 = repmat('Ch #', length_channels,1);
            str2 = num2str(channels,'%02d');
            str3 = repmat(' (a: ', length_channels,1);
            str4 = num2str(a_for_threshold_disp,'%5.2f');
            str5 = repmat(' - b: ', length_channels,1);
            str6 = num2str(b_for_threshold_disp,'%4.2f');
            str7 = repmat(')', length_channels,1);
            str = [str1, str2, str3, str4, str5, str6, str7];
            legend(str,'Location','northeastoutside');
            
            svg_to_save = [ folder_name 'analysis_matlab/ThresholdScan/Plot_PT_FTHR_fitted/Pt ' num2str(pt) ' - fthr ' num2str(fthr) '.'];
            % add legends and get its handle
            lg = legend(str,'Location','northeastoutside');
            % set unit for legend size to inches
            set(lg, 'unit', 'inches')
            % get legend size
            legend_size = get(lg, 'position');
            % new figure width
            figure_size(3) = figure_size(3) + legend_size(3);
            % set new figure size
            set(gcf, 'position', figure_size)
            save_image(svg_to_save, 'pdf', f)
            close
        end
        idx_pt = idx_pt + 1;
    end
    idx_thr = idx_thr + 1;
end

end
