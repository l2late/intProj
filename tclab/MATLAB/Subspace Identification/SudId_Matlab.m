%% Subspace Identification with MATLAB builtin functions
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
filter=[0,0.5]; % filter band
%datap.OutputData = detrend(datap.OutputData,0);
datap.OutputData = idfilt(datap.OutputData,filter);
plot(datap.OutputData)

% detrend data
% [datad,T] = detrend(data,0);

% identify system and print report
opt = ssestOptions('InitializeMethod','n4sid','InitialState',T0);
blacksys = ssest(datap,4);
blacksys.Report

[A,B,C,D,K] = idssdata(blacksys)

% Simulate the model output with zero initial states
% simOpt = simOptions('InitialCondition',T0);
% y_sim = lsim(sys,datap.InputData,simOpt);
figure
opt = compareOptions('InitialCondition',T0);
compare(datap,blacksys,opt);
legend('Location','SE')
saveas(gca,'../plots/comparison_prepross_blackbox.png')

% Get the raw parameter covariance for the model.
% cov_data = getcov(sys);

figure
iopzmap(blacksys)
saveas(gca,'../plots/polezero_blackbox.png')


opt=residOptions('MaxLag',30);
figure
resid(datap,blacksys,opt)
saveas(gca,'../plots/residuals_blackbox.png')
