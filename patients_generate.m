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
  printf('\n                    Wrtten by : TAN KHAI YU                          \n');
  printf('\n---------------------------------------------------------------------\n');
  printf('\n Total Patients arrived                 : %d\n',patients_id);
  printf('\n Total Patients for Emergency Case      : %d\n',sum (normalize_emergency == 1));
  printf('\n Total Patients for Normalize Case      : %d\n',sum (normalize_emergency == 2));
  printf('\n---------------------------------------------------------------------\n');
%------------------------------------------------------------------------------------------------
 % Set a interface design
 printf('\n---------------------------------------------------------------------\n');
 printf('\n                   Patients Detail Record Summary                    \n');
 printf('\n---------------------------------------------------------------------\n');
 printf('%-12s | %-16s | %-16s | %-10s\n', 'Patients ID','Time(minutes)','Clock','Case Level');
 printf('\n---------------------------------------------------------------------\n');

  % Set the time format and assign the case level
  for i = 1:patients_id;
    minutes = arrival_times(i);
    hours = floor(minutes/ 60);
    mins = floor(mod(minutes, 60));
    time_string = sprintf('%02d:%02d',hours,mins);

    if normalize_emergency(i)== 1;
       case_level = '1 (Emergency)';
    else
       case_level = '2 (Normalize)';
    end

    printf('No. %-8d | %-16.2f | %-16s | %-10s\n', i, minutes, time_string, case_level);
end
 printf('\n---------------------------------------------------------------------\n');
 printf('Total %d patients displayed.\n\n', patients_id);
