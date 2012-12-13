% linear regression to predict if next move is upbig/downbig or
% upsmall/downsmall
function model = regression(price, tsecs)
close all
% Train on trades from 9:30am to 12:30pm
starttime = 9*3600+30*60;
endtime = 11*3600;
pidx=(tsecs > starttime) & (tsecs < endtime);
price_train = price(pidx);
tsecs_train = tsecs(pidx); 
% Calculate rolling 5 minute spread
spread = rolling5HL(tsecs,price);
spread = spread(pidx);
%spread = rolling5HL(price_train, tsecs_train);
% Calculate price movement at every tick
prev_p = price_train(1:numel(price_train)-1);
diff_p = price_train(2:numel(price_train)) - prev_p;
% Generate all regression variables
movesmall = zeros(numel(diff_p), 1);
movebig = zeros(numel(diff_p), 1);
y = zeros(numel(diff_p), 1);
for i=1:numel(diff_p);
    % if movement is smaller than 50% of the 5 min spread, then it is a 
    % small move
    if abs(diff_p(i)) < 0.5 * spread(i);
        if diff_p(i) < 0;
            movesmall(i) = -1;
        else
            movesmall(i) = 1;
        end
    % Otherwise, it is a big move 
    else
        if diff_p(i) < 0;
            movebig(i) = -1;
        else
            movebig(i) = 1;
        end
    end
    % Our Y variable is the percentage change from last price
    y(i) = price_train(i+1)/price_train(i) - 1;
end
% Run regression of y on movebig and movesmall
model = regstats(y, [movesmall movebig]);
[y movesmall movebig]
% Make prediction and plot the prediction
x = [ones(numel(movesmall), 1) movesmall movebig];
pred = x * model.beta;
% report coefficients
model.beta
plot(tsecs_train(2:end), y);
hold all
plot(tsecs_train(2:end), pred);
legend('original', 'ours');