% Implements mean-reversion and evaluate accuracy
% 1 is uptick, and -1 is downtick
% Initialize our first forecast to be an uptick
function accuracy = mean_reversion(price)
    
prev_forecast = -1;
accuracy = 0;
for i=2:numel(price) - 1,
    % If previous tick is uptick, then forecast downtick
    if price(i-1) < price(i)
        forecast = -1;
    % Forecast uptick if prev tick is downtick
    elseif price(i-1) > price(i)
        forecast = 1;
    % Otherwise, retain our previous forecast
    else
        forecast = prev_forecast;
    end
    % Now look at the actual tick and update our accuracy score
    if (price(i+1) > price(i) && forecast == 1) || ...
       (price(i+1) < price(i) && forecast == -1)
        accuracy = accuracy + 1;
    elseif (price(i+1) ~= price(i))
        accuracy = accuracy - 1;
    end 
end
% report accuracy
accuracy = accuracy/(numel(price) - 2);
    