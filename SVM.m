function [ profit, precision, recall, accuracy ] = SVM( tsecs, prices, volumes )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
%   Features:
%       5 minute HL
%       change in volume
    
    %% SVM Training Section
    
    train_start = 9 * 3600 + 30 * 60;
    train_end = train_start + 3600;
    test_end = train_end + 60 * 60;
    
    [tsecs_train, prices_train] = range_data(tsecs, prices, train_start, train_end);   
    [~, volumes_train] = range_data(tsecs, volumes, train_start, train_end);
    price_chart = parse_training_data(tsecs_train, prices_train);
    volume_chart = parse_training_data(tsecs_train, volumes_train);
    m = length(price_chart);
    n = 8; % 12 features
    nMin = 5; % Compute relative magnitude of change compared to 5-min spread
    % absolute percentage features
    % train_perc_priceLow = zeros(m - nMin - 1, 1);
    train_perc_priceOpen = zeros(m - nMin - 1, 1);
    train_perc_priceHigh = zeros(m - nMin - 1, 1);
    train_perc_volumeHigh = zeros(m - nMin - 1, 1);
    % train_perc_volumeLow = zeros(m - nMin - 1, 1);
    train_perc_volumeOpen = zeros(m - nMin - 1, 1);
    % relative magnitude features
    train_priceOpen_magnitude = zeros(m - nMin - 1, 1);
    train_volumeOpen_magnitude = zeros(m - nMin - 1, 1);
    %   label
    train_labels = zeros(m - nMin - 1, 1);
    
    % start from nMin + 1 since we want nMin high-low spread
    for ii = nMin + 1:m;
        
        %   build train_perc_priceHigh
        train_perc_priceHigh(ii - nMin) = (price_chart(ii - 1, 1) - price_chart(ii - 2, 1)) / price_chart(ii - 2, 1);
        
        %   build train_perc_priceLow
        train_perc_priceLow(ii - nMin) = (price_chart(ii - 1, 2) - price_chart(ii - 2, 2)) / price_chart(ii - 2, 2);
        
        %   build train_perc_priceOpen
        train_perc_priceOpen(ii - nMin) = (price_chart(ii, 3) - price_chart(ii - 1, 3)) / price_chart(ii - 1, 3);
        
        %   build train_perc_volumeHigh
        train_perc_volumeHigh(ii - nMin) = (volume_chart(ii - 1, 1) - volume_chart(ii - 2, 1)) / volume_chart(ii - 2, 1);
        
        %   build train_perc_volumeLow
        train_perc_volumeLow(ii - nMin) = (volume_chart(ii - 1, 2) - volume_chart(ii - 2, 2)) / volume_chart(ii - 2, 2);
        
        %   build train_perc_volumeOpen
        train_perc_volumeOpen(ii - nMin) = (volume_chart(ii, 3) - volume_chart(ii - 1, 3)) / volume_chart(ii - 1, 3);
        
        % build features that represent relative magnitude change of price and volume
        train_priceOpen_magnitude(ii - nMin) = bucketize_perc(train_perc_priceOpen(ii - nMin)...
            /getNMinuteSpread(price_chart, nMin, ii - nMin));
        train_volumeOpen_magnitude(ii - nMin) = bucketize_perc(train_perc_volumeOpen(ii - nMin)...
            /getNMinuteSpread(volume_chart, nMin, ii - nMin));
        % build training labels, -1 for downtrend/no change, 1 for uptrend
        train_labels(ii - nMin) = sign(price_chart(ii, 4) - price_chart(ii - 1, 4));
        if train_labels(ii - nMin) == 0;
            train_labels(ii - nMin) = -1;
        end
    end
    
    % building feature matrix
    train_features = [train_perc_priceOpen train_perc_volumeOpen ...
                      train_perc_priceHigh train_perc_volumeHigh ...
                      train_perc_priceLow train_perc_volumeLow ...
                      train_priceOpen_magnitude train_volumeOpen_magnitude];
    % SVM training
    SVMStruct = svmtrain(train_features, train_labels);
    perc_sv = length(SVMStruct.Alpha)/(m-1);
    display(perc_sv);
    
    %% Testing Section
    accuracy = 0;
    total_predictions = 0;
    % The correct positive predictions
    profit = 0;
    
    [tsecs_test, prices_test] = range_data(tsecs, prices, train_end, test_end);
    [~, volumes_test] = range_data(tsecs, volumes, train_end, test_end);
    test_price_chart = parse_training_data(tsecs_test, prices_test);
    test_volume_chart = parse_training_data(tsecs_test, volumes_test);
    m = length(test_price_chart);
    
    predicted_1 = 0;
    true_1 = 0;
    true_0 = 0;
    positives = 0;
    
    for ii = nMin + 1:m;
        %   build feature vector
        %   build train_perc_priceHigh
        test_perc_priceHigh = (test_price_chart(ii - 1, 1) - test_price_chart(ii - 2, 1)) / test_price_chart(ii - 2, 1);
        
        %   build train_perc_priceLow
        test_perc_priceLow = (test_price_chart(ii - 1, 2) - test_price_chart(ii - 2, 2)) / test_price_chart(ii - 2, 2);
        
        %   build train_perc_priceOpen
        test_perc_priceOpen = (test_price_chart(ii, 3) - test_price_chart(ii - 1, 3)) / test_price_chart(ii - 1, 3);
        
        %   build train_perc_volumeHigh
        test_perc_volumeHigh = (test_volume_chart(ii - 1, 1) - test_volume_chart(ii - 2, 1)) / test_volume_chart(ii - 2, 1);
        
        %   build train_perc_volumeLow
        test_perc_volumeLow = (test_volume_chart(ii - 1, 2) - test_volume_chart(ii - 2, 2)) / test_volume_chart(ii - 2, 2);
        
        %   build train_perc_volumeOpen
        test_perc_volumeOpen = (test_volume_chart(ii, 3) - test_volume_chart(ii - 1, 3)) / test_volume_chart(ii - 1, 3);
        
        % build features that represent relative magnitude change of price and volume
        test_priceOpen_magnitude = bucketize_perc(test_perc_priceOpen...
            /getNMinuteSpread(test_price_chart, nMin, ii - nMin));
        test_volumeOpen_magnitude = bucketize_perc(test_perc_volumeOpen...
            /getNMinuteSpread(test_volume_chart, nMin, ii - nMin));
        
        % build entire test feature vector and use SVM to classify
        test_feature = [test_perc_priceOpen test_perc_volumeOpen ...
                        test_perc_priceHigh test_perc_volumeHigh ...
                        test_perc_priceLow test_perc_volumeLow ...
                        test_priceOpen_magnitude test_volumeOpen_magnitude];
        prediction = svmclassify(SVMStruct, test_feature);
        
        % Calculate metrics
        total_predictions = total_predictions + 1;
        
        if prediction == 1;
           predicted_1 = predicted_1 + 1;
           if test_price_chart(ii + 1, 4) > test_price_chart(ii, 4);
              true_1 = true_1 + 1;
              %positive_predictions = positive_predictions + 1;
              %true_positives = true_positives + 1;
              %correct_predictions = correct_predictions + 1;
              profit = profit + test_price_chart(ii + 1, 4) - test_price_chart(ii, 4);
              positives = positives + 1;
           elseif test_price_chart(ii + 1, 4) < test_price_chart(ii, 4);
              profit = profit - (test_price_chart(ii + 1, 4) - test_price_chart(ii, 4));
           end
        else
           predicted_0 = predicted_0 + 1;
           if test_price_chart(ii + 1, 4) > test_price_chart(ii, 4);
               positives = positives + 1;
              %true_positives = true_positives + 1;
           elseif test_price_chart(ii + 1, 4) < test_price_chart(ii, 4);
              true_0 = true_0 + 1;
              %correct_predictions = correct_predictions + 1;
           end
        end
    end
    
    display(profit);
    
    % display(correct_predictions);
    % display(total_predictions);
    precision = true_1 / predicted_1;
    display(precision);
    
    
    accuracy = (true_0 + true_1) / total_predictions;
    display(accuracy);
    
    recall = true_1 / positives;
    display(recall);
    
end

