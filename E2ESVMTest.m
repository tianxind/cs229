function E2ESVMTest(filename)
% filename must be .mat file
load (filename);
% create tsecs, prices, volumes vector
hour = str2double(raw(:,10));
minute = str2double(raw(:,11));
sec = str2double(raw(:,12));
tsecs = 3600*hour+60*minute+sec;
prices = [raw{:,3}];
volumes = [raw{:,4}];
% Call SVM and report evaluation metrics
SVM(tsecs, prices, volumes);