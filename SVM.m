function [ accuracy, correct_predictions, SVMStruct ] = SVM( tsecs, prices, volumes )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
%   Features:
%       5 minute HL
%       change in volume
    
    %% SVM Training Section
    
    train_start = 9 * 3600 + 30 * 60;
    train_end = 11 * 3600;
    test_end = 18 * 3600;
    
    [tsecs_train, prices_train] = range_data(tsecs, prices, train_start, train_end);    
    [~, volumes_train] = range_data(tsecs, volumes, train_start, train_end);
    m = length(tsecs_train) - 1;
    n = 4;    
    train_perc_priceHL = zeros(m, 1);
    train_perc_price = zeros(m, 1);
    train_perc_volumeHL = zeros(m, 1);
    train_perc_volume = zeros(m, 1);
    
    % build vector of percentage change in price
    rollingHL_price = rolling5HL(tsecs, prices);
    [~, train_rollingHL_price] = range_data(tsecs, rollingHL_price, train_start, train_end);
    for ii = 1:m;
        train_perc_priceHL(ii) = (prices_train(ii + 1) - prices_train(ii)) / train_rollingHL_price(ii + 1);
    end
    
    % build tick-by-tick percentage change in price
    for ii = 1:m;
        train_perc_price(ii) = (prices_train(ii + 1) - prices_train(ii)) / prices_train(ii + 1);
    end

    % build vector of percentage change in volume
    rollingHL_volume = rolling5HL(tsecs, volumes);
    [~, train_rollingHL_volume] = range_data(tsecs, rollingHL_volume, train_start, train_end);
    for ii = 1:m;
        train_perc_volumeHL(ii) = (volumes_train(ii + 1) - volumes_train(ii)) / train_rollingHL_volume(ii + 1);
    end
    
    % build tick-by-tick percentage change in price
    for ii = 1:m;
        train_perc_volume(ii) = (volumes_train(ii + 1) - volumes_train(ii)) / volumes_train(ii + 1);
    end
    
    % building label vector
    train_labels = zeros(m, 1);
    prev_trend = -1;
    for ii = 1:m;
        train_labels(ii) = sign(prices_train(ii + 1) - prices(ii));
        if train_labels(ii) == 0;
            train_labels(ii) = prev_trend;
        end
        prev_trend = train_labels(ii);
    end
    train_labels = train_labels(2:m);
    
    % building feature matrix
    train_features = [train_perc_priceHL train_perc_price train_perc_volumeHL train_perc_volume];
    %train_features = [train_perc_priceHL train_perc_volumeHL];
    %train_features = [train_perc_price train_perc_volume];
    %train_features = [train_perc_priceHL train_perc_volumeHL];
    train_features = train_features(1 : m-1, :);
    % SVM training
    SVMStruct = svmtrain(train_features, train_labels, 'showplot', true);
    perc_sv = length(SVMStruct.Alpha)/(m-1);
    display(perc_sv);
    
    %% Testing Section
    accuracy = 0;
    correct_predictions = 0;
    profit = 0;
    
    [tsecs_test, prices_test] = range_data(tsecs, prices, train_end, test_end);
    [~, volumes_test] = range_data(tsecs, volumes, train_end, test_end);
    [~, test_rollingHL_price] = range_data(tsecs, rollingHL_price, train_end, test_end);
    [~, test_rollingHL_volume] = range_data(tsecs, rollingHL_volume, train_end, test_end);
    
    for ii = 2:length(tsecs_test)-1;
        perc_priceHL = (prices_test(ii) - prices_test(ii - 1)) / test_rollingHL_price(ii);
        perc_price = (prices_test(ii) - prices_test(ii - 1)) / prices_test(ii);
        perc_volumeHL = (volumes_test(ii) - volumes_test(ii - 1)) / test_rollingHL_volume(ii);
        perc_volume = (volumes_test(ii) - volumes_test(ii - 1)) / volumes_test(ii);
        feature = [perc_priceHL perc_price perc_volumeHL perc_volume];
        %feature = [perc_priceHL perc_volumeHL];
        prediction = svmclassify(SVMStruct, feature);
        if prediction == 1;
            if prices_test(ii + 1) > prices_test(ii);
                profit = profit + 1;
            elseif prices_test(ii + 1) < prices_test(ii);
                profit = profit - 1;
            end
        end
    end
    
    display(profit);
end

