%% Simulate State Space  
clear all; close all; clc;

% load test data
load ../old/results/luca/semi_random_test_60min_luca.mat
%load ../old/results/halithan/semi_random_test_60min_halithan.mat

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
TF=  tf(linsys);

figure("Name","stepfunction openloop")

%% check State Space

EV = eig(A); % all negative so stable
%MIMO system, so controllability matrix is not enough
Co = ctrb(linsys); %check controllability,  > full rank
Ob = obsv(linsys); %check observability,    > full rank

if rank(Ob) == length(C)
    fprintf("\n full rank obsv. matrix")
end
if rank(Co) == length(B')
    fprintf("\n full rank cont. matrix \n")
end 


TF_pole = pole(TF);
TF_zero = tzero(TF)

% To find the MIMO zeros we fill in different zeros for s (a in this case),
% If the rank drops, it is a MIMO zero
% #### do this later if wanted

%% run simulations for info

step(linsys)
bodemag(linsys)

%% H_infity



%% Performance and Robustness
%## add error and Later check NP,NS, RP, RS

