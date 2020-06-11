% Requires Global Optimization Toolbox
% and Parallel Computing Toolbox

close all; clear all; clc

% generate data file from TCLab or get sample data file from:
% https://apmonitor.com/pdc/index.php/Main/ArduinoEstimation2
% Import data file
%load ../results/luca/semi_random_test.mat
load ../results/halithan/semi_random_test_Halithan.mat

% Extract data columns
t = data(:,1);
Q1 = data(:,2);
Q2 = data(:,3);
T1meas = data(:,4);
T2meas = data(:,5);

% Number of time points
ns = length(t);

% Parameter initial guess
U = 10.0;           % Heat transfer coefficient (W/m^2-K)
alpha1 = 0.0100;    % Heat gain 1 (W/%)
alpha2 = 0.0075;    % Heat gain 2 (W/%)
As = 2.0 / 100.0^2; % Area in m^2

p0 = [U,alpha1,alpha2,As];

% show initial objective
disp(['Initial SSE Objective: ' num2str(objective(p0,t,Q1,Q2,T1meas,T2meas))])

% optimize parameters

% no linear constraints
A = [];
b = [];
Aeq = [];
beq = [];
nlcon = [];

% optimize with fmincon
lb = [2, 0.005, 0.002, .1/100.0^2]; % lower bound
ub = [20, 0.02, 0.015,  4/100.0^2]; % upper bound

obj = @(x)objective(x,t,Q1,Q2,T1meas,T2meas);

% start pool of parallel workers
%parpool('local')
% Define MultiStart problem with parallel execution
ms = MultiStart('UseParallel',true);
opts = optimoptions(@fmincon,'Algorithm','interior-point','Display','iter');
problem = createOptimProblem('fmincon','objective',...
    obj,'x0',p0,'Aineq',A,'bineq',b,'Aeq',Aeq,'beq',beq,...
    'lb',lb,'ub',ub,'nonlcon',nlcon,'options',opts);
% run optimization with 50 random starts
[p,fval] = run(ms,problem,50);

% show final objective
disp(['Final SSE Objective: ' num2str(fval)])

% optimized parameter values
U = p(1);
alpha1 = p(2);
alpha2 = p(3);
As = p(4);
disp(['U: \t' num2str(U)])
disp(['alpha1: ' num2str(alpha1)])
disp(['alpha2: ' num2str(alpha2)])
disp(['As: ' num2str(As)])

% calculate model with updated parameters
Ti  = simulate(p0,t,Q1,Q2,T1meas,T2meas);
Tp  = simulate(p,t,Q1,Q2,T1meas,T2meas);

% Plot results
figure(1)

subplot(3,1,1)
plot(t/60.0,Ti(:,1),'y:','LineWidth',2)
hold on
plot(t/60.0,T1meas,'b-','LineWidth',2)
plot(t/60.0,Tp(:,1),'r--','LineWidth',2)
ylabel('Temperature (degC)')
legend('T_1 initial','T_1 measured','T_1 optimized')

subplot(3,1,2)
plot(t/60.0,Ti(:,2),'y:','LineWidth',2)
hold on
plot(t/60.0,T2meas,'b-','LineWidth',2)
plot(t/60.0,Tp(:,2),'r--','LineWidth',2)
ylabel('Temperature (degC)')
legend('T_2 initial','T_2 measured','T_2 optimized')

subplot(3,1,3)
plot(t/60.0,Q1,'g-','LineWidth',2)
hold on
plot(t/60.0,Q2,'k--','LineWidth',2)
ylabel('Heater Output')
legend('Q_1','Q_2')

xlabel('Time (min)')