% Simulate State Space
clear all; close all; clc;

% load test data
load ../results/luca/semi_random_test_60min_luca.mat

% Extract data columns
t       = data(:,1);
Q1      = data(:,2);
Q2      = data(:,3);
T1meas  = data(:,4);
T2meas  = data(:,5);

% Nominal temperature in K around which to linearize
Tnom = mean([T1meas(1),T2meas(1)]) + 273.15;

% Get state space system
sys = stateSpaceModel(Tnom);

% Initial state
%Tbar    = ones(4,1)*Tnom;
T0      = ([T1meas(1) T2meas(1) T1meas(1) T2meas(1)]'); 

% Number of time points
ns = length(t);

% simulate state space response
Tp  = lsim(sys,[Q1 Q2],t,T0);

% Plot results
figure(1)
subplot(3,1,1)
plot(t/60.0,T1meas,'b-','LineWidth',2)
hold on
plot(t/60.0,Tp(:,1),'r--','LineWidth',2)
ylabel('Temperature (degC)')
legend('T_1 measured','T_1 optimized')

subplot(3,1,2)
plot(t/60.0,T2meas,'b-','LineWidth',2)
hold on
plot(t/60.0,Tp(:,2),'r--','LineWidth',2)
ylabel('Temperature (degC)')
legend('T_2 measured','T_2 optimized')

subplot(3,1,3)
plot(t/60.0,Q1,'g-','LineWidth',2)
hold on
plot(t/60.0,Q2,'k--','LineWidth',2)
ylabel('Heater Output')
legend('Q_1','Q_2')
xlabel('Time (min)')
sgt = sgtitle('State Space Model Simulation');
sgt.FontSize = 20;