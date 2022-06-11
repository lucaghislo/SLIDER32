function [ENCs] = ENC(slopes_and_interceptes,pedestals_mean_values_normal, plot_ENC, channels_to_not_consider, folder_name)

%% INIZIALIZZAZIONE VARIABILI
channels1 = unique(slopes_and_interceptes(:,1));
peaking_times1 = unique(slopes_and_interceptes(:,2));
length_channels = length(channels1);
length_peaking_times = length(peaking_times1);

channels2 = unique(pedestals_mean_values_normal(:,1));
peaking_times2 = unique(pedestals_mean_values_normal(:,2));

Pedestal_ENC_constant = 2.35*0.841;

% DACu [uV] = 2.048/2^16 = 31.25 uV (16 bit il DAC)
% DACu [keV]= DACu[uV]*Cinj/0.044 = 0.841

%% CALCOLO ENC E PLOT
if(all(channels1 == channels2) && all(peaking_times1 == peaking_times2))
    channels = channels1;
    peaking_times = peaking_times1;
    clear channels1 channels2 peaking_times1 peaking_times2
    
    
    %% CALCOLO ENC
    ENCs = zeros(length_channels*length_peaking_times,6);
    for ch = channels'
        for pt = peaking_times'
            rms_mean = pedestals_mean_values_normal(pedestals_mean_values_normal(:,1)==ch & pedestals_mean_values_normal(:,2)==pt,4);
            rms_mean_wo_out = pedestals_mean_values_normal(pedestals_mean_values_normal(:,1)==ch & pedestals_mean_values_normal(:,2)==pt,8);
            slope_mean_linear = slopes_and_interceptes(slopes_and_interceptes(:,1)==ch & slopes_and_interceptes(:,2)==pt,3);
            slope_mean_wo_out_linear = slopes_and_interceptes(slopes_and_interceptes(:,1)==ch & slopes_and_interceptes(:,2)==pt,7);
            slope_mean_cubic = slopes_and_interceptes(slopes_and_interceptes(:,1)==ch & slopes_and_interceptes(:,2)==pt,11);
            slope_mean_wo_out_cubic = slopes_and_interceptes(slopes_and_interceptes(:,1)==ch & slopes_and_interceptes(:,2)==pt,15);
            
            if(slope_mean_linear > 0.5)
                ENC_mean_linear = rms_mean/slope_mean_linear*Pedestal_ENC_constant;
            else
                ENC_mean_linear = NaN;
            end
            
            if(slope_mean_wo_out_linear > 0.5)
                ENC_mean_wo_out_linear = rms_mean_wo_out/slope_mean_wo_out_linear*Pedestal_ENC_constant;
            else
                ENC_mean_wo_out_linear = NaN;
            end
            
            if(slope_mean_cubic > 0.5)
                ENC_mean_cubic = rms_mean/slope_mean_cubic*Pedestal_ENC_constant;
            else
                ENC_mean_cubic = NaN;
            end
            
            if(slope_mean_wo_out_cubic > 0.5)
                ENC_mean_wo_out_cubic = rms_mean_wo_out/slope_mean_wo_out_cubic*Pedestal_ENC_constant;
            else
                ENC_mean_wo_out_cubic = NaN;
            end
            
            value = [ch pt ENC_mean_linear ENC_mean_wo_out_linear ENC_mean_cubic ENC_mean_wo_out_cubic];
            pos = ch*length_peaking_times + pt + 1;
            ENCs(pos,:) = value;
        end
    end
    
    
    nans = NaN(8,4);
    
    for ch_n = channels_to_not_consider
        ENCs(ch_n*8+1: ch_n*8+8,3:6)=nans;
    end
    
    %% SAVE ENC CH
    if(plot_ENC(2)==1)
        %% create folder
        if ~exist([folder_name 'analysis_matlab/ENC'],'dir' )
            mkdir([folder_name 'analysis_matlab/ENC']);
            mkdir([folder_name 'analysis_matlab/ENC/normal']);
            mkdir([folder_name 'analysis_matlab/ENC/normal/Plot_CH']);
        else
            if ~exist([folder_name 'analysis_matlab/ENC/normal/'],'dir' )
                mkdir([folder_name 'analysis_matlab/ENC/normal']);
                mkdir([folder_name 'analysis_matlab/ENC/normal/Plot_CH']);
            else
                if~exist([folder_name 'analysis_matlab/ENC/normal/Plot_CH'],'dir' )
                    mkdir([folder_name 'analysis_matlab/ENC/normal/Plot_CH']);
                end
            end
        end
        
        data_to_plot = zeros(length_channels,length_peaking_times);
        % strings utilizzate per costruire la legenda
        str_1 = repmat('\tau_{',length(peaking_times),1);
        str_2 = num2str(peaking_times);
        str_3 = repmat('}',length(peaking_times),1);
        str = [str_1 str_2 str_3];
        pos_4_keV_x = -2;
        
        %% (Pedestal rms mean) / (Linear fit slope mean)
        %% CLASSIC GRAPH
        f = figure('visible','off');
        hold on
        grid on
        idx_pt = 1;
        for pt = peaking_times'
            data = ENCs(ENCs(:,2) == pt,3);
            data_to_plot(:,idx_pt) = data;
            plot(channels,data,'Marker','*')
            idx_pt = idx_pt + 1;
        end
        yline(4,'-.','Color','r','LineWidth',1.4);
        title('FWHM ENC [keV] (Pedestal rms / Linear fit Slope - mean)');
        ylabel('FWHM ENC [keV]');
        xlabel('Channels');
        xlim([0,31])
        f.WindowState = 'maximized';
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
        text(pos_4_keV_x,4,'4 keV','Color','red','FontSize',14)
        % annotation('textbox', [.7 .6 .1 .1], 'String','4 keV','FitBoxToText','on', 'Color','red')
        def_ax = f.CurrentAxes;
        Y_Lim = def_ax.YLim(2);
        def_ax.YLim = [0,Y_Lim];
        lg = legend(str,'Location','northeastoutside');
        
        % set unit for legend size to inches
        set(lg, 'unit', 'inches')
        % get legend size
        legend_size = get(lg, 'position');
        % new figure width
        figure_size(3) = figure_size(3) + legend_size(3);
        % set new figure size
        set(gcf, 'position', figure_size)
        
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_CH/ENC (linear-mean) - Lines.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
        %% BAR PLOT - PLOT rms_mean/slope_mean_linear
        f = figure('visible','off');
        hold on
        grid on
        bar(channels, data_to_plot);
        title('FWHM ENC [keV] (Pedestal rms / Linear fit Slope - mean)');
        xlabel('Channels');
        ylabel('FWHM ENC [keV]');
        f.WindowState = 'maximized';
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
        lg = legend(str,'Location','northeastoutside');
        
        % set unit for legend size to inches
        set(lg, 'unit', 'inches')
        % get legend size
        legend_size = get(lg, 'position');
        % new figure width
        figure_size(3) = figure_size(3) + legend_size(3);
        % set new figure size
        set(gcf, 'position', figure_size)
        
        
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_CH/ENC (linear-mean) - Bar Plot.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
        %% HEATMAP - PLOT rms_mean/slope_mean_linear
        f = figure('visible','off');
        grid on
        heatmap(num2cell(channels)',num2cell(peaking_times), data_to_plot', 'Colormap',jet);
        title('FWHM ENC [keV] (Pedestal rms / Linear fit Slope - mean)');
        xlabel('Channels');
        ylabel('Peaking times');
        f.WindowState = 'maximized';
        
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_CH/ENC (linear-mean) - Heat Map.'];
        % new figure width
        figure_size(3) = figure_size(3);
        % set new figure size
        set(gcf, 'position', figure_size)
        
        save_image(svg_to_save, 'pdf', f)
        close
        
        %% (Pedestal rms mean without outliers) / (Linear fit slope mean without outliers)
        %% CLASSIC GRAPH
        f = figure('visible','off');
        hold on
        grid on
        idx_pt = 1;
        for pt = peaking_times'
            data = ENCs(ENCs(:,2) == pt,4);
            data_to_plot(:,idx_pt) = data;
            plot(channels,data,'Marker','*')
            idx_pt = idx_pt + 1;
        end
        yline(4,'-.','Color','r','LineWidth',1.4);
        title('FWHM ENC [keV] (Pedestal rms / Linear fit Slope - mean without outliers)');
        ylabel('FWHM ENC [keV]');
        xlabel('Channels');
        xlim([0,31])
        f.WindowState = 'maximized';
        
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
        text(pos_4_keV_x,4,'4 keV','Color','red','FontSize',14)
        % annotation('textbox', [.7 .6 .1 .1], 'String','4 keV','FitBoxToText','on', 'Color','red')
        def_ax = f.CurrentAxes;
        Y_Lim = def_ax.YLim(2);
        def_ax.YLim = [0,Y_Lim];
        lg = legend(str,'Location','northeastoutside');
        
        % set unit for legend size to inches
        set(lg, 'unit', 'inches')
        % get legend size
        legend_size = get(lg, 'position');
        % new figure width
        figure_size(3) = figure_size(3) + legend_size(3);
        % set new figure size
        set(gcf, 'position', figure_size)
        
        legend(str,'Location','northeastoutside');
        text(pos_4_keV_x,4,'4 keV','Color','red','FontSize',14)
        ax = f.CurrentAxes;
        ax.YLim = [0,Y_Lim];
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_CH/ENC (linear-mean_wo_out) - Lines.'];
        save_image(svg_to_save, 'pdf', f)
        % annotation('textbox', [.7 .6 .1 .1], 'String','4 keV','FitBoxToText','on', 'Color','red')
        close
        
        %% BAR PLOT - PLOT rms_mean/slope_mean_linear
        f = figure('visible','off');
        hold on
        grid on
        bar(channels, data_to_plot);
        title('FWHM ENC [keV] (Pedestal rms / Linear fit Slope - mean without outliers)');
        xlabel('Channels');
        ylabel('FWHM ENC [keV]');
        f.WindowState = 'maximized';
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
        lg = legend(str,'Location','northeastoutside');
        
        % set unit for legend size to inches
        set(lg, 'unit', 'inches')
        % get legend size
        legend_size = get(lg, 'position');
        % new figure width
        figure_size(3) = figure_size(3) + legend_size(3);
        % set new figure size
        set(gcf, 'position', figure_size)
        
        
        ax = f.CurrentAxes;
        ax.YLim = [0,Y_Lim];
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_CH/ENC (linear-mean_wo_out) - Bar Plot.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
        %% HEATMAP - PLOT rms_mean/slope_mean_linear
        f = figure('visible','off');
        grid on
        heatmap(num2cell(channels)',num2cell(peaking_times), data_to_plot', 'Colormap',jet);
        title('FWHM ENC [keV] (Pedestal rms / Linear fit Slope - mean without outliers)');
        xlabel('Channels');
        ylabel('Peaking times');
        f.WindowState = 'fullscreen';
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_CH/ENC (linear-mean_wo_out) - Heat Map.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
        %% (Pedestal rms mean) / (Cubic fit slope mean)
        %% CLASSIC GRAPH
        f = figure('visible','off');
        hold on
        grid on
        idx_pt = 1;
        for pt = peaking_times'
            data = ENCs(ENCs(:,2) == pt,5);
            data_to_plot(:,idx_pt) = data;
            plot(channels,data,'Marker','*')
            idx_pt = idx_pt + 1;
        end
        yline(4,'-.','Color','r','LineWidth',1.4);
        title('FWHM ENC [keV] (Pedestal rms / Cubic fit Slope - mean)');
        ylabel('FWHM ENC [keV]');
        xlabel('Channels');
        xlim([0,31])
        f.WindowState = 'maximized';
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
        lg = legend(str,'Location','northeastoutside');
        
        % set unit for legend size to inches
        set(lg, 'unit', 'inches')
        % get legend size
        legend_size = get(lg, 'position');
        % new figure width
        figure_size(3) = figure_size(3) + legend_size(3);
        % set new figure size
        set(gcf, 'position', figure_size)
        
        text(pos_4_keV_x,4,'4 keV','Color','red','FontSize',14)
        ax = f.CurrentAxes;
        ax.YLim = [0,Y_Lim];
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_CH/ENC (cubic-mean) - Lines.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
        %% BAR PLOT - PLOT rms_mean/slope_mean_linear
        f = figure('visible','off');
        hold on
        grid on
        bar(channels, data_to_plot);
        title('FWHM ENC [keV] (Pedestal rms / Cubic fit Slope - mean)');
        xlabel('Channels');
        ylabel('FWHM ENC [keV]');
        f.WindowState = 'maximized';
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
        lg = legend(str,'Location','northeastoutside');
        
        % set unit for legend size to inches
        set(lg, 'unit', 'inches')
        % get legend size
        legend_size = get(lg, 'position');
        % new figure width
        figure_size(3) = figure_size(3) + legend_size(3);
        % set new figure size
        set(gcf, 'position', figure_size)
        
        ax = f.CurrentAxes;
        ax.YLim = [0,Y_Lim];
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_CH/ENC (cubic-mean) - Bar Plot.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
        %% HEATMAP - PLOT rms_mean/slope_mean_linear
        f = figure('visible','off');
        grid on
        heatmap(num2cell(channels)',num2cell(peaking_times), data_to_plot', 'Colormap',jet);
        title('FWHM ENC [keV] (Pedestal rms / Cubic fit Slope - mean)');
        xlabel('Channels');
        ylabel('Peaking times');
        f.WindowState = 'fullscreen';
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_CH/ENC (cubic-mean) - Heat Map.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
        %% (Pedestal rms mean without outliers) / (Cubic fit slope mean without outliers)
        %% CLASSIC GRAPH
        f = figure('visible','off');
        hold on
        grid on
        idx_pt = 1;
        for pt = peaking_times'
            data = ENCs(ENCs(:,2) == pt,6);
            data_to_plot(:,idx_pt) = data;
            plot(channels,data,'Marker','*')
            idx_pt = idx_pt + 1;
        end
        yline(4,'-.','Color','r','LineWidth',1.4);
        title('FWHM ENC [keV] (Pedestal rms / Cubic fit Slope - mean without outliers)');
        ylabel('FWHM ENC [keV]');
        xlabel('Channels');
        xlim([0,31])
        f.WindowState = 'maximized';
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
        lg = legend(str,'Location','northeastoutside');
        
        % set unit for legend size to inches
        set(lg, 'unit', 'inches')
        % get legend size
        legend_size = get(lg, 'position');
        % new figure width
        figure_size(3) = figure_size(3) + legend_size(3);
        % set new figure size
        set(gcf, 'position', figure_size)
        
        text(pos_4_keV_x,4,'4 keV','Color','red','FontSize',14)
        ax = f.CurrentAxes;
        ax.YLim = [0,Y_Lim];
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_CH/ENC (cubic-mean_wo_out) - Lines.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
        %% BAR PLOT - PLOT rms_mean/slope_mean_linear
        f = figure('visible','off');
        hold on
        grid on
        bar(channels, data_to_plot);
        title('FWHM ENC [keV] (Pedestal rms / Cubic fit Slope - mean without outliers)');
        xlabel('Channels');
        ylabel('FWHM ENC [keV]');
        f.WindowState = 'maximized';
        
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
        lg = legend(str,'Location','northeastoutside');
        
        % set unit for legend size to inches
        set(lg, 'unit', 'inches')
        % get legend size
        legend_size = get(lg, 'position');
        % new figure width
        figure_size(3) = figure_size(3) + legend_size(3);
        % set new figure size
        set(gcf, 'position', figure_size)
        
        ax = f.CurrentAxes;
        ax.YLim = [0,Y_Lim];
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_CH/ENC (cubic-mean_wo_out) - Bar Plot.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
        %% HEATMAP - PLOT rms_mean/slope_mean_linear
        f = figure('visible','off');
        grid on
        heatmap(num2cell(channels)',num2cell(peaking_times), data_to_plot', 'Colormap',jet);
        title('FWHM ENC [keV] (Pedestal rms / Cubic fit Slope - mean without outliers)');
        xlabel('Channels');
        ylabel('Peaking times');
        f.WindowState = 'fullscreen';
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_CH/ENC (cubic-mean_wo_out) - Heat Map.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
    end
    
    %% SAVE ENC PT
    if(plot_ENC(1)==1)
        %% create folder
        if ~exist([folder_name 'analysis_matlab/ENC'],'dir' )
            mkdir([folder_name 'analysis_matlab/ENC']);
            mkdir([folder_name 'analysis_matlab/ENC/normal']);
            mkdir([folder_name 'analysis_matlab/ENC/normal/Plot_PT']);
        else
            if ~exist([folder_name 'analysis_matlab/ENC/normal/'],'dir' )
                mkdir([folder_name 'analysis_matlab/ENC/normal']);
                mkdir([folder_name 'analysis_matlab/ENC/normal/Plot_PT']);
            else
                if~exist([folder_name 'analysis_matlab/ENC/normal/Plot_PT'],'dir' )
                    mkdir([folder_name 'analysis_matlab/ENC/normal/Plot_PT']);
                end
            end
        end
        
        data_to_plot = zeros(length_channels,length_peaking_times);
        % strings utilizzate per costruire la legenda
        str_1 = repmat('Ch #',length_channels,1);
        str_2 = num2str(channels,'%02d');
        str = [str_1 str_2];
        pos_4_keV_x = -.6;
        
        %% (Pedestal rms mean) / (Linear fit slope mean)
        %% CLASSIC GRAPH
        f = figure('visible','off');
        hold on
        grid on
        for ch = channels'
            data = ENCs(ENCs(:,1) == ch,3);
            data_to_plot(ch + 1,:) = data';
            plot(peaking_times,data,'Marker','*')
        end
        yline(4,'-.','Color','r','LineWidth',1.4);
        title('FWHM ENC [keV] (Pedestal rms / Linear fit Slope - mean)');
        ylabel('FWHM ENC [keV]');
        xlabel('Peaking times');
        xlim([min(peaking_times),max(peaking_times)])
        f.WindowState = 'maximized';
        
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
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
        
        text(pos_4_keV_x,4,'4 keV','Color','red','FontSize',14)
        % annotation('textbox', [.7 .6 .1 .1], 'String','4 keV','FitBoxToText','on', 'Color','red')
        def_ax = f.CurrentAxes;
        Y_Lim = def_ax.YLim(2);
        def_ax.YLim = [0,Y_Lim];
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_PT/ENC (linear-mean) - Lines.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
        %% BAR PLOT
        f = figure('visible','off');
        hold on
        grid on
        bar(peaking_times, data_to_plot');
        title('FWHM ENC [keV] (Pedestal rms / Linear fit Slope - mean)');
        xlabel('Peaking times');
        ylabel('FWHM ENC [keV]');
        f.WindowState = 'maximized';
        
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
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
        
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_PT/ENC (linear-mean) - Bar Plot.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
        %% HEATMAP
        f = figure('visible','off');
        grid on
        heatmap(num2cell(peaking_times)', num2cell(channels), data_to_plot, 'Colormap',jet);
        title('FWHM ENC [keV] (Pedestal rms / Linear fit Slope - mean)');
        xlabel('Peaking times');
        ylabel('Channels');
        f.WindowState = 'maximized';
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_PT/ENC (linear-mean) - Heat Map.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
        %% (Pedestal rms mean without outliers) / (Linear fit slope mean without outliers)
        %% CLASSIC GRAPH
        f = figure('visible','off');
        hold on
        grid on
        for ch = channels'
            data = ENCs(ENCs(:,1) == ch,4);
            data_to_plot(ch + 1,:) = data';
            plot(peaking_times,data,'Marker','*')
        end
        yline(4,'-.','Color','r','LineWidth',1.4);
        title('FWHM ENC [keV] (Pedestal rms / Linear fit Slope - mean without outliers)');
        ylabel('FWHM ENC [keV]');
        xlabel('Peaking times');
        xlim([min(peaking_times),max(peaking_times)])
        f.WindowState = 'maximized';
        
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
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
        
        text(pos_4_keV_x,4,'4 keV','Color','red','FontSize',14)
        ax = f.CurrentAxes;
        ax.YLim = [0,Y_Lim];
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_PT/ENC (linear-mean_wo_out) - Lines.'];
        save_image(svg_to_save, 'pdf', f)
        % annotation('textbox', [.7 .6 .1 .1], 'String','4 keV','FitBoxToText','on', 'Color','red')
        close
        
        %% BAR PLOT
        f = figure('visible','off');
        hold on
        grid on
        bar(peaking_times, data_to_plot');
        title('FWHM ENC [keV] (Pedestal rms / Linear fit Slope - mean without outliers)');
        xlabel('Peaking times');
        ylabel('FWHM ENC [keV]');
        f.WindowState = 'maximized';
        
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
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
        
        ax = f.CurrentAxes;
        ax.YLim = [0,Y_Lim];
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_PT/ENC (linear-mean_wo_out) - Bar Plot.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
        %% HEATMAP
        f = figure('visible','off');
        grid on
        heatmap(num2cell(peaking_times)', num2cell(channels), data_to_plot, 'Colormap',jet);
        title('FWHM ENC [keV] (Pedestal rms / Linear fit Slope - mean without outliers)');
        xlabel('Peaking Times');
        ylabel('Channels');
        f.WindowState = 'maximized';
        
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
        % new figure width
        figure_size(3) = figure_size(3);
        % set new figure size
        set(gcf, 'position', figure_size)
        
        
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_PT/ENC (linear-mean_wo_out) - Heat Map.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
        %% (Pedestal rms mean) / (Cubic fit slope mean)
        %% CLASSIC GRAPH
        f = figure('visible','off');
        hold on
        grid on
        for ch = channels'
            data = ENCs(ENCs(:,1) == ch,5);
            data_to_plot(ch + 1,:) = data';
            plot(peaking_times,data,'Marker','*')
        end
        yline(4,'-.','Color','r','LineWidth',1.4);
        title('FWHM ENC [keV] (Pedestal rms / Cubic fit Slope - mean)');
        ylabel('FWHM ENC [keV]');
        xlabel('Peaking times');
        xlim([min(peaking_times),max(peaking_times)])
        f.WindowState = 'maximized';
        
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
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
        
        text(pos_4_keV_x,4,'4 keV','Color','red','FontSize',14)
        ax = f.CurrentAxes;
        ax.YLim = [0,Y_Lim];
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_PT/ENC (cubic-mean) - Lines.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
        %% BAR PLOT
        f = figure('visible','off');
        hold on
        grid on
        bar(peaking_times, data_to_plot');
        title('FWHM ENC [keV] (Pedestal rms / Cubic fit Slope - mean)');
        xlabel('Peaking times');
        ylabel('FWHM ENC [keV]');
        f.WindowState = 'maximized';
        
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
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
        
        ax = f.CurrentAxes;
        ax.YLim = [0,Y_Lim];
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_PT/ENC (cubic-mean) - Bar Plot.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
        %% HEATMAP
        f = figure('visible','off');
        grid on
        heatmap(num2cell(peaking_times)', num2cell(channels), data_to_plot, 'Colormap',jet);
        title('FWHM ENC [keV] (Pedestal rms / Cubic fit Slope - mean)');
        xlabel('Peaking Times');
        ylabel('Channels');
        f.WindowState = 'maximized';
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_PT/ENC (cubic-mean) - Heat Map.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
        %% (Pedestal rms mean without outliers) / (Cubic fit slope mean without outliers)
        %% CLASSIC GRAPH
        f = figure('visible','off');
        hold on
        grid on
        for ch = channels'
            data = ENCs(ENCs(:,1) == ch,6);
            data_to_plot(ch + 1,:) = data';
            plot(peaking_times,data,'Marker','*')
        end
        yline(4,'-.','Color','r','LineWidth',1.4);
        title('FWHM ENC [keV] (Pedestal rms / Cubic fit Slope - mean without outliers)');
        ylabel('FWHM ENC [keV]');
        xlabel('Peaking times');
        xlim([min(peaking_times),max(peaking_times)])
        f.WindowState = 'maximized';
        
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
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
        
        text(pos_4_keV_x,4,'4 keV','Color','red','FontSize',14)
        ax = f.CurrentAxes;
        ax.YLim = [0,Y_Lim];
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_PT/ENC (cubic-mean_wo_out) - Lines.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
        %% BAR PLOT
        f = figure('visible','off');
        hold on
        grid on
        bar(peaking_times, data_to_plot');
        title('FWHM ENC [keV] (Pedestal rms / Cubic fit Slope - mean without outliers)');
        xlabel('Peaking times');
        ylabel('FWHM ENC [keV]');
        f.WindowState = 'maximized';
        
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
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
        
        ax = f.CurrentAxes;
        ax.YLim = [0,Y_Lim];
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_PT/ENC (cubic-mean_wo_out) - Bar Plot.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
        %% HEATMAP - PLOT rms_mean/slope_mean_linear
        f = figure('visible','off');
        grid on
        heatmap(num2cell(peaking_times)', num2cell(channels), data_to_plot, 'Colormap',jet);
        title('FWHM ENC [keV] (Pedestal rms / Cubic fit Slope - mean without outliers)');
        xlabel('Peaking times');
        ylabel('Channels');
        f.WindowState = 'maximized';
        
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        % new figure width
        figure_size(3) = figure_size(3);
        % set new figure size
        set(gcf, 'position', figure_size)
        
        svg_to_save = [folder_name 'analysis_matlab/ENC/normal/Plot_PT/ENC (cubic-mean_wo_out) - Heat Map.'];
        save_image(svg_to_save, 'pdf', f)
        close
        
    end
    
    %% SAVE FILE
    if ~exist([folder_name 'analysis_matlab/ENC'],'dir' )
        mkdir([folder_name 'analysis_matlab/ENC']);
        mkdir([folder_name 'analysis_matlab/ENC/normal']);
    else
        if ~exist([folder_name 'analysis_matlab/ENC/normal/'],'dir' )
            mkdir([folder_name 'analysis_matlab/ENC/normal']);
        end
    end
    if ~exist([folder_name 'analysis_matlab/ENC/normal/ENC_normal.dat'],'file') % Creo il file solo se non esiste già
        fileID = fopen([folder_name 'analysis_matlab/ENC/normal/ENC_normal.dat'],'w');
        fprintf(fileID,'INDEX\r\n');
        fprintf(fileID,'ENC_l_m: ENC obtained with pedestal rms and linear gain fit with mean values\r\n');
        fprintf(fileID,'ENC_l_mwo: ENC obtained with pedestal rms and linear gain fit with mean values without outliers\r\n');
        fprintf(fileID,'ENC_3_m: ENC obtained with pedestal rms and cubic gain fit with mean values\r\n');
        fprintf(fileID,'ENC_3_mwo: ENC obtained with pedestal rms and cubic gain fit with mean values without outliers\r\n');
        fprintf(fileID,'-----------------------------------------------------------------\r\n');
        
        fprintf(fileID,'%2s\t%2s\t%s\t%s\t%s\t%s\r\n','ch','pt','ENC_l_m','ENC_l_mwo','ENC_3_m','ENC_3_mwo');
        format = '%2d\t%2d\t%5.3f\t%5.3f\t%5.3f\t%5.3f\r\n';
        fprintf(fileID,format,ENCs');
        fclose(fileID);
    end
end
end


