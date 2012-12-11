function E2ESVMTest
% Test on all .mat files in data folder
files = dir('data/*.mat');
for i = 1:length(files),
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
    SVM(tsecs, prices, volumes);
end