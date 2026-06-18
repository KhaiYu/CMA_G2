function output = trapezoidalRule(fun, a, b, n)
    h = (b-a)/n;

    x = a:h:b;

    fv = feval(fun, x);

    w = [1; 2*ones(n-1, 1); 1];

    output = (h/2.0) * (fv * w);
  endfunction
