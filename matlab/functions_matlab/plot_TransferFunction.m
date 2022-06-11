function plot_TransferFunction(transfer_function_mean_values, plot_TransferFunction_PT, plot_TransferFunction_CH, statistic_used, folder_name)

%% INPUT
% tranfer_function_mean_values: dati mediati ottenuti dai file originali
% folder_name: cartella della misura -> la cartella deve contenere le
%              cartelle data e analysis_matlab.
% plot_TransferFunction_PT: booleano per scegliere se plottare i dati per PT
% plot_TransferFunction_CH: booleano per scegliere se plottare i dati per CH
% statistic_used: scegliere che tipo di peaking time utilizzare nei
%       plot: 'mean' usa i valori mediati, 'mean_wo_out' usa i valori 
%       mediati senza outliers, (median non è stato implementato, al posto
%       di median viene usato mean_wo_outliers)

%% CREAZIONE CARTELLE PER PLOT DATI
if ~exist([folder_name 'analysis_matlab/TransferFunction'],'dir' )
    mkdir([folder_name 'analysis_matlab/TransferFunction']);
    if(plot_TransferFunction_PT)
        mkdir([folder_name 'analysis_matlab/TransferFunction/Plot_PT']);
    end
    if(plot_TransferFunction_CH)
        mkdir([folder_name 'analysis_matlab/TransferFunction/Plot_CH']);
    end
else
    if(plot_TransferFunction_PT && ~exist([folder_name 'analysis_matlab/TransferFunction/Plot_PT'],'dir' ))
       mkdir([folder_name 'analysis_matlab/TransferFunction/Plot_PT']);
    end
    if(plot_TransferFunction_CH && ~exist([folder_name 'analysis_matlab/TransferFunction/Plot_CH'],'dir' ))
       mkdir([folder_name 'analysis_matlab/TransferFunction/Plot_CH']);
    end    
end

channels = unique(transfer_function_mean_values(:,1));
peaking_times = unique(transfer_function_mean_values(:,2));
max_value = max(transfer_function_mean_values(:,4));
min_value = min(transfer_function_mean_values(:,4));

graph_max = round(max_value + 20, -2);
graph_min = round(min_value - 20, -2);
% + e - 20 è messo abbastanza a caso

if graph_min < 0
    graph_min = 0;
end

%% PLOT PER CANALI
if(plot_TransferFunction_CH)
    for ch = channels'
        f = figure('visible','off');
        hold on
        grid on
        for pt = peaking_times'
            data = transfer_function_mean_values(transfer_function_mean_values(:,1)==ch & transfer_function_mean_values(:,2)==pt,:);
            if strcmp(statistic_used,'mean')
                plot(data(:,3),data(:,4))
            elseif strcmp(statistic_used,'median')
                plot(data(:,3),data(:,6))
            else
                plot(data(:,3),data(:,8))
            end
        end
        title(['Transfer Function of Channel #' num2str(ch)]);
        xlabel('CAL\_Voltage [DAC\_inj Code]');
        ylabel('Channel\_out [ADC code]');
        xlim([data(1,3) data(end,3)]);
        ylim([graph_min graph_max]);
        ax = gca;
        ax.XAxis.Exponent = 0;
        f.WindowState = 'maximized';
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
        str1 = repmat('\tau_{',length(peaking_times),1);
        str2 = num2str(peaking_times);
        str3 = repmat('}',length(peaking_times),1);
        
        str = [str1 str2 str3];
%         str1 = repmat('\tau ', length(peaking_times),1);
%         str2 = num2str(peaking_times);
%         str = [str1 str2];
        
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
        svg_to_save = [ folder_name 'analysis_matlab/TransferFunction/Plot_CH/Ch ' num2str(ch) '.'];
        save_image(svg_to_save, 'pdf', f)
        close
    end
end

%% PLOT PER PEAKING TIMES
if(plot_TransferFunction_PT)
    for pt = peaking_times'
        f = figure('visible','off');
        hold on
        grid on
        for ch = channels'
            data = transfer_function_mean_values(transfer_function_mean_values(:,1)==ch & transfer_function_mean_values(:,2)==pt,:);
            if strcmp(statistic_used,'mean')
                plot(data(:,3),data(:,4))
            elseif strcmp(statistic_used,'median')
                plot(data(:,3),data(:,6))
            else
                plot(data(:,3),data(:,8))
            end
        end
        title(['Transfer Function for \tau_{' num2str(pt) '} ']);
        xlabel('CAL\_Voltage [DAC\_inj Code]');
        ylabel('Channel\_out [ADC code]');
        xlim([data(1,3) data(end,3)]);
        ylim([graph_min graph_max]);
        ax = gca;
        ax.XAxis.Exponent = 0;
        f.WindowState = 'maximized';
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
               
        str_1 = repmat('Ch #',length(channels),1);
        str_2 = num2str(channels,'%02d');
        str = [str_1 str_2];
        
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
        svg_to_save = [ folder_name 'analysis_matlab/TransferFunction/Plot_PT/Pt ' num2str(pt) '.'];
        
        save_image(svg_to_save, 'pdf', f)
        close
    end
end

end

