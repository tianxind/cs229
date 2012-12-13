function E2ERegressionTest
% Test on all .mat files in data folder
files = dir('data/*.mat');
num_files = length(files);
% Output file name
output = 'reg_results.xlsx';
profit = zeros(num_files, 1);
precision = zeros(num_files, 1);
recall = zeros(num_files, 1);
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
    [model profit(i), precision(i), recall(i)] = ...
        regression_new(tsecs, prices, volumes);
    
end
% Write output to xls file
xlswrite(output, [profit precision recall]);
avg_profit = mean(profit);
display(avg_profit);