function spread = getNMinuteSpread(data, n, start)
  spread = max(data(start: start + n - 1)) - min(data(start: start + n -1));
end