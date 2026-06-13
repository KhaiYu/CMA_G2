function y = q_func(x, arr, st)

  %calculates how many patients are in the queue at every time poinnt 'x'
  y = zeros(1, length(x));

  for i = 1:length(x)
   % patients arrived but haven't started service yet
    y(i) = sum((arr <= x(i)) & (st > x(i)));
  end
endfunction

