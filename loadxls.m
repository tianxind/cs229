function [ tsecs, prices, volumes ] = loadxls( xlsfile )
%Parses a .xls file from bloomberg download
%   Param: xlsfile is the file name of the .xls file, including extension
%   Return: tsecs is a vector of timestamps in seconds
%           prices is a vector of associated prices
%           volumes is a vector of associated volumes
    
    % these are the indices to reference columns in the .xls file
    hour_index = 9; minute_index = 10; second_index = 11;
    price_index = 3; volume_index = 4;
    
    [~, ~, RAW] = xlsread(xlsfile);
    hours = str2double(RAW(:, hour_index));
    minutes = str2double(RAW(:, minute_index));
    seconds = str2double(RAW(:, second_index));

    tsecs = 3600 * hours + 60 * minutes + seconds;
    prices = [RAW{:, price_index}];
    volumes = [RAW{:, volume_index}];
end

