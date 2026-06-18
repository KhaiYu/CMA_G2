function strategic_analysis_report_numerical(baseline_matrix, optimized_matrix)

  scenarios = {baseline_matrix, optimized_matrix};
  scen_names = {'Baseline (Scenario A: 1 Doctor)', 'Optimized (Scenario B: 3 Doctors)'};

  total_time_mins = 1440; %24-hour simulation


  server_counts = [1, 3];

  plot_waits = zeros(1, 2);
  plot_queues = zeros(1, 2);
  plot_utilization = zeros(1, 2);

  printf('\n=====================================================================\n');
  printf('           CMA6134-T2610 EMERGENCY DEPARTMENT STRATEGIC REPORT         \n');
  printf('                 COMPUTED PERFORMANCE METRICS (LEVEL 4 QC)             \n');
  printf('\n=====================================================================\n');


  for s = 1:2
    data = scenarios{s};

    arr   = data(:, 2); % Arrival Times
    cases = data(:, 3); % Priority levels (1 = Emergency, 2 = Normal)
    st    = data(:, 4); % Service Start Times
    ends  = data(:, 5); % Service End Times

    total_served = size(data, 1);

    wait_times = st - arr;
    avg_wait_overall = mean(wait_times);

    avg_wait_emergency = mean(wait_times(cases == 1));
    avg_wait_normal = mean(wait_times(cases == 2));

    current_q_handle = @(t) q_func(t, arr, st);

    total_area = trapezoidalRule(current_q_handle, 0, total_time_mins, total_time_mins);
    avg_queue_length = total_area / total_time_mins;

    total_busy_time = sum(ends - st);

    max_capacity = total_time_mins * server_counts(s);
    utilization_rate = (total_busy_time / max_capacity) * 100;

    plot_waits(s) = avg_wait_overall;
    plot_queues(s) = avg_queue_length;
    plot_utilization(s) = utilization_rate;

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

