function [model, profit, precision, recall] = regression( tsecs, prices, volumes)
    train_start = 9 * 3600 + 30 * 60;
    train_end = 11*3600;
    
    [tsecs_train, prices_train] = range_data(tsecs, prices, train_start, train_end);   
    [~, volumes_train] = range_data(tsecs, volumes, train_start, train_end);
    
    price_chart = parse_training_data(tsecs_train, prices_train);
    volume_chart = parse_training_data(tsecs_train, volumes_train);
    m = length(price_chart);
    %n = 6; % 12 features
    n =2;
    
    train_perc_priceHigh = zeros(m - 1, 1);
    train_perc_priceLow = zeros(m - 1, 1);
    train_perc_priceOpen = zeros(m - 1, 1);
    train_perc_volumeHigh = zeros(m - 1, 1);
    train_perc_volumeLow = zeros(m - 1, 1);
    train_perc_volumeOpen = zeros(m - 1, 1);
    
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
        
        train_labels(ii - 1) = (price_chart(ii, 4) - price_chart(ii - 1, 4))/price_chart(ii - 1,4);
        %train_labels(ii - 1) = sign(price_chart(ii, 4) - price_chart(ii - 1, 4));
        %if train_labels(ii - 1) == 0;
        %    train_labels(ii - 1) = -1;
        %end
    end
    
    % building feature matrix
    %train_features = [train_perc_priceHigh train_perc_priceLow train_perc_priceOpen train_perc_volumeHigh train_perc_volumeLow train_perc_volumeOpen];
    train_features = [train_perc_priceHigh train_perc_priceLow];
    % UWLR training
    model = regstats(train_labels, train_features);
    
    % Testing UWLR on TRAINING set
    correct_predictions = 0;
    total_predictions = 0;
    positive_predictions = 0;
    true_positives = 0;
    profit = 0;
    
    % Calculating results
    train_start_time = tsecs_train(1) + 60 * 5;
    for ii = 1:length(tsecs_train) - 1;
        if tsecs_train(ii) >= train_start_time;
            [ price_num_trades, price_high, price_low, price_open ] = minute_block( tsecs_train, prices_train, tsecs_train(ii) );
            [ prev_price_num_trades, prev_price_high, prev_price_low, prev_price_open ] = minute_block( tsecs_train, prices_train, tsecs_train(ii) - 60 );
            
            [ ~, volume_high, volume_low, volume_open ] = minute_block( tsecs_train, volumes_train, tsecs_train(ii) );
            [ ~, prev_volume_high, prev_volume_low, prev_volume_open ] = minute_block( tsecs_train, volumes_train, tsecs_train(ii) - 60 );
            
            if price_num_trades >= 5 && prev_price_num_trades >= 5;
                %   build feature vector
                train_perc_priceHigh = (price_high - prev_price_high) / prev_price_high;
                train_perc_priceLow = (price_low - prev_price_low) / prev_price_low;
                train_perc_priceOpen = (price_open - prev_price_open) / prev_price_open;
                train_perc_volumeHigh = (volume_high - prev_volume_high) / prev_volume_high;
                train_perc_volumeLow = (volume_low - prev_volume_low) / prev_volume_low;
                train_perc_volumeOpen = (volume_open - prev_volume_open) / prev_volume_open;
                %train_feature = [ones(length(train_perc_priceHigh), 1) train_perc_priceHigh train_perc_priceLow train_perc_priceOpen train_perc_volumeHigh train_perc_volumeLow train_perc_volumeOpen];
                train_feature = [ones(length(train_perc_priceHigh), 1) train_perc_priceHigh train_perc_priceLow];
                
                prediction = train_feature * model.beta;
                
                total_predictions = total_predictions + 1;
                %display(model.beta);
                if prediction > 0.001;
                    if prices_train(ii + 1) > prices_train(ii);
                        positive_predictions = positive_predictions + 1;
                        true_positives = true_positives + 1;
                        correct_predictions = correct_predictions + 1;
                    elseif prices_train(ii + 1) < prices_train(ii);
                        profit = profit - 1;
                    end
                else
                    if prices_train(ii + 1) > prices_train(ii);
                        true_positives = true_positives + 1;
                    elseif prices_train(ii + 1) < prices_train(ii);
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