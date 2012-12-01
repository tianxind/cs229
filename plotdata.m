close all
clear all
load('GME_raw.mat');
%small = data(1:10,:);


hour = str2double(raw(:,10));
minute = str2double(raw(:,11));
sec = str2double(raw(:,12));
tsecs = 3600*hour+60*minute+sec;
prices = [raw{:,3}];
volumes = [raw{:,4}];
plot(tsecs,prices);
figure
plot(tsecs,volumes);              



%%  Plot Data in 1-minute buckets
price_chart = parse_training_data(tsecs, prices);
volume_chart = parse_training_data(tsecs, volumes);

price_highs = price_chart(:, 1);
price_lows = price_chart(:, 2);
price_opens = price_chart(:, 3);
price_closes = price_chart(:, 4);


volume_highs = volume_chart(:, 1);
volume_lows = volume_chart(:, 2);
volume_opens = volume_chart(:, 3);
volume_closes = volume_chart(:, 4);

figure

subplot(2, 1, 1);
hold all
plot(price_highs);
plot(price_lows);
plot(price_opens);
plot(price_closes);

subplot(2, 1, 2);
hold all
plot(volume_highs);
plot(volume_lows);
plot(volume_opens);
plot(volume_closes);