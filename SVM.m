function [ accuracy, correct_predictions ] = SVM( tsecs, prices, volumes )
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
    price_chart = parse_training_data(tsecs_train, prices_train);
    volume_chart = parse_training_data(tsecs_train, volumes_train);
    m = length(price_chart);
    n = 6; % 12 features
    
    %   features
    train_perc_priceHigh = zeros(m - 1, 1);
    train_perc_priceLow = zeros(m - 1, 1);
    train_perc_priceOpen = zeros(m - 1, 1);
    train_perc_volumeHigh = zeros(m - 1, 1);
    train_perc_volumeLow = zeros(m - 1, 1);
    train_perc_volumeOpen = zeros(m - 1, 1);
    
    %   label
    train_labels = zeros(m - 1, 1);
    
    for ii = 2:m;
        
        %   build train_perc_priceHigh
        train_perc_priceHigh(ii - 1) = (price_chart(ii, 1) - price_chart(ii - 1, 1)) / price_chart(ii - 1, 1);
        
        %   build train_perc_priceLow
        train_perc_priceLow(ii - 1) = (price_chart(ii, 2) - price_chart(ii - 1, 2)) / price_chart(ii - 1, 2);
        
        %   build train_perc_priceOpen
        train_perc_priceOpen(ii - 1) = (price_chart(ii, 3) - price_chart(ii - 1, 3)) / price_chart(ii - 1, 3);
        
        %   build train_perc_volumeHigh
        train_perc_volumeHigh(ii - 1) = (volume_chart(ii, 1) - volume_chart(ii - 1, 1)) / volume_chart(ii - 1, 1);
        
        %   build train_perc_volumeLow
        train_perc_volumeLow(ii - 1) = (volume_chart(ii, 2) - volume_chart(ii - 1, 2)) / volume_chart(ii - 1, 2);
        
        %   build train_perc_volumeOpen
        train_perc_volumeOpen(ii - 1) = (volume_chart(ii, 3) - volume_chart(ii - 1, 3)) / volume_chart(ii - 1, 3);
        
        train_labels(ii - 1) = sign(price_chart(ii, 4) - price_chart(ii - 1, 4));
        if train_labels(ii - 1) == 0;
            train_labels(ii - 1) = -1;
        end
    end
    
    % building feature matrix
    train_features = [train_perc_priceHigh train_perc_priceLow train_perc_priceOpen train_perc_volumeHigh train_perc_volumeLow train_perc_volumeOpen];
    % SVM training
    SVMStruct = svmtrain(train_features, train_labels);
    perc_sv = length(SVMStruct.Alpha)/(m-1);
    display(perc_sv);
    
    %% Testing Section
    accuracy = 0;
    correct_predictions = 0;
    total_predictions = 0;
    positive_predictions = 0;
    true_positives = 0;
    profit = 0;
    
    [tsecs_test, prices_test] = range_data(tsecs, prices, train_end, test_end);
    [~, volumes_test] = range_data(tsecs, volumes, train_end, test_end);
    
    test_start_time = tsecs_test(1) + 60 * 5;
    for ii = 1:length(tsecs_test);
        if tsecs_test(ii) >= test_start_time;
            [ price_num_trades, price_high, price_low, price_open ] = minute_block( tsecs_test, prices_test, tsecs_test(ii) );
            [ prev_price_num_trades, prev_price_high, prev_price_low, prev_price_open ] = minute_block( tsecs_test, prices_test, tsecs_test(ii) - 60 );
            
            [ ~, volume_high, volume_low, volume_open ] = minute_block( tsecs_test, volumes_test, tsecs_test(ii) );
            [ ~, prev_volume_high, prev_volume_low, prev_volume_open ] = minute_block( tsecs_test, volumes_test, tsecs_test(ii) - 60 );
            
            if price_num_trades >= 5 && prev_price_num_trades >= 5;
                %   build feature vector
                test_perc_priceHigh = (price_high - prev_price_high) / prev_price_high;
                test_perc_priceLow = (price_low - prev_price_low) / prev_price_low;
                test_perc_priceOpen = (price_open - prev_price_open) / prev_price_open;
                test_perc_volumeHigh = (volume_high - prev_volume_high) / prev_volume_high;
                test_perc_volumeLow = (volume_low - prev_volume_low) / prev_volume_low;
                test_perc_volumeOpen = (volume_open - prev_volume_open) / prev_volume_open;
                test_feature = [test_perc_priceHigh test_perc_priceLow test_perc_priceOpen test_perc_volumeHigh test_perc_volumeLow test_perc_volumeOpen];
                prediction = svmclassify(SVMStruct, test_feature);
                
                total_predictions = total_predictions + 1;
                if prediction == 1;
                    if prices_test(ii + 1) > prices_test(ii);
                        positive_predictions = positive_predictions + 1;
                        true_positives = true_positives + 1;
                        correct_predictions = correct_predictions + 1;
                        profit = profit + 1;
                    elseif prices_test(ii + 1) < prices_test(ii);
                        profit = profit - 1;
                    end
                else
                    if prices_test(ii + 1) > prices_test(ii);
                        true_positives = true_positives + 1;
                    elseif prices_test(ii + 1) < prices_test(ii);
                        correct_predictions = correct_predictions + 1;
                    end
                end
            end
        end
    end
    
    display(profit);
    
    display(correct_predictions);
    display(total_predictions);
    precision = correct_predictions / total_predictions;
    display(precision);
    
    display(positive_predictions);
    display(true_positives);
    recall = positive_predictions / true_positives;
    display(recall);
    
end

