close all
clear all
load('GME_raw.mat');
%small = data(1:10,:);
hour = str2double(raw(:,10));
minute = str2double(raw(:,11));
sec = str2double(raw(:,12));
tsecs = 3600*hour+60*minute+sec;
price = [raw{:,3}];
volume = [raw{:,4}];
plot(tsecs,price);
figure
plot(tsecs,volume);                                                                               