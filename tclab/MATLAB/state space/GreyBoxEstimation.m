clear all; close all; clc;

% load test data
load ../results/luca/semi_random_test_60min_luca.mat
load ../model_parameters/model_parameters_luca.mat

% Extract data columns
t = data(:,1);
Q1 = data(:,2);
Q2 = data(:,3);
T1meas = data(:,4);
T2meas = data(:,5);
T0 = ([T1meas(1) T2meas(1) T1meas(1) T2meas(1)]');
Ts = mean(diff(t));

% Nominal temperature in K around which to linearize
Tnom = mean([T1meas(1),T2meas(1)]) + 273.15;

% Constuct data object for sys id
data = iddata([T1meas T2meas],[Q1 Q2],Ts);

%% Preprocess output data to remove hi freq noise content and bias
datap=data;
filter=[0 0.4];
% datap.OutputData = detrend(datap.OutputData,0);
% datap.OutputData = idfilt(datap.OutputData,2,0.1,'low');
datap.OutputData = idfilt(datap.OutputData,filter,'FilterOrder',2);

%% Initialize greybox model

odefun = 'linearTclabModel';
fcn_type =  'c';
parameters = {'heatCoef1',U;'heatCoef2',Us;'alpha1',alpha1;....
    'alpha2',alpha2;'timeConstant',tau};
init_sys = idgrey(odefun,parameters,fcn_type,'InputName',{'Heater 1','Heater 2'},...
           'OutputName',{'Temp 1','Temp 2'});

%% Define parameter bounds

% U
init_sys.Structure.Parameters(1).Minimum = 1;
init_sys.Structure.Parameters(1).Maximum = 20;
% Us
init_sys.Structure.Parameters(2).Minimum = 5;
init_sys.Structure.Parameters(2).Maximum = 40;
% alpha1
init_sys.Structure.Parameters(3).Minimum = 0.001;
init_sys.Structure.Parameters(3).Maximum = 0.03;
% alpha2
init_sys.Structure.Parameters(4).Minimum = 0.001;
init_sys.Structure.Parameters(4).Maximum = 0.03;
% tau
init_sys.Structure.Parameters(5).Minimum = 3;
init_sys.Structure.Parameters(5).Maximum = 60;

%% Estimate Greybox model

opt = greyestOptions('SearchMethod','fmincon','InitialState','backcast');
greysys = greyest(datap,init_sys,opt);

%% Plot results and save images


figure
opt = compareOptions('InitialCondition',T0);
legend('Location','SE')
compare(data,greysys,opt);
saveas(gca,'../plots/comparison_greybox.png')

figure
opt = compareOptions('InitialCondition',T0);
legend('Location','SE')
compare(datap,greysys,opt);
saveas(gca,'../plots/comparison_prepross_greybox.png')

figure
iopzmap(greysys)
saveas(gca,'../plots/polezero_greybox.png')
figure
bodemag(greysys)
saveas(gca,'../plots/bodemag_greybox.png')

% t = 0:Ts:t(end);
% ygrey=lsim(greysys,[Q1 Q2],t,T0);
% 
% plot(data.OutputData);
% hold on;
% plot(t,ygrey)


%% Compare greybox model to optimized state space model

% Get state space system for linearized 2nd order physics model
linsys = stateSpaceModel(Tnom);

% Simulate state space responses
T_lin  = lsim(linsys,[Q1 Q2],t,T0);
T_grey = lsim(greysys,[Q1 Q2],t,T0);

measdata=datap.OutputData;
%measdata=[T1meas T2meas];


figure
subplot(2,1,1)
plot(t,measdata(:,1),t,T_lin(:,1),t,T_grey(:,1)); hold on;
ylabel('Temperature (degC)')
legend('T1 Measured','T1 optimized state space model','T1 greybox model','Location','SE')
subplot(2,1,2)
plot(t,measdata(:,2),t,T_lin(:,2),t,T_grey(:,2))
ylabel('Temperature (degC)')
legend('T2 Measured','T2 optimized state space model','T2 greybox model','Location','SE')
xlabel('Time (min)')
sgt = sgtitle('Comparison of optimized state space model and greybox model');
sgt.FontSize = 10;
saveas(gca,'../plots/comparison_greybox_statespace.png');

