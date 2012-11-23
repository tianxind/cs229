% Calculate an array of rolling 5 minute high-low
function rollingSpread = rolling5HL(tsecs, price)
rollingSpread = zeros(1, numel(price));
high = -Inf*ones(1,5);
low = Inf*ones(1,5);
% Use dynamic programming to calculate previous 5 minutes high-low
last_bucket_start = tsecs(1);
for i=1:numel(price),
   elapsed = tsecs(i) - last_bucket_start;
   bucket_shift = floor(elapsed/60);
   last_bucket_start = last_bucket_start + 60 * bucket_shift;
   % shift every bucket by 'bucket_shift'
   high(1:5-bucket_shift) = high(1+bucket_shift:end);
   low(1:5-bucket_shift) = low(1+bucket_shift:end);
   % Initialize all unitialized high bucket to -Inf
   high(max(5-bucket_shift+1,1):end) = -Inf*ones(1, min(bucket_shift,5));
   low(max(5-bucket_shift+1,1):end) = Inf*ones(1, min(bucket_shift,5));
   % Update high and low at current bucket
   if price(i) > high(5)
       high(5) = price(i);
   end
   if price(i) < low(5)
       low(5) = price(i);
   end
   % Calculate high low for last 5 minutes and copy it into final answer
   % array
   high5Min = max(high);
   low5Min = min(low);
   rollingSpread(i) = high5Min - low5Min;
end
end