% Run multiple of tests

%% test 1
FileName='test3';

% simulation time
time = 0.1;             % time in min
loops = time*60;        % simulation time in seconds
Q1 = zeros(loops,1);
Q2 = zeros(loops,1);

% adjust heater levels
Q1(1:end,1) = 90;  % heater 1
Q2(2:end,1) = 80;  % heater 2

run_one_test(Q1,Q2,FileName)


%% test 2