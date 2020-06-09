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
TF=  tf(linsys);

figure("Name","stepfunction openloop")
step(linsys)

%% check State Space

EV = eig(A); % all negative so stable
%MIMO system, so controllability matrix is not enough
Co = ctrb(linsys); %check controllability,  > full rank
Ob = obsv(linsys); %check observability,    > full rank

if rank(Ob) == length(C)
    fprintf("\n full rank obsv. matrix")
end
if rank(Co) == length(B')
    fprintf("\n full rank cont. matrix")
end 


TF_pole = pole(TF);
TF_zero = tzero(TF);

% To find the MIMO zeros we fill in different zeros for s (a in this case),
% If the rank drops, it is a MIMO zero
% #### do this later if wanted

%% Pole placement
% close all
P = [-0.05 -0.05 -0.1 -0.2]  ; % desired closed loop EV
K = place(A,B,P); %Solve for K using pole placement

% check for closed loop EV
Acl = A-B*K;
Ecl = eig(Acl);

linsys_cl = ss(Acl, B, C, D)
figure("Name","stepfunction closedloop")
step(linsys_cl)

%Scale 
Kdc = dcgain (linsys_cl);
Kr = inv(Kdc);

%check scaled
linsys_cl_scaled = ss(Acl, B*Kr, C, D);
figure("Name","Scaled - stepfunction closedloop")
step(linsys_cl_scaled)


%% LQR
% R = diag(ones(length(A),1)) %autodiag
Q = [1 0 0 0;   %penalize x1 error
     0 1 0 0;   %penalize x2 error
     0 0 1 0;   %penalize x3 error
     0 0 0 1];  %penalize x4 error
R = [0.01   0;     %penalize actuator effort
     0      0.01];

 
[K_lqr,S,e] = lqr(linsys,Q,R) ;

% check for closed loop EV
A_lqr = A-B*K_lqr;
E_lqr = eig(A_lqr);
linsys_lqr = ss(A_lqr, B, C, D);

%plot
figure("Name","Scaled - LQR control")
step(linsys_lqr)

X0= [1; 0; 0; 0]; 
[Y,T,X] = initial (linsys_lqr, X0);

figure("Name","Response to Initial Condiiton");
p1 = plot( T, Y(:,1), 'LineWidth', 4);

figure("Name","Actuator Effor' - LQR control")
p2= plot( T, -K*X', 'LineWidth', 4);

figure("Name","Pole / Zero - LQR control")
pzmap(linsys_lqr)
%% H_infity



%% Performance and Robustness
%## add error and Later check NP,NS, RP, RS
