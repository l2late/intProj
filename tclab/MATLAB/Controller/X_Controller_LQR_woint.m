%% Simulink File
%first step run simulink

clear all; close all; clc;


%% Load old models

%cd ('C:\Users\halit\Desktop\Universiteit\Q4\Integration Project SC\TCLab Files\intProj\tclab\MATLAB\Controller')
% load ../data/luca/prbs_test_60min.mat         % old model
%  load ../data/halithan/prbs_test_60min.mat     % old model

%load ../final_models/halithan/models.mat        % new models halithan
% load ../final_models/luca/models.mat            % new models luca

% data=prbs_test_60min{1};
% % Extract data columns
% t       = data(:,1);
% Q1      = data(:,2);
% Q2      = data(:,3);
% T1meas  = data(:,4);
% T2meas  = data(:,5);
% 
% % Nominal temperature in K around which to linearize
% Tnom = mean([T1meas(1),T2meas(1)]) + 273.15;
% Tnom_celsius = mean([T1meas(1),T2meas(1)]);
% 
% % Get state space system for linearized 2nd order physics model
% linsys = stateSpaceModel(Tnom);
% 
% A= linsys.A; B= linsys.B; C= linsys.C; D= linsys.D; %SS converting
% TF=  tf(linsys);

%% Load Blackbox
cd ('C:\Users\halit\Desktop\Universiteit\Q4\Integration Project SC\TCLab Files\intProj\tclab\MATLAB\Controller')

% load test data 
load state_space_matrices.mat

%% LQR control & Kalman filter
close all
% L = place(A', C', eig(A)*4)';
% L = sys.K;

% LQR
nil = 1e-5;
Q_x1 = 1E2;
Q_x2 = 1E2; %https://www.youtube.com/watch?v=wEevt2a4SKI&feature=youtu.be
Q_x3 = 1E2; %Q is bigger than R means fast regulation
Q_x4 = 1E2;

r11= 0.00005;
r22= 0.00005;
N=0; % N matrix could be added but we do see no reason to penalize the
%cross product between x and u

Q = diag([Q_x1 Q_x2 Q_x3 Q_x4 ]);
R = diag([r11 r22]);
N = 0; 

[K,S,e] = lqr(A, B, Q, R, N);

% Kalman  Filter
% Augmente system with disturbances and noise
Vd = .0001*eye(4);  %disturbance covariance
Vn = 0.0001*eye(2);        % noise covariance

%build kalman  filter
[L,P,E] = lqe(A,Vd, C,Vd,Vn); % Design Kalman filter
Kf= (lqr(A',C',Vd,Vn))'; % or using LQR
sysKF =  ss(A-Kf*C, [B Kf], eye(4), 0*[B Kf]);





%% Go back to simulink Folder
cd ('C:\Users\halit\Desktop\Universiteit\Q4\Integration Project SC\TCLab Files\intProj\tclab\MATLAB\Controller\Simulink\Dual_Heater')


% YOU CAN NOW RUN THE SIMULINK 



%% check lqr
figure1=figure('Position', [500, 50, 1020, 600]);
A_lqr1 = A_-B_*K_;
linsys_lqr1 = ss(A_lqr1, B_, C_, D);
A_lqr2 = A-B*K;
linsys_lqr2 = ss(A_lqr2, B, C, D);
[K3,S,e] = lqr(A, B, Q2, R, 0);
A_lqr3 = A-B*K3;
linsys_lqr3 = ss(A_lqr3, B, C, D);
subplot(1,3,1)
step(linsys_lqr1)
subplot(1,3,2)
step(linsys_lqr2)
subplot(1,3,3)
step(linsys_lqr3)

%% Check cd ('C:\Users\halit\Desktop\Universiteit\Q4\Integration Project SC\TCLab Files\intProj\tclab\MATLAB\Controller')
% 
% check for closed loop EV
% linsys = ss(A,B,C,D)
% Q2= diag([Q_1 Q_2 Q_3 Q_4]);
% [K_lqr2,S2,e2] = lqr(linsys,Q2,R) ;
% 
% 
% A_lqr2 = A-B*K_lqr2;
% E_lqr2 = eig(A_lqr2);
% linsys_lqr = ss(A_lqr2, B, C, D);
% 
% plot
% figure("Name","LQR")
% subplot(2,2,1)
% title("LQR control")
% step(linsys_lqr)
% 
% 
% X0= [1; 0; 0.5 ; 0.2]; 
% [Y,T,X] = initial (linsys_lqr, X0);
% subplot(2,2,2)
% p1 = plot( T, Y(:,1), 'LineWidth', 1);
% title("Step Response Initial Condiiton");
% 
% subplot(2,2,3)
% p2= plot( T, -K_lqr2*X', 'LineWidth', 1);
% title("Actuator Effort - LQR control")
% 
% subplot(2,2,4)
% pzmap(linsys_lqr)
% title("Pole-Zero Map - LQR")
% 
% 
