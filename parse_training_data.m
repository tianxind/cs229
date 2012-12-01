function [ data_chart ] = parse_training_data( tsecs, data )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    data_chart = [];
    minute_start = tsecs(1);
    minute_open = data(1);
    minute_high = -Inf;
    minute_low = Inf;
    minute_trades = 0;
	for ii = 1 : length(tsecs) - 1;
        if tsecs(ii) - minute_start < 60;
            minute_trades = minute_trades + 1;
            if data(ii) > minute_high && tsecs(ii + 1) < minute_start + 60;
                minute_high = data(ii);                
            end
            if data(ii) < minute_low && tsecs(ii + 1) < minute_start + 60;
                minute_low = data(ii);
            end
        else
            minute_close = data(ii - 1);
            if minute_trades >= 5;
                data_chart = [data_chart; minute_high, minute_low, minute_open, minute_close;];
            end
            % the floor is to skip over the blank minutes
            minute_start = minute_start + floor((tsecs(ii) - minute_start) / 60) * 60;
            minute_high = data(ii);
            minute_low = data(ii);
            minute_open = data(ii);
            minute_trades = 1;
        end
    end
end

