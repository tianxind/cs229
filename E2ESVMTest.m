function E2ESVMTest
% Test on all .mat files in data folder
files = dir('data/*.mat');
num_files = length(files);
% Output file name
output = 'svm_results.xlsx';
profit = zeros(num_files, 1);
precision = zeros(num_files, 1);
recall = zeros(num_files, 1);
correct_predictions = zeros(num_files, 1);
total_predictions = zeros(num_files, 1);
for i = 1:num_files,
    fullname = strcat('data/', files(i).name); 
    load (fullname);
    strcat(fullname, '...')
    % create tsecs, prices, volumes vector
    hour = str2double(raw(:,9));
    minute = str2double(raw(:,10));
    sec = str2double(raw(:,11));
    tsecs = 3600*hour+60*minute+sec;
    prices = [raw{:,3}];
    volumes = [raw{:,4}];
    % Call SVM and report evaluation metrics
    [profit(i), precision(i), recall(i), correct_predictions(i), total_predictions(i)] = ...
        SVM(tsecs, prices, volumes);
end
% Write output to xls file
xlswrite(output, [profit precision recall correct_predictions total_predictions]);