% Written by Tan Khai Yu
function patient_matrix = generate_patients()
  % =========================================================================
  % MODULE: Stochastic Patient Profile & Arrival Stream Generator
  % METHODOLOGY: Inverse Transform Sampling (Course Notes Ch. 4, Pg. 4 Protocol)
  % OUTPUT FORMAT: [Patient_ID, Arrival_Time, Triage_Priority]
  % =========================================================================

  % 1. Fixed Simulation Parameters
  total_time = 1440; % Total operational window: 24 hours scaled in minutes
  current_time = 0;  % Global simulation execution clock begins at 0
  patient_id = 0;    % Distinct structural tracker index for each profile

  % 2. Initialize Structural Storage Arrays
  arrival_times = [];
  priorities = [];

  % 3. Stochastic Generation Loop
  while current_time < total_time

      % Dynamic Arrival Rate Allocation to model peak day-flow shifts
      if current_time >= 480 && current_time <= 1080
          % Peak Demand Window: 08:00 to 18:00 (480 to 1080 minutes)
          lambda = 1 / 4; % Expected intensity rate: 0.25 patients per minute
      else
          % Non-Peak Demand Window: Night shift and early morning
          lambda = 1 / 12; % Expected intensity rate: 0.083 patients per minute
      end

      % --- INVERSE TRANSFORM METHODS ALGORITHM (Chapter 4, Page 4) ---
      % Mathematical Mapping: X_i = (-1 / lambda) * ln(1 - R_i)
      R_i = rand();
      inter_arrival = (-1 / lambda) * log(1 - R_i);
      % ---------------------------------------------------------------

      % Move global simulation timeline forward
      current_time = current_time + inter_arrival;

      % Log attributes if within the operational envelope boundary
      if current_time <= total_time
          patient_id = patient_id + 1;
          arrival_times(patient_id) = current_time;

          % Triage Prioritization (Critical to feed the Grade 4 Priority Queue)
          if rand() <= 0.30
              priorities(patient_id) = 1; % Profile Level 1: Critical Emergency
          else
              priorities(patient_id) = 2; % Profile Level 2: Standard Ambulatory
          end
      end
  end

  % 4. Construct Output Matrix Structure
  patient_matrix = [(1:patient_id)', arrival_times', priorities'];

  % 5. Operational Verification Summary Display
  fprintf('\n==============================================================\n');
  fprintf('       STOCHASTIC DATA PIPELINE GENERATION SUMMARY            \n');
  fprintf('       DEVELOPER CREDIT: TAN KHAI YU                          \n');
  fprintf('==============================================================\n');
  fprintf('Total Cumulative Patient Arrivals     : %d\n', patient_id);
  fprintf('Total Critical Profile Count (P1)     : %d\n', sum(priorities == 1));
  fprintf('Total Standard Profile Count (P2)     : %d\n', sum(priorities == 2));
  fprintf('==============================================================\n\n');

  % 6. FORMATTED VISUAL INTERFACE (Previews first 30 patients cleanly)
  fprintf('--------------------------------------------------------------\n');
  fprintf('       PATIENT MATRIX DATA STREAM (FIRST 30 PATIENTS PREVIEW) \n');
  fprintf('--------------------------------------------------------------\n');
  fprintf('%-12s | %-16s | %-16s | %-10s\n', 'Patient ID', 'Timeline (Min)', 'Wall Clock (Time)', 'Priority');
  fprintf('--------------------------------------------------------------\n');

  % Establish preview bounds to prevent console flooding
  preview_limit = min(30, patient_id);
  for i = 1:preview_limit
      % Mathematical conversion from simulation runtime minutes to 24-hr layout
      raw_minutes = arrival_times(i);
      hours = floor(raw_minutes / 60);
      mins = floor(mod(raw_minutes, 60));
      time_string = sprintf('%02d:%02d', hours, mins);

      % Translate raw numerical flags into descriptive reporting labels
      if priorities(i) == 1
          p_label = '1 (Critical)';
      else
          p_label = '2 (Standard)';
      end

      % Print row metrics with standardized tabular spacing
      fprintf('No. %-8d | %-16.2f | %-16s | %-10s\n', i, raw_minutes, time_string, p_label);
  end
  fprintf('--------------------------------------------------------------\n');
  fprintf('... and %d more rows safely stored in your data matrix variable.\n\n', patient_id - preview_limit);
end
