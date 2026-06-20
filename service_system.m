function [patients_matrix,results_before,results_after]= service_system()


%----------------------------------------------------------------------------------
patient_matrix = patients_generate();
[results_before, ~,data_base] = sim_patient_priority(patient_matrix, 1);
[results_after, ~,data_opt] = sim_patient_priority(patient_matrix, 3);
strategic_analysis_report_numerical(data_base, data_opt);

end
%----------------------------------------------------------------------------------
% Generate Patients functions
% Written by Tan Khai Yu
function patients_matrix = patients_generate()

  % Set the default parameter
  total_minutes = 1440; % Open 24 hours in minutes unit
  current_time = 0; % Clock begin at 0
  patients_id = 0; % Patients begin from 0

  % Set Storage Arrays
  arrival_times = [];
  normalize_emergency = [];

  % Loop that randomly generates patient arrival times
  while current_time < total_minutes

      % Set the busy from 8 a.m.(480 minutes) until 8 p.m.(1200 minutes)to peak hour
      if current_time >= 480 && current_time <= 1200
          % Use Lambda set 5 minutes per person in peak hour
          lambda = 1 / 5;
      else
          % Use Lambda set 10 minutes per person in non-peak hour
          lambda = 1 / 10;
      end

 % Random variate formula: X_i = (-1 / lambda) * ln(1 - R_i)
 % Note: ln -> log(x)

      % Generate random number between 0 and 1
      R_i = rand();
      inter_arrival = (-1 / lambda) * log(1 - R_i);

      % Update new current time
      current_time = current_time + inter_arrival;

      % Assign the arrival time to patient
      if current_time <= total_minutes;
        patients_id = patients_id + 1;
        arrival_times(patients_id) = current_time;

          % If random number < 0.3 become emergency case else is nomalize case
          if rand() < 0.3;
            normalize_emergency(patients_id) = 1; % Set 1 become emergency case
          else
            normalize_emergency(patients_id) = 2; % Set 2 become normalize case
          end
      end
  end
    % Set output format
  patients_matrix = [(1:patients_id)',arrival_times',normalize_emergency'];

    % Display Summary Patients Detail
  printf('\n---------------------------------------------------------------------\n');
  printf('\n Function Generate Patients and Assign become Emergency or Normalize \n');
  printf('\n---------------------------------------------------------------------\n');
  printf('\n Total Patients arrived                 : %d\n',patients_id);
  printf('\n Total Patients for Emergency Case      : %d\n',sum (normalize_emergency == 1));
  printf('\n Total Patients for Normalize Case      : %d\n',sum (normalize_emergency == 2));
  printf('\n---------------------------------------------------------------------\n');
end
%--------------------------------------------------------------------------------------
% Multi-Server Priority Queue Simulation
% Written by AL-SAKKAF, MAHMOOD SHAFEQ A`BDULWALI
function [results,summary,report_data] = sim_patient_priority(patients,num_doctors)
  n = size(patients,1);

% Inject random service times
 mean_service = 10;
 svc_times = - mean_service * log(1 - rand(n, 1));
 patients = [patients(:,1:2), svc_times, patients(:,3)];
% Sort by arrival time
 patients = sortrows(patients,2);

% Set the Variables
 curr_time = 0;
 count_time = 0;
 idx = 1;

 queue = [];
 results = [];
 t_doctors = zeros(1, num_doctors); % Track when each doctor will be free

% Matrix structured specifically for strategic_analysis_report_numerical.m
% Format: [ID, Arrival, Priority, StartTime, EndTime]
report_data = zeros(n,5);

while count_time < n
    % Buffer newly arrived patients into the active queue
    while idx <= n && patients(idx,2) <= curr_time
      queue = [queue; patients(idx, :)];
      idx = idx + 1;
    end

  % Find which doctors are free now
  available_doctors = find(t_doctors <= curr_time);

  % Assign the patients to doctor are free now
  if ~isempty(queue) && ~isempty(available_doctors)

    %Filter queue by case emergency,then by arrival time
    %case emergency  = 1 && case normalize = 2
    queue = sortrows (queue, [4,2]);

    %Pop next patients
    curr = queue(1, :);
    queue (1,:) =[];

    p_id = curr(1);
    arrival = curr(2);
    service = curr(3);
    prio =curr(4);

    % Assign to the first available doctor right now
    doc_idx = available_doctors(1);

    % Calculate the  timeline metrics
    t_start = max(curr_time,arrival);
    t_wait = t_start - arrival;
    t_finish = t_start + service;
    t_system = t_finish - arrival;

    %Show the results
    results = [results; p_id, arrival, service, prio, t_start, t_wait, t_finish, t_system];
    report_data(count_time + 1, :) = [p_id, arrival, prio, t_start, t_finish];

    %Update the chosen docter schedule
    t_doctors(doc_idx) = t_finish;
    count_time = count_time + 1;
  else
      % Set next event
      next_event_times = [];

      if idx <= n
        next_event_times = [next_event_times,patients(idx, 2)];
      end

      busy_doctors =  t_doctors(t_doctors > curr_time);

      if ~isempty(busy_doctors)
        next_event_times = [next_event_times, min(busy_doctors)];
      end

      if ~isempty(next_event_times);
        curr_time = min(next_event_times);
      end
    end
  end

  % Aggregate performance metrics
  summary = mean(results(:,[6,3,8]),1);
end
%-----------------------------------------------------------------------------------------------------
% Strategic analysis report generator
% Written by NG YONG QI
function strategic_analysis_report_numerical(baseline_matrix, optimized_matrix)

  %Define simulation parameters
  scenarios = {baseline_matrix, optimized_matrix};
  scen_names = {'Baseline (Scenario A: 1 Doctor)', 'Optimized (Scenario B: 3 Doctors)'};

  total_time_mins = 1440; %24-hour simulation

  %level 4 component A requires multiple doctors.
  %assume baseline has 1 doctor, optimized has 3
  server_counts = [1, 3];

  %Pre-allocate tracking arrays for automated scenario visualization
  plot_waits = zeros(1, 2);
  plot_queues = zeros(1, 2);
  plot_utilization = zeros(1, 2);

  %Display structural ASCII interface
  printf('\n=====================================================================\n');
  printf('           CMA6134-T2610 EMERGENCY DEPARTMENT STRATEGIC REPORT         \n');
  printf('                 COMPUTED PERFORMANCE METRICS (LEVEL 4 QC)             \n');
  printf('\n=====================================================================\n');


  for s = 1:2
    data = scenarios{s};

    % Extract exact data columns from teammate matrix handoffs
    arr   = data(:, 2); % Arrival Times
    cases = data(:, 3); % Priority levels (1 = Emergency, 2 = Normal)
    st    = data(:, 4); % Service Start Times
    ends  = data(:, 5); % Service End Times

    %% METRIC 1: average waiting time
    total_served = size(data, 1);

    %% METRIC 2: Average Waiting Time
    wait_times = st - arr;
    avg_wait_overall = mean(wait_times);

    % Level 4 proof: Breaking down wait times by priority
    avg_wait_emergency = mean(wait_times(cases == 1));
    avg_wait_normal = mean(wait_times(cases == 2));

    %% METRIC 3: Average Queue Length via lec's trapezoidal rule
    % Bind the current data to the q_func interface
    current_q_handle = @(t) q_func(t, arr, st);

    % Integrate from t=0 to t=1440 with 1440 steps (1 minute intervals)
    total_area = trapezoidalRule(current_q_handle, 0, total_time_mins, total_time_mins);
    avg_queue_length = total_area / total_time_mins;

    %% METRIC 4: Docotr Utilization
    % total minutes spent treating patients across all doctors
    total_busy_time = sum(ends - st);

    % Maximum possible minutes of service capacity
    max_capacity = total_time_mins * server_counts(s);
    utilization_rate = (total_busy_time / max_capacity) * 100;

    % Store metrics for plotting
    plot_waits(s) = avg_wait_overall;
    plot_queues(s) = avg_queue_length;
    plot_utilization(s) = utilization_rate;

    %% Display Summary Data
    printf('\n >> %s \n', scen_names{s});
    printf('---------------------------------------------------------------------\n');
    printf(' [1] Total Patients Served           : %d patients\n', total_served);
      printf(' [2] Average Waiting Time (Overall)  : %-10.2f minutes\n', avg_wait_overall);
      printf('     - Priority 1 (Emergency) Waits  : %-10.2f minutes\n', avg_wait_emergency);
      printf('     - Priority 2 (Normal) Waits     : %-10.2f minutes\n', avg_wait_normal);
      printf(' [3] Average Queue Length (Integral) : %-10.2f patients\n', avg_queue_length);
      printf(' [4] Doctor Utilization (%d Doctors)  : %-10.2f %%\n', server_counts(s), utilization_rate);
    end
    printf('=====================================================================\n\n');

    %%Automated side by side Visualization (fulfills component C "Compare Scenarios")
    printf('>> Generating Performance Comparison Charts...\n\n');
    grid on;

    subplot(1, 2, 1);
    bar([1, 2], [plot_waits; plot_queues]');
    title('Patient Experience Metric');
    ylabel('Scale (Minutes / Patients)');
    legend('Avg. Wait Times', 'Avg. Queue Length', 'location', 'northeast');
    set(gca, 'XTick', [1, 2], 'XTickLabel', {'BaseLine', 'Optimized'});
    grid on;

    subplot(1, 2, 2);
    bar([1, 2], plot_utilization);
    title('Doctor Utilization Metrics');
    ylabel('Utilization Percentage (%)');
    ylim([0 100]);
    set(gca, 'XTick', [1, 2], 'XTickLabel', {'Baseline', 'Optimized'});
    grid on;

  endfunction
%------------------------------------------------------------------------------------------------------
%Extra Mathematical Helpers
%Written by NG YONG QI
function y = q_func(x, arr, st)

  %calculates how many patients are in the queue at every time poinnt 'x'
  y = zeros(1, length(x));

  for i = 1:length(x)
   % patients arrived but haven't started service yet
    y(i) = sum((arr <= x(i)) & (st > x(i)));
  end
endfunction

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
