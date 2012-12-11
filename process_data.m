%% Read all .xlsx file and save them in .mat format for faster processing
% Get all files in 'data' folder
files = dir('data/*.xlsx');
for k = 1:length(files)
    var_name = files(k).name;
    % Get rid of the extension
    var_name = var_name(1:strfind(var_name, '.xlsx') - 1);
    [~, ~, raw] = xlsread(strcat('data/',files(k).name));
    % Save as .mat file
    mat_file_name = strcat('data/', strcat(var_name,'.mat'));
    save(mat_file_name, 'raw');
end