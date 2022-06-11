function [fitMeanData, pedestals_mean_values_wo_fit] = pedestal_fit(allData,pedestal_data_for_ch_mean, channels_to_not_consider, plot_PEDESTALS, folder_name)
channels = 0:31;
channels_to_plot = channels(~ismember(channels, channels_to_not_consider));
    
length_channels = length(channels);
peaking_times = 0:7;
length_peaking_times = length(peaking_times);
linear_fit = zeros(length_channels*length_peaking_times,4);
number_of_pedestals = 1000;

zoom_min = 101;
zoom_max = 200;


%% CALCOLO FIT AND PLOT FIT DATA

%% create folder
if (plot_PEDESTALS(11)==1)
    if ~exist([folder_name 'analysis_matlab/Pedestal'],'dir' )
        mkdir([folder_name 'analysis_matlab/Pedestal']);
        mkdir([folder_name 'analysis_matlab/Pedestal/wo_fit']);
        mkdir([folder_name 'analysis_matlab/Pedestal/wo_fit/Fit_data']);
    else
        if(~exist([folder_name 'analysis_matlab/Pedestal/wo_fit'],'dir' ))
            mkdir([folder_name 'analysis_matlab/Pedestal/wo_fit']);
            mkdir([folder_name 'analysis_matlab/Pedestal/wo_fit/Fit_data']);
        else
            if (~exist([folder_name 'analysis_matlab/Pedestal/wo_fit/Fit_data'],'dir' ))
                mkdir([folder_name 'analysis_matlab/Pedestal/wo_fit/Fit_data']);
            end
        end
    end
end

%% calculate fit anf plot normal vs mean
pos = 1;
for ch = channels
    for pt = peaking_times       
        P = polyfit(allData(:,ch + 1,pt + 1),pedestal_data_for_ch_mean(:,pt + 1),1);
        value = [ch pt P(1) P(2)];
        linear_fit(pos,:) = value;
        
        if (plot_PEDESTALS(11)==1)
            f1 = figure('visible','off');
            hold on
            scatter(allData(:,ch + 1,pt + 1),pedestal_data_for_ch_mean(:,pt + 1));
            
            title(['Pedestal fit - ch ' num2str(ch) '- \tau_{' num2str(pt) '}']);
            xlabel('Original Pedestal')
            ylabel('Mean Pedestals')
            x_min = min(allData(:,ch + 1,pt + 1));
            x_max = max(allData(:,ch + 1,pt + 1));
            x_axis = x_min:x_max;
            yfit = P(1)*x_axis+P(2);
            
            plot(x_axis,yfit,'r');
            
            f1.WindowState = 'maximized';
            
            % get the original size of figure before the legends are added
            set(gcf, 'unit', 'inches');
            figure_size =  get(gcf, 'position');
            
            % new figure width
            figure_size(3) = figure_size(3);
            % set new figure size
            set(gcf, 'position', figure_size)
            
            
            svg_to_save = [folder_name 'analysis_matlab/Pedestal/wo_fit/Fit_data/Ch ' num2str(ch) ' - pt ' num2str(pt) '.'];
            save_image(svg_to_save, 'pdf', f1)
            close    
        end
        pos = pos + 1;
    end
end

%% SAVE COEFFICIENTS ON FILE
if ~exist([folder_name 'analysis_matlab/Pedestal/wo_fit/coefficients.dat'],'file') % Creo il file solo se non esiste già
    fileID = fopen([folder_name 'analysis_matlab/Pedestal/wo_fit/coefficients.dat'],'w');
    fprintf(fileID,'%2s/t%2s/t%s/t%s/r/n','ch','pt','m','q');
    format = '%2d/t%2d/t%5.4f/t%5.4f/r/n';
    fprintf(fileID,format,linear_fit');
    fclose(fileID);
end

%% RIEMPIMENTO FIT MEAN DATA

fitMeanData = zeros(number_of_pedestals,length_channels, length_peaking_times);
for ch = channels
    for pt = peaking_times
        k = linear_fit(linear_fit(:,1)==ch & linear_fit(:,2)==pt,3);
        fitMeanData(:, ch + 1, pt + 1) = allData(:,ch + 1, pt + 1) - 1/k.*pedestal_data_for_ch_mean(:, pt + 1);
    end
end

%% CALCOLO MEAN VALUES FIT DA FIT MEAN DATA
fitMeanData_max = max(fitMeanData(:,:,:),[],'all');
fitMeanData_min = min(fitMeanData(:,:,:),[],'all');

fitMeanData_max = ceil(fitMeanData_max);
fitMeanData_min = floor(fitMeanData_min);

pedestals_channel_out_ADC_codes3 = fitMeanData_min:fitMeanData_max;
length_channel_out_ADC_code3 = length(pedestals_channel_out_ADC_codes3);

pedestals_mean_values_wo_fit = zeros(length_channels * length_peaking_times, 9 + length_channel_out_ADC_code3);

for pt = peaking_times
    for ch = channels
        data = fitMeanData(:,ch + 1, pt + 1);
        count_occurencies = histcounts(data,[pedestals_channel_out_ADC_codes3, fitMeanData_max + 1]-0.5);
        data_mean = mean(data);
        data_std = std(data);
        data_median = median(data);
        [data_without_outliers, boolean_outliers] = rmoutliers(data);
        data_mean_wout_outliers = mean(data_without_outliers);
        data_std_wout_outliers = std(data_without_outliers);
        outliers = data(boolean_outliers);
        pos = ch * length_peaking_times + pt + 1;
        
        value = [ch pt data_mean data_std data_median length(outliers) data_mean_wout_outliers data_std_wout_outliers length(data) count_occurencies];
        pedestals_mean_values_wo_fit(pos,:) = value;
    end
    
end

%% SAVE FIT MEAN VALUES ON FILE
pedestals_file_data = [folder_name '/data/Pedestal_wo_fit.dat'];
fileID = fopen(pedestals_file_data,'w');
fprintf(fileID,'%2s/t%2s/t%4s/t%4s/t%3s/t%6s/t%8s/t%12s/t%11s/t%7s','ch','pt','mean','std','median','outliers','mean_w/o_out', 'std_w/o_out','samples');
first_line = sprintf('%4s/t',strcat('#',string(pedestals_channel_out_ADC_codes3)));
first_line = first_line(1:end-1);
fprintf(fileID,'%s/r/n',first_line);

max_size = length_channels * length_peaking_times;
for line = 1 : max_size
    fprintf(fileID,'%2d/t%2d/t%7.2f/t%7.2f/t%6.1f/t%4d/t%7.2f/t%6.2f/t%4d',pedestals_mean_values_wo_fit(line,1:9)');
    line_string = sprintf('%4s/t',string(pedestals_mean_values_wo_fit(line,10:end)));
    line_string = line_string(1:end-1);
    fprintf(fileID,'%s/r/n',line_string);
end
fclose(fileID);

%% PLOT PEDESTALS WITHOUT FIT - ALL TIME
if (plot_PEDESTALS(9) == 1)  
    %% create folder
    if ~exist([folder_name 'analysis_matlab/Pedestal'],'dir' )
        mkdir([folder_name 'analysis_matlab/Pedestal']);
        mkdir([folder_name 'analysis_matlab/Pedestal/wo_fit']);
        mkdir([folder_name 'analysis_matlab/Pedestal/wo_fit/Plot_all_Cases_byTime']);
    else
        if(~exist([folder_name 'analysis_matlab/Pedestal/wo_fit'],'dir' ))
            mkdir([folder_name 'analysis_matlab/Pedestal/wo_fit']);
            mkdir([folder_name 'analysis_matlab/Pedestal/wo_fit/Plot_all_Cases_byTime']);
        else
            if (~exist([folder_name 'analysis_matlab/Pedestal/wo_fit/Plot_all_Cases_byTime'],'dir' ))
                mkdir([folder_name 'analysis_matlab/Pedestal/wo_fit/Plot_all_Cases_byTime']);
            end
        end
    end
    
    %% plot selected channels
    for pt = peaking_times
        f = figure('visible','off');
        hold on
        grid on
        
        for ch = channels_to_plot
            plot(fitMeanData(:,ch + 1, pt + 1));
        end
        
        title(['Pedestal in Time of \tau_{' num2str(pt) '}']);
        xlabel('Time')
        ylabel('Channel\_out [ADC code]');
        %ylim([y_min1 y_max1]);
        f.WindowState = 'maximized';
        
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
        str_1 = repmat('Ch #',length(channels_to_plot'),1);
        str_2 = num2str(channels_to_plot','%02d');
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
        
        
        svg_to_save = [folder_name 'analysis_matlab/Pedestal/wo_fit/Plot_all_Cases_byTime/Pt ' num2str(pt) '.'];
        save_image(svg_to_save, 'pdf', f)
        close
    end
    
end

%% PLOT PEDESTALS WITHOUT FIT - ZOOM
if (plot_PEDESTALS(10) == 1)
    %% create folder
    if ~exist([folder_name 'analysis_matlab/Pedestal'],'dir' )
        mkdir([folder_name 'analysis_matlab/Pedestal']);
        mkdir([folder_name 'analysis_matlab/Pedestal/wo_fit']);
        mkdir([folder_name 'analysis_matlab/Pedestal/wo_fit/Plot_all_Cases_byTime_ZOOM']);
    else
        if(~exist([folder_name 'analysis_matlab/Pedestal/wo_fit'],'dir' ))
            mkdir([folder_name 'analysis_matlab/Pedestal/wo_fit']);
            mkdir([folder_name 'analysis_matlab/Pedestal/wo_fit/Plot_all_Cases_byTime_ZOOM']);
        else
            if (~exist([folder_name 'analysis_matlab/Pedestal/wo_fit/Plot_all_Cases_byTime_ZOOM'],'dir' ))
                mkdir([folder_name 'analysis_matlab/Pedestal/wo_fit/Plot_all_Cases_byTime_ZOOM']);
            end
        end
    end
    
    %% plot selected channels
    for pt = peaking_times
        f = figure('visible','off');
        hold on
        grid on
        
        for ch = channels_to_plot
            plot(fitMeanData(zoom_min:zoom_max,ch + 1, pt + 1));
        end
        
        title(['Pedestal in Time of \tau_{' num2str(pt) '}']);
        xlabel('Time')
        ylabel('Channel\_out [ADC code]');
        %    ylim([y_min1 y_max1]);
        
        f.WindowState = 'maximized';
        
        % get the original size of figure before the legends are added
        set(gcf, 'unit', 'inches');
        figure_size =  get(gcf, 'position');
        
        str_1 = repmat('Ch #',length(channels_to_plot'),1);
        str_2 = num2str(channels_to_plot','%02d');
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
        
        
        svg_to_save = [folder_name 'analysis_matlab/Pedestal/wo_fit/Plot_all_Cases_byTime_ZOOM/Pt ' num2str(pt) '.'];
        save_image(svg_to_save, 'pdf', f)
        close
    end
    
end

%% PLOT HISTOGRAMS
if (plot_PEDESTALS(8) == 1)
    %% create folder
    if ~exist([folder_name 'analysis_matlab/Pedestal'],'dir' )
        mkdir([folder_name 'analysis_matlab/Pedestal']);
        mkdir([folder_name 'analysis_matlab/Pedestal/wo_fit']);
        mkdir([folder_name 'analysis_matlab/Pedestal/wo_fit/Plot_histograms']);
    else
        if(~exist([folder_name 'analysis_matlab/Pedestal/wo_fit'],'dir' ))
            mkdir([folder_name 'analysis_matlab/Pedestal/wo_fit']);
            mkdir([folder_name 'analysis_matlab/Pedestal/wo_fit/Plot_histograms']);
        else
            if (~exist([folder_name 'analysis_matlab/Pedestal/wo_fit/Plot_histograms'],'dir' ))
                mkdir([folder_name 'analysis_matlab/Pedestal/wo_fit/Plot_histograms']);
            end
        end
    end
    
    %% plot all channels
    for ch = channels
        for pt = peaking_times
            value = pedestals_mean_values_wo_fit(pedestals_mean_values_wo_fit(:,1)==ch & pedestals_mean_values_wo_fit(:,2)==pt,:);
            % PLOT HISTOGRAM
            f = figure('visible','off');
            hold on
            grid on
            idx_bar_min = find(value(1,10:end) > 0, 1, 'first');
            idx_bar_max = find(value(1,10:end) > 0, 1, 'last');
            bar_min = pedestals_channel_out_ADC_codes3(idx_bar_min);
            bar_max = pedestals_channel_out_ADC_codes3(idx_bar_max);
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
            bar(pedestals_channel_out_ADC_codes3, value(10:end),1,'EdgeColor','black');
            g = gca;
            text(mu + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'\mu', 'FontSize', 14)
            text(mu + sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'\sigma', 'FontSize', 14)
            text(mu + 2*sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'2\sigma', 'FontSize', 14)
            text(mu + 3*sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'3\sigma', 'FontSize', 14)
            text(mu - sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'-\sigma', 'FontSize', 14)
            text(mu - 2*sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'-2\sigma', 'FontSize', 14)
            text(mu - 3*sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'-3\sigma', 'FontSize', 14)
            
            
            f.WindowState = 'maximized';
            plot(x,fun(x)*trapz(pedestals_channel_out_ADC_codes3,value(10:end)),'r', 'LineWidth', 1.5);
            
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
            
            svg_to_save = [folder_name 'analysis_matlab/Pedestal/wo_fit/Plot_histograms/Ch ' num2str(ch)  ' - Pt ' num2str(pt) '.pdf'];
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

