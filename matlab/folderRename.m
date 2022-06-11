function folderRename(start, stop)
%% Start e Stop sono numeri interi supposti consecutivi
%% Da utilizzare con cautela, perchè non c'è un Ctrl+Z !!!!!
for i = start:stop
folderName = strcat('ASIC_',num2str(i));
mkdir(folderName);
movefile(strcat('MODULE',num2str(i),'_fast/1'), strcat('ASIC_',num2str(i)));
rmdir(strcat('MODULE',num2str(i),'_fast'));
end