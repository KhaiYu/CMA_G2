function y = q_func(x, arr, st)

  y = zeros(1, length(x));

  for i = 1:length(x)
    y(i) = sum((arr <= x(i)) & (st > x(i)));
  end
endfunction

