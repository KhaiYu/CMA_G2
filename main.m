function [patients_matrix, results, summary] = run_hospital_simulation()

    patients_matrix = patients_generate();

    [results, summary] = sim_patient_priority(patients_matrix);

end


function patients_matrix = patients_generate() % Set the default parameter total_minutes = 1440; % Open 24 hours in minutes unit current_time = 0; % Clock begin at 0 patients_id = 0; % Patients begin from 0 % Set Storage Arrays arrival_times = []; normalize_emergency = []; % Loop that randomly generates patient arrival times while current_time < total_minutes % Set the busy from 8 a.m.(480 minutes) until 8 p.m.(1200 minutes)to peak hour if current_time >= 480 && current_time <= 1200 % Use Lambda set 5 minutes per person in peak hour lambda = 1 / 5; else % Use Lambda set 10 minutes per person in non-peak hour lambda = 1 / 10; end % Random variate formula: X_i = (-1 / lambda) * ln(1 - R_i) % Note: ln -> log(x) % Generate random number between 0 and 1 R_i = rand(); inter_arrival = (-1 / lambda) * log(1 - R_i); % Update new current time current_time = current_time + inter_arrival; % Assign the arrival time to patient if current_time <= total_minutes; patients_id = patients_id + 1; arrival_times(patients_id) = current_time; % If random number < 0.3 become emergency case else is nomalize case if rand() < 0.3; normalize_emergency(patients_id) = 1; % Set 1 become emergency case else normalize_emergency(patients_id) = 2; % Set 2 become normalize case end end end % Set output format patients_matrix = [(1:patients_id)',arrival_times',normalize_emergency']; % Display Summary Patients Detail printf('\n---------------------------------------------------------------------\n'); printf('\n Function Generate Patients and Assign become Emergency or Normalize \n'); printf('\n Wrtten by : TAN KHAI YU \n'); printf('\n---------------------------------------------------------------------\n'); printf('\n Total Patients arrived : %d\n',patients_id); printf('\n Total Patients for Emergency Case : %d\n',sum (normalize_emergency == 1)); printf('\n Total Patients for Normalize Case : %d\n',sum (normalize_emergency == 2)); printf('\n---------------------------------------------------------------------\n'); %------------------------------------------------------------------------------------------------ % Set a interface design printf('\n---------------------------------------------------------------------\n'); printf('\n Patients Detail Record Summary \n'); printf('\n---------------------------------------------------------------------\n'); printf('%-12s | %-16s | %-16s | %-10s\n', 'Patients ID','Time(minutes)','Clock','Case Level'); printf('\n---------------------------------------------------------------------\n'); % Set the time format and assign the case level for i = 1:patients_id; minutes = arrival_times(i); hours = floor(minutes/ 60); mins = floor(mod(minutes, 60)); time_string = sprintf('%02d:%02d',hours,mins); if normalize_emergency(i)== 1; case_level = '1 (Emergency)'; else case_level = '2 (Normalize)'; end printf('No. %-8d | %-16.2f | %-16s | %-10s\n', i, minutes, time_string, case_level); end printf('\n---------------------------------------------------------------------\n'); printf('Total %d patients displayed.\n\n', patients_id);


function [results, summary] = sim_patient_priority(patients)

    % Default test dataset (ID, Arrival, Priority)
    if nargin == 0
        patients = [
            1 0 1;
            2 2 2;
            3 4 1;
            4 6 2;
            5 7 1;
            6 9 2
        ];
    end

    n = size(patients, 1);
    
    % Inject random service times (Uniform distribution between 5 and 15)
    svc_times = 5 + rand(n, 1) * 10;
    patients = [patients(:, 1:2), svc_times, patients(:, 3)];
    
    % Sort by arrival time
    patients = sortrows(patients, 2);

    % Simulation state variables
    t_curr = 0;
    done_count = 0;
    idx = 1;
    
    queue = [];
    results = [];

    while done_count < n

        % Buffer newly arrived patients into the active queue
        while idx <= n && patients(idx, 2) <= t_curr
            queue = [queue; patients(idx, :)];
            idx = idx + 1;
        end

        % Handle idle processor time if queue is empty
        if isempty(queue)
            if idx <= n
                t_curr = patients(idx, 2);
            end
            continue;
        end

        % Sort queue by priority tier, then by arrival time
        queue = sortrows(queue, [4, 2]);

        % Pop next patient
        curr = queue(1, :);
        queue(1, :) = [];

        p_id    = curr(1);
        arrival = curr(2);
        service = curr(3);
        prio    = curr(4);

        % Calculate timeline metrics
        t_start  = max(t_curr, arrival);
        t_wait   = t_start - arrival;
        t_finish = t_start + service;
        t_system = t_finish - arrival;

        results = [results; p_id, arrival, service, prio, t_start, t_wait, t_finish, t_system];

        t_curr = t_finish;
        done_count = done_count + 1;
    end

    % Aggregate performance metrics
    summary = mean(results(:, [6, 3, 8]), 1);

    % Output reporting
    fprintf('\n--- Simulation Metrics ---\n');
    fprintf('Avg Waiting Time:   %.2f\n', summary(1));
    fprintf('Avg Service Time:   %.2f\n', summary(2));
    fprintf('Avg Time in System: %.2f\n', summary(3));
end
