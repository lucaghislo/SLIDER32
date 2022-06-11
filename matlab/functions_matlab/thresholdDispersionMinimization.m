function thresholdDispersionMinimization(fitParameters, threshold_dispersions, plot_Dispersion_Minimization, plot_ThresholdScan_PT_FTHR_fitted, graph_min, graph_max, statistic_used,  folder_name)
fun = fittype(@(a,b,x) 50 + 50*erf((x - a)/(sqrt(2)*b)));

%% CREAZIONE CARTELLE PER PLOT DATI
if ~exist([folder_name 'analysis_matlab/ThresholdScan'],'dir' )
    mkdir([folder_name 'analysis_matlab/ThresholdScan']); 
    if(plot_Dispersion_Minimization)
        mkdir([folder_name 'analysis_matlab/ThresholdScan/Plot_Disp_Minimization']);
    end
else
    if(plot_Dispersion_Minimization && ~exist([folder_name 'analysis_matlab/ThresholdScan/Plot_Disp_Minimization'],'dir' ))
       mkdir([folder_name 'analysis_matlab/ThresholdScan/Plot_Disp_Minimization']);
    end
end

%% VARIABLES INITIALIZATION
channels = unique(fitParameters(:,1));
length_channels = length(channels);
peaking_times = unique(fitParameters(:,2));
length_peaking_times = length(peaking_times);
fine_thresholds = unique(fitParameters(:,3));
length_fine_thresholds = length(fine_thresholds);

a_mean_fixed = mean(fitParameters(:,4));
[data_without_outliers, boolean_outliers] = rmoutliers(fitParameters(:,4));
a_mean_wo_outliers_fixed = mean(data_without_outliers);

fin_thr_minimization = zeros(length_channels*length_peaking_times,4);

%% THRESHOLD DISPERSION MINIMIZATION
% Calcolo della fine threshold per ogni canale
if exist([folder_name 'analysis_matlab/ThresholdScan/Thr_disp_minimization_fine_thresholds.dat'],'file')
    fin_thr_minimization = readmatrix([folder_name 'analysis_matlab/ThresholdScan/Thr_disp_minimization_fine_thresholds.dat']);
else
    for ch = channels'
        idx_ch = find(ch == channels);
        for pt = peaking_times'
            idx_pt = find(pt == peaking_times);
            a_mean = fitParameters(fitParameters(:,1) == ch & fitParameters(:,2) == pt,4);
            a_diff = a_mean - a_mean_fixed;
            a_diff_wo_out = a_mean - a_mean_wo_outliers_fixed;
            [a_diff_min, idx_fin_thr] = min(abs(a_diff));
            [a_diff_min_wo, idx_fin_thr_wo] = min(abs(a_diff_wo_out));
            
            pos = (idx_ch - 1)*length_peaking_times + idx_pt;
            value = [ch, pt, idx_fin_thr - 1, idx_fin_thr_wo - 1];
            fin_thr_minimization(pos,:) = value;
        end
    end
end
%% PLOT HISTOGRAMS
fixed_fine_threshold = 4;
for pt = peaking_times'
    f = figure('visible','off');
    fixed_data = fitParameters(fitParameters(:,2) == pt & fitParameters(:,3) == fixed_fine_threshold,4);
    graph_max = max(fixed_data);
    graph_min = min(fixed_data);
    graph_steps = ((round(graph_min)-0.5):(round(graph_max) + 0.5));  
    histogram(fixed_data,graph_steps);
    hold on
    data =  fitParameters(fitParameters(:,2)==pt,:);
    data_to_plot = zeros(length_channels,1);
    for ch = channels'
        fine_thr = fin_thr_minimization(fin_thr_minimization(:,1) == ch & fin_thr_minimization(:,2) == pt,3);
        data_to_plot(ch + 1) = data(data(:,1) == ch & data(:,3) == fine_thr,4);
    end
    histogram(data_to_plot,graph_steps); 
    f.WindowState = 'maximized';
    
    % get the original size of figure before the legends are added
    set(gcf, 'unit', 'inches');
    figure_size =  get(gcf, 'position');
            
    xlabel('Discriminator Threshold [DAC\_inj code]')
    ylabel('Occurencies') 
    str = {'Fine\_thr = 4','Disp minimization'};
    title(['Dispersion Mimimization for \tau_{' num2str(pt) '}']);       
    svg_to_save = [folder_name 'analysis_matlab/ThresholdScan/Plot_Disp_Minimization/Pt ' num2str(pt) '.'];
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

%% FITTED PLOT PER TEMPI DI PICCO E FINE THRESHOLD TRIMMING - THRESHOLD DISPERSION MINIMIZATION
% in questa parte della funzione viene anche calcolata la dispersione di
% soglia al variare del tempo di picco con soglia minimizzata
idx_peaking_time = 1;
for pt = peaking_times'
    
    if(plot_ThresholdScan_PT_FTHR_fitted)
        f = figure('visible','off');
        hold on
        grid on
    end
    
    a_for_threshold_disp_mean = zeros(length_channels,1);
    b_for_threshold_disp_mean = zeros(length_channels,1);
    fin_thr_for_threshold_disp_mean = zeros(length_channels,1);
    
    a_for_threshold_disp_mean_wo_outliers = zeros(length_channels,1);
    b_for_threshold_disp_mean_wo_outliers = zeros(length_channels,1);
    fin_thr_for_threshold_disp_mean_wo_outliers = zeros(length_channels,1);
    
    idx_channel = 1;
    for ch = channels'
        pos1 = (idx_channel - 1)*length_peaking_times + idx_peaking_time;
        
        % Calcolo dispersione di soglia ottimizzata con mean
        fin_thr_mean = fin_thr_minimization(pos1,3);
        x_mean = fitParameters(:,1) == ch & fitParameters(:,2) == pt & fitParameters(:,3) == fin_thr_mean;
        a_b_mean = fitParameters(x_mean,:);
        a_mean = a_b_mean(4);
        b_mean = a_b_mean(5);
        a_for_threshold_disp_mean(idx_channel,1) = a_mean;
        b_for_threshold_disp_mean(idx_channel,1) = b_mean;
        fin_thr_for_threshold_disp_mean(idx_channel,1) = fin_thr_mean;
        
        % Calcolo dispersione di soglia ottimizzata con mean without
        % outliers
        fin_thr_mean_wo_outliers = fin_thr_minimization(pos1,4);
        x_mean_wo_outliers = fitParameters(:,1) == ch & fitParameters(:,2) == pt & fitParameters(:,3) == fin_thr_mean_wo_outliers;
        a_b_mean_wo_outliers = fitParameters(x_mean_wo_outliers,:);
        a_mean_wo_outliers = a_b_mean_wo_outliers(4);
        b_mean_wo_outliers = a_b_mean_wo_outliers(5);
        a_for_threshold_disp_mean_wo_outliers(idx_channel,1) = a_mean_wo_outliers;
        b_for_threshold_disp_mean_wo_outliers(idx_channel,1) = b_mean_wo_outliers;
        fin_thr_for_threshold_disp_mean_wo_outliers(idx_channel,1) = fin_thr_mean;
        
        if(plot_ThresholdScan_PT_FTHR_fitted)
            if strcmp(statistic_used,'mean')
                fitted_min_plot = a_mean - 5*b_mean;
                fitted_max_plot = a_mean + 5*b_mean;
                x_axis = [graph_min fitted_min_plot:0.1:fitted_max_plot graph_max];
                y_axis = fun(a_mean,b_mean,x_axis);
                plot(x_axis,y_axis)
            else
                fitted_min_plot = a_mean_wo_outliers - 5*b_mean_wo_outliers;
                fitted_max_plot = a_mean_wo_outliers + 5*b_mean_wo_outliers;
                x_axis = [graph_min fitted_min_plot:0.1:fitted_max_plot graph_max];
                y_axis = fun(a_mean_wo_outliers,b_mean_wo_outliers,x_axis);
                plot(x_axis,y_axis)
            end
        end
        
        idx_channel = idx_channel + 1;
    end
    
    % Dispersione di soglia basata sulle "a". La dispersione di soglia
    % viene calcolata in 2 modi:
    % 1) threshold_dispersion_mean: si fa la media di tutte le "a" di tutti i casi (peaking time,
    %    channels e fine threshold) e per ogni coppia (canale, tempo di picco)
    %    si trova la fine_threshold che si avvicina di più alla media precedentemente calcolata
    % 2) threshold_dispersion_mean_wo_outliers: si fa la media delle "a" che non sono outliers. Si eliminano le "a"
    %    più esterne con la funzione rmoutliers e si fa la media delle "a"
    %    rimanenti. Il resto del procedimento è come il precedente.
    threshold_dispersion_mean = std(a_for_threshold_disp_mean);
    threshold_dispersion_mean_wo_outliers = std(a_for_threshold_disp_mean_wo_outliers);
    
    % dopo aver minimizzato la soglia con il metodo 1) descritto precedentemente
    % si eliminano le "a" che non si sono avvicinate alla media delle soglie. Quindi si procede
    % all'eliminazione delle "a" che son considerate outliers.
    [data_without_outliers, boolean_outliers] = rmoutliers(a_for_threshold_disp_mean);
    data_std_wout_outliers = std(data_without_outliers);
    outliers = a_for_threshold_disp_mean(boolean_outliers);
    length_outliers = length(outliers);
    value = [threshold_dispersion_mean, threshold_dispersion_mean_wo_outliers, length_outliers, data_std_wout_outliers];
    threshold_dispersions(idx_peaking_time,length_fine_thresholds + 1:end) = value;
    
    if(plot_ThresholdScan_PT_FTHR_fitted)
        if strcmp(statistic_used,'mean')
            annotation('textbox', [0.15 0.7 0.1 0.1], 'String', ['Threshold Dispersion: ', num2str(threshold_dispersion_mean,'%5.3f'), ' [DAC\_thr code]'],'FitBoxToText','on', 'BackgroundColor','white')
        else
            annotation('textbox', [0.15 0.7 0.1 0.1], 'String', ['Threshold Dispersion: ', num2str(threshold_dispersion_mean_wo_outliers,'%5.3f'), ' [DAC\_thr code]'],'FitBoxToText','on', 'BackgroundColor','white')
        end
        title(['Threshold Scan at \tau_{' num2str(pt) '} - minimized']);
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
        str4 = num2str(a_for_threshold_disp_mean,'%5.2f');
        str5 = repmat(' - b: ', length_channels,1);
        str6 = num2str(b_for_threshold_disp_mean,'%4.2f');
        str7 = repmat(' - fin\_thr: ', length_channels,1);
        str8 = num2str(dec2bin(fin_thr_for_threshold_disp_mean),'%03d');
        str9 = repmat(')', length_channels,1);
        str = [str1, str2, str3, str4, str5, str6, str7, str8, str9];

        svg_to_save = [ folder_name 'analysis_matlab/ThresholdScan/Plot_PT_FTHR_fitted/Pt ' num2str(pt) ' - minimized.'];
        
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
        
        %% PLOT SENZA OUTLIERS
        f = figure('visible','off');
        hold on
        grid on
        dim = length(data_without_outliers);
        channels_wo = zeros(dim,1);
        length_channels_wo = length(channels_wo);
        a_wo = zeros(dim,1);
        b_wo = zeros(dim,1);
        fin_thr_wo = zeros(dim,1);
        count = 1;
        for idx = 1 : length(a_for_threshold_disp_mean)
            if(~boolean_outliers(idx))
                a = a_for_threshold_disp_mean(idx,1);
                b = b_for_threshold_disp_mean(idx,1);
                fin_thr = fin_thr_for_threshold_disp_mean(idx,1);
                fitted_min_plot = a - 5*b;
                fitted_max_plot = a + 5*b;
                x_axis = [graph_min fitted_min_plot:0.1:fitted_max_plot graph_max];
                y_axis = fun(a,b,x_axis);
                plot(x_axis,y_axis)
                
                channels_wo(count,1) = (idx - 1);
                a_wo(count,1) = a;
                b_wo(count,1) = b;
                fin_thr_wo(count,1) = fin_thr;
                count = count + 1;
            end
        end
        
        str1 = repmat('Ch #', length_channels_wo,1);
        str2 = num2str(channels_wo,'%02d');
        str3 = repmat(' (a: ', length_channels_wo,1);
        str4 = num2str(a_wo,'%5.2f');
        str5 = repmat(' - b: ', length_channels_wo,1);
        str6 = num2str(b_wo,'%4.2f');
        str7 = repmat(' - fin\_thr: ', length_channels_wo,1);
        str8 = num2str(dec2bin(fin_thr_wo),'%03d');
        str9 = repmat(')', length_channels_wo,1);
        str = [str1, str2, str3, str4, str5, str6, str7, str8, str9];
        title(['Threshold Scan at \tau_{' num2str(pt) '} - minimized without outliers']);
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
        
        svg_to_save = [ folder_name 'analysis_matlab/ThresholdScan/Plot_PT_FTHR_fitted/Pt ' num2str(pt) ' - minimized_without_outliers.'];
        
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
    idx_peaking_time = idx_peaking_time + 1;
end

%% SAVE DATA 
fileID = fopen([folder_name 'analysis_matlab/ThresholdScan/Thr_disp_minimization_fine_thresholds.dat'],'w');
fprintf(fileID,'%s/t%s/t%s/t%s/r/n','ch','pt','fine_thr_mean','fine_thr_mean_wo_outliers');
fprintf(fileID,'%2d/t%2d/t%2d/t%2d/r/n',fin_thr_minimization');
fclose(fileID);

fileID = fopen([folder_name 'analysis_matlab/ThresholdScan/Threshold_dispersion.dat'],'w');
fprintf(fileID,'%s/r/n','Come minimizzare la dispersione di soglia:');
fprintf(fileID,'%s/r/n','Calcolare la media "x" delle soglie ("a" ottenute dai fit)');
fprintf(fileID,'%s/r/n','1) disp_mean: per ogni coppia (canale, tempo di picco) si trova la fine_threshold che si avvicina di più alla media "x" precedentemente calcolata');
fprintf(fileID,'%s/r/n','2) disp_mean_wo_outliers_1: prima del calocolo della media "x" vengono eliminati gli outliers, poi per ogni coppia (canale, tempo di picco) si trova la fine_threshold che si avvicina di più alla nuova media');
fprintf(fileID,'%s/r/n','3.1) outliers: Dopo aver trovato le fine threshold che minimizzano la soglia nel metodo 1), elimino i canali che hanno una soglia troppo spostata rispetto alla media (rimozione outliers)');
fprintf(fileID,'%s/r/n','3.2) disp_mean_wo_outliers_2: Calcolo la dispersione di soglia dei canali che non son stati eliminati nel punto 3.1');
fprintf(fileID,'%s/r/n','-----------------------------------------------------------------------------------------------------------------------------------------');
fprintf(fileID,'%s/t%s/t%s/t%s/t%s/t%s/t%s/t%s/t%s/t%s/t%s/t%s/r/n','f_thr_000','f_thr_001','f_thr_010','f_thr_011','f_thr_100','f_thr_101','f_thr_110','f_thr_111','disp_mean','disp_mean_wo_outliers_1','outliers', 'disp_mean_wo_outliers_2');
fprintf(fileID,'%5.3f/t%5.3f/t%5.3f/t%5.3f/t%5.3f/t%5.3f/t%5.3f/t%5.3f/t%5.3f/t%5.3f/t%2d/t%5.3f/r/n',threshold_dispersions');
fclose(fileID);
end



