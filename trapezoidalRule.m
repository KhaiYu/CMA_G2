function output = trapezoidalRule(fun, a, b, n)
    %Calculate the step size
    h = (b-a)/n;

    %Create the array of time steps from start a to end b
    x = a:h:b;

    %Evaluate the queue fuction at every time step
    fv = feval(fun, x);

    %Lecturer's vectorized weight arrat for the Trapezoidal formulation
    w = [1; 2*ones(n-1, 1); 1];

    %Calculate the final integral (area unde the curve) via dot product
    output = (h/2.0) * (fv * w);
  endfunction
