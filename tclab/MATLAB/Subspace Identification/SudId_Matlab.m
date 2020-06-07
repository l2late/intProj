%% Subspace Identification with MATLAB builtin functions
clear all; close all; clc;

% load test data
load ../results/luca/semi_random_test_60min_luca.mat


% Extract data columns
t = data(:,1);
Q1 = data(:,2);
Q2 = data(:,3);
T1meas = data(:,4);
T2meas = data(:,5);
T0      = ([T1meas(1) T2meas(1) T1meas(1) T2meas(1)]');

% Nominal temperature in K around which to linearize
Tnom = mean([T1meas(1),T2meas(1)]) + 273.15;

% Constuct data object for sys id
data = iddata([T1meas T2meas],[Q1 Q2],1);
% Extract and plot spectral density
% g = spafdr(data); 
% figure
% bode(g)

% filter output data to remove hi freq noise content
dataf = data;
filter=[0,0.5]; % filter band
dataf.OutputData = idfilt(data.OutputData,filter);

% detrend data
[datad,T] = detrend(dataf,0);

% identify system and print report
sys = ssest(datad,4);
sys.Report

% Simulate the model output with zero initial states
simOpt = simOptions('InitialCondition',T0);
y_sim = sim(sys,datad(:,[],:),simOpt);
y_tot = retrend(y_sim,T);

figure
compare(data,y_tot)

% Get the raw parameter covariance for the model.
% cov_data = getcov(sys);

[A,B,C,D,K] = idssdata(sys);
figure
iopzmap(sys)

%%

% nk = delayest(dataf)





% opt = n4sidOptions('N4Weight','MOESP','Display','on');
% sys = n4sid(data,2:8,opt);
% sys2 = ssest(data)

