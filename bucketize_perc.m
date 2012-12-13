% Bucketize percentage into 5 buckets
% bucket 1 -- [0, 25%)
% bucket 2 -- [25%, 50%)
% bucket 3 -- [50%, 75%)
% bucket 4 -- [75%, 100%)
% bucket 5 -- [100%, Inf)
% if percentage is negative, then bucket number is negative
function bucket = bucketize_perc(percentage)
  if percentage < 0 
      bucket = -min(5, floor(-percentage / 0.25) + 1);
  else
      bucket = min(5, floor(percentage / 0.25) + 1);
  end
end