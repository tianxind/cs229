function [ tsecs_sector, values_sector ] = range_data( tsecs, values, start_time, end_time )
%Find a sector of data that has time in between starttime and endtime
%   Param: starttime, endtime are in seconds
%   Return: tsecs_sector, prices_sector are timestamps, prices, volumes of
%           data in the specified range.
    
    pidx = (tsecs > start_time) & (tsecs < end_time);
    tsecs_sector = tsecs(pidx);
    values_sector = values(pidx);

end