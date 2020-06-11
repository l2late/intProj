% Requires Global Optimization Toolbox
% and Parallel Computing Toolbox

close all; clear all; clc

n_multistart = 20;

% generate data file from TCLab or get sample data file from:
% https://apmonitor.com/pdc/index.php/Main/ArduinoEstimation2
% Import data file
%load ../data/luca/prbs_test_60min.mat
%load ../data/halithan/prbs_test_60min.mat

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
Us = 20.0;          % Heat transfer coefficent
tau1 = 10.0;         % Heat conduction time constant for heater 1
tau2 = 10.0;         % Heat conduction time constant for heater 2


% Initial guess vector
p0 = [U,alpha1,alpha2,Us,tau1,tau2];

% Upper and lower bounds of p
lb = [1,  0.001, 0.001, 5,  3, 3]; % lower bound
ub = [20, 0.03,  0.03,  40, 60, 60]; % upper bound

% Show initial objective
disp(['Initial SSE Objective: ' num2str(objective(p0,t,Q1,Q2,T1meas,T2meas))])

% No linear constraints
A = [];
b = [];
Aeq = [];
beq = [];
nlcon = [];

% create anonymous function for optimoptions
obj = @(x)objective(x,t,Q1,Q2,T1meas,T2meas);

% start pool of parallel workers
parpool('local')
% Define MultiStart problem with parallel execution
ms = MultiStart('UseParallel',true);     
opts = optimoptions(@fmincon,'Algorithm','interior-point','Display','iter');
problem = createOptimProblem('fmincon','objective',...
    obj,'x0',p0,'Aineq',A,'bineq',b,'Aeq',Aeq,'beq',beq,...
    'lb',lb,'ub',ub,'nonlcon',nlcon,'options',opts);

% Run optimization with random starts
[p,fval] = run(ms,problem,n_multistart);

% Show final objective
disp(['Final SSE Objective: ' num2str(fval)])

% Optimized parameter values
U = p(1);
alpha1 = p(2);
alpha2 = p(3);
Us = p(4);
tau1 = p(5);
tau2 = p(6);

fprintf('U:\t%4.2f\n',U)
fprintf('alpha1:\t%4.4f\n',alpha1)
fprintf('alpha2:\t%4.4f\n',alpha2)
fprintf('Us:\t%4.2f\n',Us)
fprintf('tau1:\t%4.2f\n',tau1)
fprintf('tau2:\t%4.2f\n',tau2)

% Calculate model with updated parameters
Ti  = simulate(p0,t,Q1,Q2,T1meas(1),T2meas(1));
Tp  = simulate(p,t,Q1,Q2,T1meas(1),T2meas(1));

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

% save optimized parameters
FileName = '../model_parameters/model_parameters_luca_2tau';
%FileName = '../model_parameters/model_parameters_halithan_2tau';
save(FileName,'U','Us','alpha1','alpha2','tau1','tau2');
