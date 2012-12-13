% linear regression to predict if next move is upbig/downbig or
% upsmall/downsmall
function model = regression(price, tsecs)
close all
% Train on trades from 9:30am to 10am
starttime = 9*3600+30*60;
endtime = 10*3600;
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
%% Test on the next 30 minutes
% testend = endtime + 30*60;
% test_pidx=(tsecs > endtime) & (tsecs < testend);
% price_test = price(test_pidx);
% tsecs_test = tsecs(test_pidx); 
% Calculate rolling 5 minute spread
% test_spread = spread(test_pidx);
%spread = rolling5HL(price_train, tsecs_train);
% Calculate price movement at every tick
% test_prev_p = price_test(1:numel(price_test)-1);
% test_diff_p = price_test(2:numel(price_test)) - test_prev_p;
% Generate all regression variables
% test_movesmall = zeros(numel(test_diff_p), 1);
% test_movebig = zeros(numel(test_diff_p), 1);
% for i=1:numel(test_diff_p);
    % if movement is smaller than 50% of the 5 min spread, then it is a 
    % small move
  %  if abs(test_diff_p(i)) < 0.5 * test_spread(i);
  %      if test_diff_p(i) < 0;
  %          test_movesmall(i) = -1;
  %      else
  %          test_movesmall(i) = 1;
  %      end
    % Otherwise, it is a big move 
  %  else
  %      if test_diff_p(i) < 0;
            test_movebig(i) = -1;
  %      else
  %          test_movebig(i) = 1;
  %      end
  %  end
% end
% Make prediction and plot the prediction
x = [ones(numel(test_movesmall), 1) test_movesmall test_movebig];
pred = x * model.beta;

% report coefficients
% model.beta
% plot(tsecs_train(2:end), y);
% hold all
% plot(tsecs_train(2:end), pred);
% legend('original', 'ours');