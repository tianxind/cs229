function [model, profit, precision, recall] = regression_new( tsecs, prices, volumes)
    train_start = 9 * 3600 + 30 * 60;
    train_end = 10 * 3600 + 30 * 60;
    
    [tsecs_train, prices_train] = range_data(tsecs, prices, train_start, train_end);   
    [~, volumes_train] = range_data(tsecs, volumes, train_start, train_end);
    
    price_chart = parse_training_data(tsecs_train, prices_train);
    volume_chart = parse_training_data(tsecs_train, volumes_train);
    m = length(price_chart);
    %n = 6; % 12 features
    n =2;
    nMin = 5;  
    train_perc_priceHigh = zeros(m - nMin - 1, 1);
    train_perc_priceLow = zeros(m - nMin - 1, 1);
    train_perc_priceOpen = zeros(m - nMin - 1, 1);
    train_perc_volumeHigh = zeros(m - nMin - 1, 1);
    train_perc_volumeLow = zeros(m - nMin - 1, 1);
    train_perc_volumeOpen = zeros(m - nMin - 1, 1);
    train_nmin_price_spread = zeros(m - nMin - 1, 1);
    train_nmin_volume_spread = zeros(m - nMin - 1, 1);
    train_labels = zeros(m - nMin - 1, 1);

    for ii = nMin + 1:m;
        train_nmin_price_spread(ii - nMin) = getNMinuteSpread(price_chart, nMin, ii - nMin);
        train_nmin_volume_spread(ii - nMin) = getNMinuteSpread(volume_chart, nMin, ii - nMin);
        %   build train_perc_priceHigh
        % train_perc_priceHigh(ii - nMin) = (price_chart(ii, 1) - price_chart(ii - 1, 1)) / price_chart(ii - 1, 1);
        
        %   build train_perc_priceLow
        % train_perc_priceLow(ii - nMin) = (price_chart(ii, 2) - price_chart(ii - 1, 2)) / price_chart(ii - 1, 2);
        
        %   build train_perc_priceOpen
        % build feature that represents the magnitude of price change with regard
        % to n-minute rolling spread
        train_perc_priceOpen(ii - nMin) = (price_chart(ii, 3) - price_chart(ii - 1, 3)) / train_nmin_price_spread(ii - nMin);
        train_perc_priceOpen(ii - nMin) = bucketize_perc(train_perc_priceOpen(ii - nMin));
        
        %   build train_perc_volumeHigh
        % train_perc_volumeHigh(ii - nMin) = (volume_chart(ii, 1) - volume_chart(ii - 1, 1)) / volume_chart(ii - 1, 1);
        
        %   build train_perc_volumeLow
        % train_perc_volumeLow(ii - nMin) = (volume_chart(ii, 2) - volume_chart(ii - 1, 2)) / volume_chart(ii - 1, 2);
        
        %   build train_perc_volumeOpen
        % build feature that represents the magnitude of volume change with regard
        % to n-minute rolling spread
        train_perc_volumeOpen(ii - nMin) = (volume_chart(ii, 3) - volume_chart(ii - 1, 3)) / train_nmin_volume_spread(ii - nMin);
        train_perc_volumeOpen(ii - nMin) = bucketize_perc(train_perc_volumeOpen(ii - nMin));
        
        train_labels(ii - nMin) = (price_chart(ii, 4) - price_chart(ii - 1, 4))/price_chart(ii - 1,4);
        %train_labels(ii - 1) = sign(price_chart(ii, 4) - price_chart(ii - 1, 4));
        %if train_labels(ii - 1) == 0;
        %    train_labels(ii - 1) = -1;
        %end
    end
    
    % building feature matrix
    %train_features = [train_perc_priceHigh train_perc_priceLow train_perc_priceOpen train_perc_volumeHigh train_perc_volumeLow train_perc_volumeOpen];
    train_features = [train_perc_priceOpen train_perc_volumeOpen];
    % UWLR training
    model = regstats(train_labels, train_features);
    
    %% Testing UWLR on 30-min after TRAINING set end
    correct_predictions = 0;
    total_predictions = 0;
    positive_predictions = 0;
    true_positives = 0;
    profit = 0;
    
    test_start = train_end;
    test_end = train_end + 60 * 60;
    [tsecs_test, prices_test] = range_data(tsecs, prices, test_start, test_end);   
    [~, volumes_test] = range_data(tsecs, volumes, test_start, test_end);
    
    test_price_chart = parse_training_data(tsecs_test, prices_test);
    test_volume_chart = parse_training_data(tsecs_test, volumes_test);
    m = length(test_price_chart);
    %n = 6; % 12 features
    n =2;
    
    test_perc_priceHigh = zeros(m - nMin - 1, 1);
    test_perc_priceLow = zeros(m - nMin - 1, 1);
    test_perc_priceOpen = zeros(m - nMin - 1, 1);
    test_perc_volumeHigh = zeros(m - nMin - 1, 1);
    test_perc_volumeLow = zeros(m - nMin - 1, 1);
    test_perc_volumeOpen = zeros(m - nMin - 1, 1);
    test_nmin_price_spread = zeros(m - nMin - 1, 1);
    test_nmin_volume_spread = zeros(m - nMin - 1, 1);
    nMin = 5;
    for ii = nMin + 1:m;
        test_nmin_price_spread(ii - nMin) = getNMinuteSpread(test_price_chart, nMin, ii - nMin);
        test_nmin_volume_spread(ii - nMin) = getNMinuteSpread(test_volume_chart, nMin, ii - nMin);
        %   build train_perc_priceHigh
        % train_perc_priceHigh(ii - nMin) = (price_chart(ii, 1) - price_chart(ii - 1, 1)) / price_chart(ii - 1, 1);
        
        %   build train_perc_priceLow
        % train_perc_priceLow(ii - nMin) = (price_chart(ii, 2) - price_chart(ii - 1, 2)) / price_chart(ii - 1, 2);
        
        %   build train_perc_priceOpen
        % build feature that represents the magnitude of price change with regard
        % to n-minute rolling spread
        test_perc_priceOpen(ii - nMin) = (test_price_chart(ii, 3) - test_price_chart(ii - 1, 3)) / test_nmin_price_spread(ii - nMin);
        test_perc_priceOpen(ii - nMin) = bucketize_perc(test_perc_priceOpen(ii - nMin));
        
        %   build train_perc_volumeHigh
        % train_perc_volumeHigh(ii - nMin) = (volume_chart(ii, 1) - volume_chart(ii - 1, 1)) / volume_chart(ii - 1, 1);
        
        %   build train_perc_volumeLow
        % train_perc_volumeLow(ii - nMin) = (volume_chart(ii, 2) - volume_chart(ii - 1, 2)) / volume_chart(ii - 1, 2);
        
        %   build train_perc_volumeOpen
        % build feature that represents the magnitude of volume change with regard
        % to n-minute rolling spread
        test_perc_volumeOpen(ii - nMin) = (test_volume_chart(ii, 3) - test_volume_chart(ii - 1, 3)) / test_nmin_volume_spread(ii - nMin);
        test_perc_volumeOpen(ii - nMin) = bucketize_perc(test_perc_volumeOpen(ii - nMin));
        
        %train_labels(ii - 1) = sign(price_chart(ii, 4) - price_chart(ii - 1, 4));
        %if train_labels(ii - 1) == 0;
        %    train_labels(ii - 1) = -1;
        %end
    end
    
    x = [ones(length(test_perc_priceOpen), 1) test_perc_priceOpen test_perc_volumeOpen];
    predictions = x * model.beta;
    % Calculate test results
    for ii = nMin + 1:m;
        % We buy in if the percentage change is bigger than 10%
        if predictions(ii - nMin) > 0,
            if test_price_chart(ii, 4) > test_price_chart(ii - 1, 4),
                positive_predictions = positive_predictions + 1;
                true_positives = true_positives + 1;
                correct_predictions = correct_predictions + 1;
                profit = profit + 1;
            elseif test_price_chart(ii, 4) < test_price_chart(ii - 1, 4),
                profit = profit - 1;
            end
        else
            if test_price_chart(ii, 4) > test_price_chart(ii - 1, 4);
                true_positives = true_positives + 1;
            elseif test_price_chart(ii, 4) < test_price_chart(ii - 1, 4);
                correct_predictions = correct_predictions + 1;
            end
        end
    end
    total_predictions = length(predictions);
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