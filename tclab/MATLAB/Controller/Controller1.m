%% Simulate State Space
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

A= linsys.A; B= linsys.B; C= linsys.C; D= linsys.D; %SS converting

%%
% p= [-1 -1.2 -1.3 -5]  ;   K = place(A,B,p); %pole placement
Co = ctrb(linsys); %check controllability,  > full rank
Ob = obsv(linsys); %check observability,    > full rank

