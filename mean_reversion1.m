function [ correct_prediction, accuracy ] = mean_reversion1( prices )
%Implements mean-reversion and evaluate accuracy
%   Param: prices is a vector of prices
%   Return: correct_prediction is the number of correct predictions
%           accuracy is the percentage accuracy

    correct_prediction = 0;
    prev_forecast = -1;
    for ii = 2:length(prices) - 1;
        % If previous tick is uptick, then forecast downtick
        % Otherwise, then forecast uptick
        forecast = sign(prices(ii - 1) - prices(ii));
        
        % If price remains unchanged, then retain previous forecast
        if forecast == 0;
            forecast = prev_forecast;
        end
        
        if prices(ii + 1) > prices(ii) && forecast == 1;
           correct_prediction = correct_prediction + 1;
        elseif prices(ii + 1) < prices(ii) && forecast == -1;
            correct_prediction = correct_prediction + 1;
        elseif prices(ii + 1) ~= prices(ii);
            correct_prediction = correct_prediction - 1;
        end
    end
    
    accuracy = correct_prediction / (length(prices) - 2);
end

