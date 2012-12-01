function [ num_trades, high, low, open ] = minute_block( tsecs, data, current_time )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    num_trades = 0;
    open = -1;
    high = -Inf;
    low = Inf;
    for ii = 1 : length(tsecs);
        if tsecs(ii) >= current_time - 60 && tsecs(ii) < current_time;
            num_trades = num_trades + 1;
            if open == -1;
                open = data(ii);
            end
            if data(ii) > high;
                high = data(ii);
            end
            if data(ii) < low;
                low = data(ii);
            end
        end
    end
end

