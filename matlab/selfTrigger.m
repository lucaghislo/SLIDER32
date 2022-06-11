clear all
path = 'Measure 28/';

%% create folder
if ~exist([path 'analysis_matlab/SelfTrigger'],'dir' )
    mkdir([path 'analysis_matlab/SelfTrigger']);
    mkdir([path 'analysis_matlab/SelfTrigger/Plot_histograms']);
else
    if(~exist([path 'analysis_matlab/SelfTrigger/Plot_histograms'],'dir' ))
        mkdir([path 'analysis_matlab/SelfTrigger/Plot_histograms']);
    end
end

%% process data

for ch = 0 : 31
   importedData = importdata([path 'data/SelfTrigger_ch' num2str(ch) '.dat']);
   importedData = importedData.data;
   
   value = importedData((importedData(:,2)==00 | importedData(:,2)==10) & importedData(:,3)==(ch) & importedData(:,4) < 1900,4);
   % PLOT HISTOGRAM
   f = figure;
   hold on
   grid on
   histogram(value);
   
   mu = mean(value);
   sigma = std(value);
   
   
   if (~isnan(mu) && ~isnan(sigma))
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
        
   x = min(value):0.1:max(value); % asse x per la gaussiana
   % bar(self_trigger_channel_out_ADC_codes, value(9:end),1,'EdgeColor','black');
   g = gca;
   if (~isnan(mu) && ~isnan(sigma))
       text(mu + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'\mu', 'FontSize', 14)
       text(mu + sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'\sigma', 'FontSize', 14)
       text(mu + 2*sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'2\sigma', 'FontSize', 14)
       text(mu + 3*sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'3\sigma', 'FontSize', 14)
       text(mu - sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'-\sigma', 'FontSize', 14)
       text(mu - 2*sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'-2\sigma', 'FontSize', 14)
       text(mu - 3*sigma + 0.2,(g.YAxis.Limits(2)-g.YAxis.Limits(1))/100*92 + g.YAxis.Limits(1),'-3\sigma', 'FontSize', 14)
       % plot(x,fun(x)*trapz(self_trigger_channel_out_ADC_codes,value(9:end)),'r', 'LineWidth', 1.5);
   end
   
   f.WindowState = 'maximized';
   
   
   
   str1 = sprintf('#Occurencies: %4d',size(value,1));
   str2 = ['\mu: ' sprintf('%4.3f', mu) ' [ADC c]'];
   str3 = ['\sigma: ' sprintf('%4.3f', sigma) ' [ADC c]'];
   str = {str1,str2,str3};
   annotation('textbox', [.7 .7 .1 .1], 'String',str,'FitBoxToText','on','BackgroundColor','white')
   % get the original size of figure before the legends are added
   set(gcf, 'unit', 'inches');
   figure_size =  get(gcf, 'position');
   % set new figure size
   set(gcf, 'position', figure_size)
   
   svg_to_save = [path 'analysis_matlab/SelfTrigger/Plot_histograms/Ch ' num2str(ch) '.pdf'];
   set(f, 'PaperUnits','centimeters');
   set(f, 'Units','centimeters');
   pos=get(f,'Position');
   set(f, 'PaperSize', [pos(3) pos(4)]);
   set(f, 'PaperPositionMode', 'manual');
   set(f, 'PaperPosition',[0 0 pos(3) pos(4)]);
   print(svg_to_save,'-dpdf')
   close
end