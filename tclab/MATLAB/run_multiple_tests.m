% Run multiple of tests
cool_temp = 25;

tclab

%% test 1

% wait for setup to cooldown
while (T1C() || T2C()) > cool_temp
    fprintf('Waiting for setup to cool down');
    fprintf('Current temp:\t%4.2f\t%4.2f\n',T1C(),T2C());
    pause(10)
end

FileName='only_heater1_80';

% simulation time
time = 1;               % time in min
loops = time*60;        % simulation time in seconds
Q1 = zeros(loops,1);    
Q2 = zeros(loops,1);    

% adjust heater levels
Q1(1:end,1) = 80;  % heater 1

run_one_test(a,Q1,Q2,FileName)

%% test 2

% wait for setup to cooldown
while (T1C() || T2C()) > cool_temp
    fprintf('Waiting for setup to cool down');
    fprintf('Current temp:\t%4.2f\t%4.2f\n',T1C(),T2C());
    pause(10)
end

FileName='only_heater2_80';

% simulation time
time = 1;             % time in min
loops = time*60;        % simulation time in seconds
Q1 = zeros(loops,1);
Q2 = zeros(loops,1);

% adjust heater levels
Q2(1:end,1) = 80;  % heater 2

run_one_test(Q1,Q2,FileName)


%% test 3

% wait for setup to cooldown
while (T1C() || T2C()) > cool_temp
    fprintf('Waiting for setup to cool down');
    fprintf('Current temp:\t%4.2f\t%4.2f\n',T1C(),T2C());
    pause(10)
end

FileName='both_heaters_80';

% simulation time
time = 1;             % time in min
loops = time*60;        % simulation time in seconds
Q1 = zeros(loops,1);
Q2 = zeros(loops,1);

% adjust heater levels
Q1(1:end,1) = 80;  % heater 1
Q2(1:end,1) = 80;  % heater 2

run_one_test(Q1,Q2,FileName)