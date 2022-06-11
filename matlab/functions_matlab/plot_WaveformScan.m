function plot_WaveformScan(waveform_mean_values, injected_CAL_Voltage, real_peaking_times,  plot_Waveform_PT, plot_Waveform_CH, statistic_used, folder_name)
%% INPUT
% waveform_mean_values: dati mediati ottenuti dai file originali
% injected_CAL_Voltage: valore della carica iniettata in DAC_inj code
% tempi di picco: 8 righe (tempi di picco) * 32 colonne (canali)
% folder_name: cartella della misura -> la cartella deve contenere le
%              cartelle data e analysis_matlab.
% plot_PT: booleano per scegliere se plottare i dati per PT
% plot_CH: booleano per scegliere se plottare i dati per CH
% statistic_used: scegliere che tipo di peaking time utilizzare nei
%       plot: 'mean' usa i valori mediati, 'mean_wo_out' usa i valori 
%       mediati senza outliers, (median non è stato implementato, al posto
%       di median viene usato mean_wo_outliers)

%% CREAZIONE CARTELLE PER PLOT DATI
if ~exist([folder_name 'analysis_matlab/WaveformScan'],'dir' )
    mkdir([folder_name 'analysis_matlab/WaveformScan']);
    if(plot_Waveform_PT)
        mkdir([folder_name 'analysis_matlab/WaveformScan/Plot_PT']);
    end
    if(plot_Waveform_CH)
        mkdir([folder_name 'analysis_matlab/WaveformScan/Plot_CH']);
    end
else
    if(plot_Waveform_PT && ~exist([folder_name 'analysis_matlab/WaveformScan/Plot_PT'],'dir' ))
       mkdir([folder_name 'analysis_matlab/WaveformScan/Plot_PT']);
    end
    if(plot_Waveform_CH && ~exist([folder_name 'analysis_matlab/WaveformScan/Plot_CH'],'dir' ))
       mkdir([folder_name 'analysis_matlab/WaveformScan/Plot_CH']);
    end
end

channels = unique(waveform_mean_values(:,1));
peaking_times = unique(waveform_mean_values(:,2));
max_value = max(waveform_mean_values(:,8));
min_value = min(waveform_mean_values(:,1));

graph_max = round(max_value + 50, -2);
graph_min = round(min_value - 50, -2);
if graph_min < 0
    graph_min = 0;
end

%% PLOT PER CANALI
if(plot_Waveform_CH)
    for ch = channels'
        f = figure('visible', 'off');
        hold on
        grid on
        for pt = peaking_times'
            data = waveform_mean_values(waveform_mean_values(:,1)==ch & waveform_mean_values(:,2)==pt,:);
            if strcmp(statistic_used,'mean')
                plot(data(:,3)./48,data(:,4))
            elseif strcmp(statistic_used,'median')
                plot(data(:,3)./48,data(:,6))
            else
                plot(data(:,3)./48,data(:,8))
            end
        end
        title(['Waveform Scan of Channel #' num2str(ch) ' - ' num2str(injected_CAL_Voltage) ' DAC\_inj code']);
        xlabel('t [\mus]');
        ylabel('Channel\_out [ADC code]');
        xlim([data(1,3)/48 data(end,3)/48]);
        ylim([graph_min graph_max]);
        f.WindowState = 'maximized';
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');

        
        
        str1 = repmat('\tau_{',length(peaking_times),1);
        str2 = num2str(peaking_times);
        str3 = repmat('}',length(peaking_times),1);
        str4 = repmat('  (\tau_{p} ',length(peaking_times),1);
        str5 = num2str(real_peaking_times(:,ch + 1),'%3.2f');
        str6 = repmat(' \mus)',length(peaking_times),1);
        
        str = [str1 str2 str3 str4 str5 str6];
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
 
        svg_to_save = [ folder_name 'analysis_matlab/WaveformScan/Plot_CH/Ch ' num2str(ch) '.'];
        save_image(svg_to_save, 'pdf', f)
        close
    end
end

%% PLOT PER PEAKING TIMES
if(plot_Waveform_PT)
    for pt = peaking_times'
        f = figure('visible', 'off');
        hold on
        grid on
        for ch = channels'
            data = waveform_mean_values(waveform_mean_values(:,1)==ch & waveform_mean_values(:,2)==pt,:);
            if strcmp(statistic_used,'mean')
                plot(data(:,3)./48,data(:,4))
            elseif strcmp(statistic_used,'median')
                plot(data(:,3)./48,data(:,6))
            else
                plot(data(:,3)./48,data(:,8))
            end
        end

        set(gca,'FontName','Helvetica');
        title(['Waveform Scan for \tau_{' num2str(pt) '} - ' num2str(injected_CAL_Voltage) ' DAC\_inj code']);
        xlabel('t [\mus]');
        ylabel('Channel\_out [ADC code]');
        xlim([data(1,3)/48 data(end,3)/48]);
        ylim([graph_min graph_max]);
        f.WindowState = 'maximized';
        
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
        str_1 = repmat('Ch #',length(channels),1);
        str_2 = num2str(channels,'%02d');
        str_3 = repmat('  (\tau_{p} ',length(channels),1);
        str_4 = repmat(' \mus)',length(channels),1);
        str = [str_1 str_2 str_3 num2str(real_peaking_times(pt + 1,:)','%3.2f') str_4];
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
        
        svg_to_save = [ folder_name 'analysis_matlab/WaveformScan/Plot_PT/Pt ' num2str(pt) '.'];
        save_image(svg_to_save, 'pdf', f)
        close
    end
end

end

