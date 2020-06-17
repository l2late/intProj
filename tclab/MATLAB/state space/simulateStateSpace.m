function simulate_StateSpace

% Simulate State Space
clear all; close all; clc;

% load test data
load ../results/luca/semi_random_test_60min_luca.mat
%load ../results/halithan/semi_random_test_60min_halithan.mat

% Extract data columns
t       = data(:,1);
Q1      = data(:,2);
Q2      = data(:,3);
T1meas  = data(:,4);
T2meas  = data(:,5);

% Nominal temperature in K around which to linearize
Tnom = mean([T1meas(1),T2meas(1)]) + 273.15;

% Get state space system for linearized 2nd order physics model
linsys = stateSpaceModel(Tnom);
% load subspace identified state space system
%load ../model_parameters/sid_parameters_luca.mat

% Initial state
%Tbar    = ones(4,1)*Tnom;
T0      = [T1meas(1) T2meas(1) T1meas(1) T2meas(1)]'; 

% Number of time points
ns = length(t);

% Simulate state space responses
Tp_lin  = lsim(linsys,[Q1 Q2],t,T0);
%Tp_sid  = lsim(sidsys,[Q1 Q2],t,T0);

% Plot results
figure('Position', [10, 10, 750, 400])
subplot(3,1,1)
plot(t/60.0,T1meas,'b-','LineWidth',2)
hold on
plot(t/60.0,Tp_lin(:,1),'r--','LineWidth',2)
%plot(t/60.0,Tp_sid(:,1),'b:','LineWidth',2)
ylabel('Temperature (degC)')
legend('T_1 measured','T_1 optimized','Location','NEO')

subplot(3,1,2)
plot(t/60.0,T2meas,'b-','LineWidth',2)
hold on
plot(t/60.0,Tp_lin(:,2),'r--','LineWidth',2)
%plot(t/60.0,Tp_sid(:,2),'b:','LineWidth',2)
ylabel('Temperature (degC)')
legend('T_2 measured','T_2 optimized','Location','NEO')

subplot(3,1,3)
plot(t/60.0,Q1,'g-','LineWidth',2)
hold on
plot(t/60.0,Q2,'k--','LineWidth',2)
ylabel('Heater Output')
legend('Q_1','Q_2','Location','NEO')
xlabel('Time (min)')
sgt = sgtitle('State Space Model Simulation');
sgt.FontSize = 20;