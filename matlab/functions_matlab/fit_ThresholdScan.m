function [fitParameters] = fit_ThresholdScan(threshold_mean_values, folder_name)
%% INPUT 
% threshold_mean_values: dati ottenuti dai file originali

%% CREAZIONE CARTELLE PER PLOT DATI
if ~exist([folder_name 'analysis_matlab/ThresholdScan'],'dir' )
    mkdir([folder_name 'analysis_matlab/ThresholdScan']);   
end

%% FITTING
if ~exist([folder_name 'analysis_matlab/ThresholdScan/fitParameters.dat'],'file' )
    myFitType = fittype(@(a,b,x) 0.5 + 0.5*erf((x-a)/(sqrt(2)*b)));
    
    channels = unique(threshold_mean_values(:,1));
    length_channels = length(channels);
    peaking_times = unique(threshold_mean_values(:,2));
    length_peaking_times = length(peaking_times);
    fine_threshold = unique(threshold_mean_values(:,3));
    length_fine_threshold = length(fine_threshold);
    discriminator_threshold = unique(threshold_mean_values(:,4));
    length_discriminator_threshold = length(discriminator_threshold);
    FIT_threshold = 220;
    FIT_noise = 5;
    
    fitParameters=zeros(length_channels*length_peaking_times*length_fine_threshold,5);
    
    for ch = channels'
        idx_ch = find(ch == channels);
        for pt = peaking_times'
            idx_pt = find(pt == peaking_times);
            for fin_thr = fine_threshold'
                idx_fin_thr = find(fin_thr == fine_threshold);
                init_pos = (idx_ch - 1)*length_fine_threshold*length_peaking_times*length_discriminator_threshold + (idx_pt - 1)*length_fine_threshold*length_discriminator_threshold + (idx_fin_thr - 1)*length_discriminator_threshold + 1;
                end_pos = init_pos + length_discriminator_threshold - 1;
                data = threshold_mean_values(init_pos:end_pos,6)./threshold_mean_values(init_pos:end_pos,5);
                myFit = fit(discriminator_threshold,data,myFitType,'Lower',[0,0],'Upper',[Inf,Inf],'StartPoint',[FIT_threshold FIT_noise]);
                
                fit_pos = (idx_ch - 1)*length_peaking_times*length_fine_threshold + (idx_pt -1)*length_fine_threshold + idx_fin_thr;
                value = [ch pt fin_thr coeffvalues(myFit)];
                fitParameters(fit_pos,:) = value;
            end
        end
    end
else
    fitParameters = readmatrix([folder_name 'analysis_matlab/ThresholdScan/fitParameters.dat']);
end

%% SAVE DATA
fileID = fopen([folder_name 'analysis_matlab/ThresholdScan/fitParameters.dat'],'w');
fprintf(fileID,'%s\t%s\t%s\t%s\t%s\r\n','ch','pt','fine_thr','a_fit','b_fit');
fprintf(fileID,'%2d\t%2d\t%2d\t%5.3f\t%5.3f\r\n',fitParameters');
fclose(fileID);

end

