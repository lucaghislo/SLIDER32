function analyzeEverything(start, stop, type)

% type is ASIC for asic and MODULE for module
for iFolder=start:stop
    if (~exist(strcat('/home/lucaghislotti/Documents/SLIDER32/MODULE',num2str(iFolder, '%03d'),'_fast'),'dir'))
        continue
    end

    disp([type ' #' num2str(iFolder, '%03d')])
%     movefile(strcat(type,'_',num2str(iFolder, '%03d'),'\1\data'));

    % move file to correct folder
    movefile(strcat('/home/lucaghislotti/Documents/SLIDER32/MODULE',num2str(iFolder, '%03d'),'_fast'), strcat(type,'_',num2str(iFolder, '%03d')));

    folder_name = strcat(type,'_',num2str(iFolder, '%03d'),'/-36A/');
    slider32_clearmem;
%     movefile('data', strcat(type,'_',num2str(iFolder, '%03d'),'\1'));
%     movefile('analysis_matlab', strcat(type,'_',num2str(iFolder, '%03d'),'\1'));
end