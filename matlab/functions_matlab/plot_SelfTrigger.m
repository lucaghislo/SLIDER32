function plot_SelfTrigger(self_trigger_mean_values, self_trigger_channel_out_ADC_codes, allDataSelfTrigger, plot_SELF_TRIGGER, channels_to_not_consider, folder_name)

channels = unique(self_trigger_mean_values(:,1));

channels_to_plot = channels(~ismember(channels, channels_to_not_consider));
zoom_min = 101;
zoom_max = 200;

a = channels_to_plot + 1;
data1 = allDataSelfTrigger(:,a',:); 

y_min1 = min(data1,[],'all');
y_max1 = max(data1,[],'all');

%% PLOT self_trigger NORMAL - ALL TIME
if (plot_SELF_TRIGGER(2)==1)
    %% create folder
    if ~exist([folder_name 'analysis_matlab/SelfTrigger'],'dir' )
        mkdir([folder_name 'analysis_matlab/SelfTrigger']);
        mkdir([folder_name 'analysis_matlab/SelfTrigger/Plot_all_cases']);
    else
        if(~exist([folder_name 'analysis_matlab/SelfTrigger/Plot_all_cases'],'dir' ))
            mkdir([folder_name 'analysis_matlab/SelfTrigger/Plot_all_cases']);
        end
    end
    
    %% plot selected channels
    f = figure('visible', 'off');
    hold on
    grid on
    
    for ch = channels_to_plot'
        plotting = allDataSelfTrigger(:,ch + 1);
        plotting = plotting(plotting>0,:);
        plot(plotting);
    end
    
    title('Self Trigger in Time');
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
    
    
    svg_to_save = [folder_name 'analysis_matlab/SelfTrigger/Plot_all_cases/ST.'];
    save_image(svg_to_save, 'pdf', f)
    close

end

%% PLOT self_trigger NORMAL - ZOOM
if (plot_SELF_TRIGGER(3)==1)
    %% create folder
    if ~exist([folder_name 'analysis_matlab/SelfTrigger'],'dir' )
        mkdir([folder_name 'analysis_matlab/SelfTrigger']);
        mkdir([folder_name 'analysis_matlab/SelfTrigger/Plot_all_cases_ZOOM']);
    else
        if(~exist([folder_name 'analysis_matlab/SelfTrigger/Plot_all_cases_ZOOM'],'dir' ))
            mkdir([folder_name 'analysis_matlab/SelfTrigger/Plot_all_cases_ZOOM']);
        end
    end
    
    %% plot selected channels
    f = figure('visible', 'off');
    hold on
    grid on
    
    for ch = channels_to_plot'
        plotting = allDataSelfTrigger(:,ch + 1);
        plotting = plotting(plotting > 0, :);
        if(length(plotting) < zoom_max)
            zoom_max = length(plotting);
        end
        if( zoom_max - 100 < 1)
            zoom_min = 1;
        end        
        plot(plotting(zoom_min:zoom_max));
    end
    
    title('Self Trigger in Time');
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
    
    
    svg_to_save = [folder_name 'analysis_matlab/SelfTrigger/Plot_all_cases_ZOOM/ST.'];
    save_image(svg_to_save, 'pdf', f)
    close

end

%% PLOT self_trigger NORMAL - HISTOGRAM
if (plot_SELF_TRIGGER(1)==1)
    %% create folder
    if ~exist([folder_name 'analysis_matlab/SelfTrigger'],'dir' )
        mkdir([folder_name 'analysis_matlab/SelfTrigger']);
        mkdir([folder_name 'analysis_matlab/SelfTrigger/Plot_histograms']);
    else
        if(~exist([folder_name 'analysis_matlab/SelfTrigger/Plot_histograms'],'dir' ))
            mkdir([folder_name 'analysis_matlab/SelfTrigger/Plot_histograms']);
        end
    end
    
    %% plot all channels
    for ch = channels'
        value = self_trigger_mean_values(self_trigger_mean_values(:,1)==ch,:);
        % PLOT HISTOGRAM
        f = figure('visible', 'off');
        hold on
        grid on
        idx_bar_min = find(value(1,9:end) > 0, 1, 'first');
        idx_bar_max = find(value(1,9:end) > 0, 1, 'last');
        bar_min = self_trigger_channel_out_ADC_codes(idx_bar_min);
        bar_max = self_trigger_channel_out_ADC_codes(idx_bar_max);
        mu = value(2);
        sigma = value(3);
        if(~isnan(mu) && ~isnan(sigma))
            xline(mu,'-.','Color','k','LineWidth',1.2);
            xline(mu + sigma,'-.','Color','k','LineWidth',1.2);
            xline(mu + 2*sigma,'-.','Color','k','LineWidth',1.2);
            xline(mu + 3*sigma,'-.','Color','k','LineWidth',1.2);
            xline(mu - sigma,'-.','Color','k','LineWidth',1.2);
            xline(mu - 2*sigma,'-.','Color','k','LineWidth',1.2);
            xline(mu - 3*sigma,'-.','Color','k','LineWidth',1.2);
        
        fun = @(x)1/(sqrt(2*pi)*sigma)*exp(-(x-mu).^2/(2*sigma^2));
        end
        title(['Pedestal of Channel #' num2str(ch)]);
        xlabel('Channel\_out [ADC code]')
        ylabel('Occurencies');
        
        x = bar_min:0.1:bar_max; % asse x per la gaussiana
        bar(self_trigger_channel_out_ADC_codes, value(9:end),1,'EdgeColor','black');
        g = gca;
        if(~isnan(mu) && ~isnan(sigma))
            text(mu + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'\mu', 'FontSize', 14)
            text(mu + sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'\sigma', 'FontSize', 14)
            text(mu + 2*sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'2\sigma', 'FontSize', 14)
            text(mu + 3*sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'3\sigma', 'FontSize', 14)
            text(mu - sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'-\sigma', 'FontSize', 14)
            text(mu - 2*sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'-2\sigma', 'FontSize', 14)
            text(mu - 3*sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'-3\sigma', 'FontSize', 14)
            plot(x,fun(x)*trapz(self_trigger_channel_out_ADC_codes,value(9:end)),'r', 'LineWidth', 1.5);
        
        end
        
        f.WindowState = 'maximized';

        
        if(size(xlim) > 2)
            xlim([bar_min - 1,bar_max + 1]);
        end
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
        
        svg_to_save = [folder_name 'analysis_matlab/SelfTrigger/Plot_histograms/Ch ' num2str(ch) '.pdf'];
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

