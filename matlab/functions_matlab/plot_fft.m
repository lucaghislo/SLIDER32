function plot_fft(pedestalAllData, folder_name)
channels = 0:31;
peaking_times = 0:7;

%% create folder
if ~exist([folder_name 'analysis_matlab/Pedestal'],'dir' )
    mkdir([folder_name 'analysis_matlab/Pedestal']);
    mkdir([folder_name 'analysis_matlab/Pedestal/fft']);
else
    if(~exist([folder_name 'analysis_matlab/Pedestal/fft'],'dir' ))
        mkdir([folder_name 'analysis_matlab/Pedestal/fft']);
    end
end

%% calculate FFT
for ch = channels
    fig = figure('visible', 'off');
    hold on;
    grid on
    for pt = peaking_times
        x= pedestalAllData(:, ch + 1, pt + 1);
        [y,f] = myfft(x, 64*10e6/2000);
        plot(f, y)
    end
    
    xlabel('Frequency [Hz]');
    ylabel('Channel\_out [ADC code]');
    title(['FFT Channel ' num2str(ch)]);
    set(gca, 'YScale', 'log')
    set(gca, 'XScale', 'log')
    fig.WindowState = 'maximized';
    % get the original size of figure before the legends are added
    set(gcf, 'unit', 'inches');
    figure_size =  get(gcf, 'position');
    %ylim([0 10]);
    
    
    str1 = repmat('\tau_{',length(peaking_times),1);
    str2 = num2str(peaking_times');
    str3 = repmat('}',length(peaking_times),1);
    
    str = [str1 str2 str3];
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
    
    svg_to_save = [ folder_name 'analysis_matlab/Pedestal/fft/ch ' num2str(ch) '.'];
    save_image(svg_to_save, 'pdf', fig)
    close
end

end

