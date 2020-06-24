%% Simulate State Space
clear all; close all; clc;

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

% Get state space system for linearized 2nd order physics model
linsys = stateSpaceModel(Tnom);

A= linsys.A; B= linsys.B; C= linsys.C; D= linsys.D; %SS converting
TF=  tf(linsys);



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

TF_pole = pole(TF)
TF_zero = tzero(TF)

%% Openloop plot

% figure("Name","stepfunction openloop")
% step(linsys)


%% Pole placement
% close all
P = [-0.005 -0.005 -0.01 -0.02]  ; % desired closed loop EV
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
R = [0.01   0;     %penalize input/actuator effort
     0      0.01];


[K_lqr,S,e] = lqr(linsys,Q,R) ;



% check for closed loop EV
A_lqr = A-B*K_lqr;
E_lqr = eig(A_lqr);
linsys_lqr = ss(A_lqr, B, C, D);

%plot
figure("Name","LQR")
subplot(2,2,1)
title("LQR control")
step(linsys_lqr)


X0= [1; 0; 0.5 ; 0.2]; 
[Y,T,X] = initial (linsys_lqr, X0);
subplot(2,2,2)
p1 = plot( T, Y(:,1), 'LineWidth', 1);
title("Step Response Initial Condiiton");

subplot(2,2,3)
p2= plot( T, -K_lqr*X', 'LineWidth', 1);
title("Actuator Effort - LQR control")

subplot(2,2,4)
pzmap(linsys_lqr)
title("Pole-Zero Map - LQR")

%% Check robust stability

% opt = robOptions('Display','on','Sensitivity','on');
% [StabilityMargin,wcu] =robstab(linsys_lqr,opt);


