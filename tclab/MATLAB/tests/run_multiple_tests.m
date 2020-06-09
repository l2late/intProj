clear all;  close all; clc

% save files in right folders
if isunix
    FileName1='../data/luca/prbs_test_60min';
    FileName2='../data/luca/prbs_test_60min_val';
elseif ispc
    FileName1='../data/halithan/prbs_test_60min';
    FileName2='../data/halithan/prbs_test_60min_val'; 
else
    disp('Platform not supported')
end

% temperature to which the test setup must cool down before continuing with
% the next test
cool_temp = 28;

% include tclab for connection to arduino
tclab

%% PRBS Test

% wait for setup to cooldown
cool_down_check(a,cool_temp);

% get heater settings from file
load ../data/inputs/prbs_heater_input_60min.mat

Q1 = Q(:,1);
Q2 = Q(:,2);

run_one_test(a,Q1,Q2,FileName1)

%% PRBS Test for validation data

% wait for setup to cooldown
cool_down_check(a,cool_temp);

% get heater settings from file
load ../data/inputs/prbs_heater_input_60min_val.mat

Q1 = Q(:,1);
Q2 = Q(:,2);

run_one_test(a,Q1,Q2,FileName2)

% %% Test 1: Only heater 1 set to 80%
% 
% % wait for setup to cooldown
% cool_down_check(a,cool_temp);
% 
% FileName='only_heater1_80';
% 
% time = 10;              % simulation time in min
% loops = time*60;        % simulation time in seconds
% Q1 = zeros(loops,1);    
% Q2 = zeros(loops,1);    
% 
% % adjust heater levels
% Q1(1:end,1) = 80;  % heater 1
% 
% run_one_test(a,Q1,Q2,FileName)
% 
% %% Test 2: Only heater 2 set to 80%
% 
% % wait for setup to cooldown
% cool_down_check(a,cool_temp);
% 
% FileName='only_heater2_80';
% 
% time = 10;               % simulation time in min% time in min
% loops = time*60;        % simulation time in seconds
% Q1 = zeros(loops,1);
% Q2 = zeros(loops,1);
% 
% % adjust heater levels
% Q2(1:end,1) = 80;  % heater 2
% 
% run_one_test(a,Q1,Q2,FileName)
% 
% %% Test 3: Both heaters set to 80%
% 
% % wait for setup to cooldown
% cool_down_check(a,cool_temp);
% 
% FileName='both_heaters_80';
% 
% time = 10;               % simulation time in min
% loops = time*60;        % simulation time in seconds
% Q1 = zeros(loops,1);
% Q2 = zeros(loops,1);
% 
% % adjust heater levels
% Q1(1:end,1) = 80;  % heater 1
% Q2(1:end,1) = 80;  % heater 2
% 
% run_one_test(a,Q1,Q2,FileName)