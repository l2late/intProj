%% Simulink File

clear all; close all; clc;


%% first step run simulink

cd ('C:\Users\halit\Desktop\Universiteit\Q4\Integration Project SC\TCLab Files\intProj\tclab\MATLAB\Controller')

% load test data
% load ../data/luca/prbs_test_60min.mat
load ../data/halithan/prbs_test_60min.mat
%%
data=prbs_test_60min{1};
% Extract data columns
t       = data(:,1);
Q1      = data(:,2);
Q2      = data(:,3);
T1meas  = data(:,4);
T2meas  = data(:,5);

% Nominal temperature in K around which to linearize
Tnom = mean([T1meas(1),T2meas(1)]) + 273.15;
Tnom_celsius = mean([T1meas(1),T2meas(1)]);

% Get state space system for linearized 2nd order physics model
linsys = stateSpaceModel(Tnom);

A= linsys.A; B= linsys.B; C= linsys.C; D= linsys.D; %SS converting
TF=  tf(linsys);


%% Go back to simulink Folder
cd ('C:\Users\halit\Desktop\Universiteit\Q4\Integration Project SC\TCLab Files\intProj\tclab\MATLAB\Controller\Simulink\Dual_Heater')


% YOU CAN NOW RUN THE SIMULINK 


