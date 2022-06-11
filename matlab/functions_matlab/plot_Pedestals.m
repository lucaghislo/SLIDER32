function plot_Pedestals(pedestals_mean_values, pedestals_channel_out_ADC_codes, pedestals_mean_values_wo_mean, pedestals_channel_out_ADC_codes2, allData, meanData, pedestal_data_for_ch_mean, plot_PEDESTALS, channels_to_not_consider, folder_name)

channels = unique(pedestals_mean_values(:,1));

channels_to_plot = channels(~ismember(channels, channels_to_not_consider));
peaking_times = unique(pedestals_mean_values(:,2));
zoom_min = 101;
zoom_max = 200;

a = channels_to_plot + 1;
data1 = allData(:,a',:); 
if plot_PEDESTALS(1) == 1
    data2 = meanData(:,a',:);
end
y_min1 = min(data1,[],'all');
y_max1 = max(data1,[],'all');
if plot_PEDESTALS(1) == 1
    y_min2 = min(data2,[],'all');
    y_max2 = max(data2,[],'all');
end

%% PLOT PEDESTALS NORMAL - ALL TIME
if (plot_PEDESTALS(3)==1)
    %% create folder
    if ~exist([folder_name 'analysis_matlab/Pedestal'],'dir' )
        mkdir([folder_name 'analysis_matlab/Pedestal']);
        mkdir([folder_name 'analysis_matlab/Pedestal/normal']);
        mkdir([folder_name 'analysis_matlab/Pedestal/normal/Plot_all_Cases_byTime']);
    else
        if(~exist([folder_name 'analysis_matlab/Pedestal/normal'],'dir' ))
            mkdir([folder_name 'analysis_matlab/Pedestal/normal']);
            mkdir([folder_name 'analysis_matlab/Pedestal/normal/Plot_all_Cases_byTime']);
        else
            if(~exist([folder_name 'analysis_matlab/Pedestal/normal/Plot_all_Cases_byTime'],'dir' ))
                mkdir([folder_name 'analysis_matlab/Pedestal/normal/Plot_all_Cases_byTime']);
            end
        end
    end
    
    %% plot selected channels
    for pt = peaking_times'
        f = figure('visible','off');
        hold on
        grid on
        
        for ch = channels_to_plot'
            plot(allData(:,ch + 1, pt + 1));
        end
        
        title(['Pedestal in Time of \tau_{' num2str(pt) '}']);
        xlabel('Time')
        ylabel('Channel\_out [ADC code]');
        ylim([y_min1 y_max1]);
        f.WindowState = 'maximized';
        
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
        str_1 = repmat('Ch #',length(channels_to_plot),1);
        str_2 = num2str(channels_to_plot,'%02d');
        str = [str_1 str_2];
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
        
        
        svg_to_save = [folder_name 'analysis_matlab/Pedestal/normal/Plot_all_Cases_byTime/Pt ' num2str(pt) '.'];
        save_image(svg_to_save, 'pdf', f)
        close
    end
    
    %% plot mean of channels
    if (plot_PEDESTALS(1) == 1)
        for pt = peaking_times'
            f1 = figure('visible','off');
            
            plot(pedestal_data_for_ch_mean(:, pt + 1));
            title(['Pedestal in Time of \tau_{' num2str(pt) '}']);
            xlabel('Time')
            ylabel('Channel\_out [ADC code]');
            ylim([y_min1 y_max1]);
            
            f1.WindowState = 'maximized';
            
            % get the original size of figure before the legends are added
            set(gcf, 'unit', 'inches');
            figure_size =  get(gcf, 'position');
            
            % new figure width
            figure_size(3) = figure_size(3);
            % set new figure size
            set(gcf, 'position', figure_size)
            
            
            svg_to_save = [folder_name 'analysis_matlab/Pedestal/normal/Plot_all_Cases_byTime/Pt ' num2str(pt) ' - Ch mean.'];
            save_image(svg_to_save, 'pdf', f1)
            close
        end
    end
    
end

%% PLOT PEDESTALS NORMAL - ZOOM
if (plot_PEDESTALS(4)==1)
    %% create folder
    if ~exist([folder_name 'analysis_matlab/Pedestal'],'dir' )
        mkdir([folder_name 'analysis_matlab/Pedestal']);
        mkdir([folder_name 'analysis_matlab/Pedestal/normal']);
        mkdir([folder_name 'analysis_matlab/Pedestal/normal/Plot_all_Cases_byTime_ZOOM']);
    else
        if(~exist([folder_name 'analysis_matlab/Pedestal/normal'],'dir' ))
            mkdir([folder_name 'analysis_matlab/Pedestal/normal']);
            mkdir([folder_name 'analysis_matlab/Pedestal/normal/Plot_all_Cases_byTime_ZOOM']);
        else
            if(~exist([folder_name 'analysis_matlab/Pedestal/normal/Plot_all_Cases_byTime_ZOOM'],'dir' ))
                mkdir([folder_name 'analysis_matlab/Pedestal/normal/Plot_all_Cases_byTime_ZOOM']);
            end
        end
    end
    
    %% plot selected channels
    for pt = peaking_times'
        f = figure('visible','off');
        hold on
        grid on
        
        for ch = channels_to_plot'
            plot(allData(zoom_min:zoom_max,ch + 1, pt + 1));
        end
        
        title(['Pedestal in Time of \tau_{' num2str(pt) '}']);
        xlabel('Time')
        ylabel('Channel\_out [ADC code]');
        ylim([y_min1 y_max1]);
        
        f.WindowState = 'maximized';
        
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
        str_1 = repmat('Ch #',length(channels_to_plot),1);
        str_2 = num2str(channels_to_plot,'%02d');
        str = [str_1 str_2];
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
        
        
        svg_to_save = [folder_name 'analysis_matlab/Pedestal/normal/Plot_all_Cases_byTime_ZOOM/Pt ' num2str(pt) '.'];
        save_image(svg_to_save, 'pdf', f)
        close
    end
    
    %% plot mean of channels
    if (plot_PEDESTALS(1) == 1)
        for pt = peaking_times'
            f1 = figure('visible','off');
            
            plot(pedestal_data_for_ch_mean(zoom_min:zoom_max, pt + 1));
            title(['Pedestal in Time of \tau_{' num2str(pt) '}']);
            xlabel('Time')
            ylabel('Channel\_out [ADC code]');
            ylim([y_min1 y_max1]);
            
            f1.WindowState = 'maximized';
            
            % get the original size of figure before the legends are added
            set(gcf, 'unit', 'inches');
            figure_size =  get(gcf, 'position');
            
            % new figure width
            figure_size(3) = figure_size(3);
            % set new figure size
            set(gcf, 'position', figure_size)
            
            
            svg_to_save = [folder_name 'analysis_matlab/Pedestal/normal/Plot_all_Cases_byTime_ZOOM/Pt ' num2str(pt) ' - Ch mean.'];
            save_image(svg_to_save, 'pdf', f1)
            close
        end
    end
    
end

%% PLOT PEDESTALS NORMAL - HISTOGRAM
if (plot_PEDESTALS(2)==1)
    %% create folder
    if ~exist([folder_name 'analysis_matlab/Pedestal'],'dir' )
        mkdir([folder_name 'analysis_matlab/Pedestal']);
        mkdir([folder_name 'analysis_matlab/Pedestal/normal']);
        mkdir([folder_name 'analysis_matlab/Pedestal/normal/Plot_histograms']);
    else
        if(~exist([folder_name 'analysis_matlab/Pedestal/normal'],'dir' ))
            mkdir([folder_name 'analysis_matlab/Pedestal/normal']);
            mkdir([folder_name 'analysis_matlab/Pedestal/normal/Plot_histograms']);
        else
            if(~exist([folder_name 'analysis_matlab/Pedestal/normal/Plot_histograms'],'dir' ))
                mkdir([folder_name 'analysis_matlab/Pedestal/normal/Plot_histograms']);
            end
        end
    end
    
    %% plot all channels
    for ch = channels'
        for pt = peaking_times'
            value = pedestals_mean_values(pedestals_mean_values(:,1)==ch & pedestals_mean_values(:,2)==pt,:);
            % PLOT HISTOGRAM
            f = figure('visible','off');
            hold on
            grid on
            idx_bar_min = find(value(1,10:end) > 0, 1, 'first');
            idx_bar_max = find(value(1,10:end) > 0, 1, 'last');
            bar_min = pedestals_channel_out_ADC_codes(idx_bar_min);
            bar_max = pedestals_channel_out_ADC_codes(idx_bar_max);
            mu = value(3);
            sigma = value(4);
            xline(mu,'-.','Color','k','LineWidth',1.2);
            xline(mu + sigma,'-.','Color','k','LineWidth',1.2);
            xline(mu + 2*sigma,'-.','Color','k','LineWidth',1.2);
            xline(mu + 3*sigma,'-.','Color','k','LineWidth',1.2);
            xline(mu - sigma,'-.','Color','k','LineWidth',1.2);
            xline(mu - 2*sigma,'-.','Color','k','LineWidth',1.2);
            xline(mu - 3*sigma,'-.','Color','k','LineWidth',1.2);
            
            fun = @(x)1/(sqrt(2*pi)*sigma)*exp(-(x-mu).^2/(2*sigma^2));
            
            title(['Pedestal of Channel #' num2str(ch) ' - \tau_{' num2str(pt) '}']);
            xlabel('Channel\_out [ADC code]')
            ylabel('Occurencies');
            
            x = bar_min:0.1:bar_max; % asse x per la gaussiana
            bar(pedestals_channel_out_ADC_codes, value(10:end),1,'EdgeColor','black');
            g = gca;
            text(mu + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'\mu', 'FontSize', 14)
            text(mu + sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'\sigma', 'FontSize', 14)
            text(mu + 2*sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'2\sigma', 'FontSize', 14)
            text(mu + 3*sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'3\sigma', 'FontSize', 14)
            text(mu - sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'-\sigma', 'FontSize', 14)
            text(mu - 2*sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'-2\sigma', 'FontSize', 14)
            text(mu - 3*sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'-3\sigma', 'FontSize', 14)
            
            
            f.WindowState = 'maximized';
            plot(x,fun(x)*trapz(pedestals_channel_out_ADC_codes,value(10:end)),'r', 'LineWidth', 1.5);
            
            xlim([bar_min - 1,bar_max + 1]);
            str1 = sprintf('#Occurencies: %4d',value(9));
            str2 = ['\mu: ' sprintf('%4.3f', mu) ' [ADC c]'];
            str3 = ['\sigma: ' sprintf('%4.3f', sigma) ' [ADC c]'];
            str = {str1,str2,str3};
            annotation('textbox', [.7 .7 .1 .1], 'String',str,'FitBoxToText','on','BackgroundColor','white')
            % get the original size of figure before the legends are added
            set(gcf, 'unit', 'inches');
            figure_size =  get(gcf, 'position');
            % set new figure size
            set(gcf, 'position', figure_size)
            
            svg_to_save = [folder_name 'analysis_matlab/Pedestal/normal/Plot_histograms/Ch ' num2str(ch)  ' - Pt ' num2str(pt) '.pdf'];
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

%% PLOT PEDESTALS WITHOUT MEAN - ALL TIME
if (plot_PEDESTALS(6)==1)
    %% create folder
    if ~exist([folder_name 'analysis_matlab/Pedestal'],'dir' )
        mkdir([folder_name 'analysis_matlab/Pedestal']);
        mkdir([folder_name 'analysis_matlab/Pedestal/wo_mean']);
        mkdir([folder_name 'analysis_matlab/Pedestal/wo_mean/Plot_all_Cases_byTime']);
    else
        if(~exist([folder_name 'analysis_matlab/Pedestal/wo_mean'],'dir' ))
            mkdir([folder_name 'analysis_matlab/Pedestal/wo_mean']);
            mkdir([folder_name 'analysis_matlab/Pedestal/wo_mean/Plot_all_Cases_byTime']);
        else
            if(~exist([folder_name 'analysis_matlab/Pedestal/wo_mean/Plot_all_Cases_byTime'],'dir' ))
                mkdir([folder_name 'analysis_matlab/Pedestal/wo_mean/Plot_all_Cases_byTime']);
            end
        end
    end
    
    %% plot selected channels
    for pt = peaking_times'
        f = figure('visible','off');
        hold on
        grid on
        
        for ch = channels_to_plot'
            plot(meanData(:,ch + 1, pt + 1));
        end
        
        title(['Pedestal in Time of \tau_{' num2str(pt) '}']);
        xlabel('Time')
        ylabel('Channel\_out [ADC code]');
        ylim([y_min2 y_max2]);
        
        f.WindowState = 'maximized';
        
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
        str_1 = repmat('Ch #',length(channels_to_plot),1);
        str_2 = num2str(channels_to_plot,'%02d');
        str = [str_1 str_2];
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
        
        
        svg_to_save = [folder_name 'analysis_matlab/Pedestal/wo_mean/Plot_all_Cases_byTime/Pt ' num2str(pt) '.'];
        save_image(svg_to_save, 'pdf', f)
        close
    end
    
end

%% PLOT PEDESTALS WITHOUT MEAN - ZOOM
if (plot_PEDESTALS(7)==1)
    %% create folder
    if ~exist([folder_name 'analysis_matlab/Pedestal'],'dir' )
        mkdir([folder_name 'analysis_matlab/Pedestal']);
        mkdir([folder_name 'analysis_matlab/Pedestal/wo_mean']);
        mkdir([folder_name 'analysis_matlab/Pedestal/wo_mean/Plot_all_Cases_byTime_ZOOM']);
    else
        if(~exist([folder_name 'analysis_matlab/Pedestal/wo_mean'],'dir' ))
            mkdir([folder_name 'analysis_matlab/Pedestal/wo_mean']);
            mkdir([folder_name 'analysis_matlab/Pedestal/wo_mean/Plot_all_Cases_byTime_ZOOM']);
        else
            if(~exist([folder_name 'analysis_matlab/Pedestal/wo_mean/Plot_all_Cases_byTime_ZOOM'],'dir' ))
                mkdir([folder_name 'analysis_matlab/Pedestal/wo_mean/Plot_all_Cases_byTime_ZOOM']);
            end
        end
    end
    
    %% plot selected channels
    for pt = peaking_times'
        f = figure('visible','off');
        hold on
        grid on
        
        for ch = channels_to_plot'
            plot(meanData(zoom_min:zoom_max,ch + 1, pt + 1));
        end
        
        title(['Pedestal in Time of \tau_{' num2str(pt) '}']);
        xlabel('Time')
        ylabel('Channel\_out [ADC code]');
        ylim([y_min2 y_max2]);
        
        f.WindowState = 'maximized';
        
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
        str_1 = repmat('Ch #',length(channels_to_plot),1);
        str_2 = num2str(channels_to_plot,'%02d');
        str = [str_1 str_2];
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
        
        
        svg_to_save = [folder_name 'analysis_matlab/Pedestal/wo_mean/Plot_all_Cases_byTime_ZOOM/Pt ' num2str(pt) '.'];
        save_image(svg_to_save, 'pdf', f)
        close
    end
    
end

%% PLOT PEDESTALS WITHOUT MEAN - HISTOGRAM
if (plot_PEDESTALS(5)==1)
    %% create folder
    if ~exist([folder_name 'analysis_matlab/Pedestal'],'dir' )
        mkdir([folder_name 'analysis_matlab/Pedestal']);
        mkdir([folder_name 'analysis_matlab/Pedestal/wo_mean']);
        mkdir([folder_name 'analysis_matlab/Pedestal/wo_mean/Plot_histograms']);
    else
        if(~exist([folder_name 'analysis_matlab/Pedestal/wo_mean'],'dir' ))
            mkdir([folder_name 'analysis_matlab/Pedestal/wo_mean']);
            mkdir([folder_name 'analysis_matlab/Pedestal/wo_mean/Plot_histograms']);
        else
            if(~exist([folder_name 'analysis_matlab/Pedestal/wo_mean/Plot_histograms'],'dir' ))
                mkdir([folder_name 'analysis_matlab/Pedestal/wo_mean/Plot_histograms']);
            end
        end
    end
    
    %% plot all channels
    for ch = channels'
        for pt = peaking_times'
            value = pedestals_mean_values_wo_mean(pedestals_mean_values_wo_mean(:,1)==ch & pedestals_mean_values_wo_mean(:,2)==pt,:);
            % PLOT HISTOGRAM
            f = figure('visible','off');
            hold on
            grid on
            idx_bar_min = find(value(1,10:end) > 0, 1, 'first');
            idx_bar_max = find(value(1,10:end) > 0, 1, 'last');
            bar_min = pedestals_channel_out_ADC_codes2(idx_bar_min);
            bar_max = pedestals_channel_out_ADC_codes2(idx_bar_max);
            mu = value(3);
            sigma = value(4);
            xline(mu,'-.','Color','k','LineWidth',1.2);
            xline(mu + sigma,'-.','Color','k','LineWidth',1.2);
            xline(mu + 2*sigma,'-.','Color','k','LineWidth',1.2);
            xline(mu + 3*sigma,'-.','Color','k','LineWidth',1.2);
            xline(mu - sigma,'-.','Color','k','LineWidth',1.2);
            xline(mu - 2*sigma,'-.','Color','k','LineWidth',1.2);
            xline(mu - 3*sigma,'-.','Color','k','LineWidth',1.2);
            
            fun = @(x)1/(sqrt(2*pi)*sigma)*exp(-(x-mu).^2/(2*sigma^2));
            
            title(['Pedestal of Channel #' num2str(ch) ' - \tau_{' num2str(pt) '}']);
            xlabel('Channel\_out [ADC code]')
            ylabel('Occurencies');
            
            x = bar_min:0.1:bar_max; % asse x per la gaussiana
            bar(pedestals_channel_out_ADC_codes2, value(10:end),1,'EdgeColor','black');
            g = gca;
            text(mu + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'\mu', 'FontSize', 14)
            text(mu + sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'\sigma', 'FontSize', 14)
            text(mu + 2*sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'2\sigma', 'FontSize', 14)
            text(mu + 3*sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'3\sigma', 'FontSize', 14)
            text(mu - sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'-\sigma', 'FontSize', 14)
            text(mu - 2*sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'-2\sigma', 'FontSize', 14)
            text(mu - 3*sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'-3\sigma', 'FontSize', 14)
            
            
            f.WindowState = 'maximized';
            plot(x,fun(x)*trapz(pedestals_channel_out_ADC_codes2,value(10:end)),'r', 'LineWidth', 1.5);
            
            xlim([bar_min - 1,bar_max + 1]);
            str1 = sprintf('#Occurencies: %4d',value(9));
            str2 = ['\mu: ' sprintf('%4.3f', mu) ' [ADC c]'];
            str3 = ['\sigma: ' sprintf('%4.3f', sigma) ' [ADC c]'];
            str = {str1,str2,str3};
            annotation('textbox', [.7 .7 .1 .1], 'String',str,'FitBoxToText','on','BackgroundColor','white')
            % get the original size of figure before the legends are added
            set(gcf, 'unit', 'inches');
            figure_size =  get(gcf, 'position');
            % set new figure size
            set(gcf, 'position', figure_size)
            
            svg_to_save = [folder_name 'analysis_matlab/Pedestal/wo_mean/Plot_histograms/Ch ' num2str(ch)  ' - Pt ' num2str(pt) '.pdf'];
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

