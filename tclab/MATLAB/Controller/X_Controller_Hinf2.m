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
% load state_space_matrices.mat
load bb_mat_new.mat


%% LQR control & Kalman filter
close all
nx = 4; % number of state
nu = 2; %number of input
ny = 2; % number of output

beta = ureal('k', 1, 'Range',[-0.1 1]);
k = ureal('k', 1, 'Range',[-2 2]); % uncertain parameter
alpha = ureal('alpha', 1, 'Range', [-1E-5 1E-5]);
Ap = A +A*k


Bp = B + B*k
Cp = C + [eye(2) eye(2)]*k;
Gp = ss(A,Bp,Cp,0);
bodemag(Gp)

H = ss(A,B,C,D);
G= tf(H);

%% choosing weights
cd ('C:\Users\halit\Desktop\Universiteit\Q4\Integration Project SC\TCLab Files\intProj\tclab\MATLAB\Controller\Simulink\Dual_Heater')

close all
%tuning Parameters
s=tf('s');

wB = 0.1;         % desired closed-loop bandwidth
At_11 = 1E9;       % desired distrubance attenuation inside bandwith
M_11  = 20;         % desired bound on hinfnorm(S)

Wp_11 = (s/M_11+wB)/(s+wB*At_11);      % Tunable/variable weight weight
Wp_22 = (s/M_11+wB)/(s+wB*At_11);      % Tunable/variable weight weight 
Ws = [Wp_11 0;0 Wp_22];                % Sensivity weight -> Wp*S 0.2
Wu = eye(2); %Control weight -> Wu*K*S 
Wt = []; %Empty weight

% [A1, B1, C1, D1] = linmod('hinfinity');
% 
% P = ss(A1, B1, C1, D1);
% 
% [Kinf,CL, GAM] = hinfsyn(P,2,2)

[Kinf,CL,GAM,INFO] = mixsyn(G,Ws,Wu,Wt);
step(feedback(G*Kinf, eye(2)));
% bode(feedback(G*Kinf, eye(2)));
%% Go back to simulink Folder
L = G*Kinf;
I = eye(size(L));
S = feedback(L,eye(2)); % S=inv(I+L);
T = I-S;

S_Ta_large= svds(T.a)
S_Sa_large= svds(S.a)
S_Ta_small = svds(T.a,6,'smallest')
S_Sa_small = svds(S.a,6,'smallest')
% 
% S=  inv(1+G*Kinf)
% T = S*G*Kinf
% YOU CAN NOW RUN THE SIMULINK 





%% check lqr
% figure1=figure('Position', [500, 50, 1020, 600]);
% A_lqr1 = A_-B_*K_;
% linsys_lqr1 = ss(A_lqr1, B_, C_, D);
% A_lqr2 = A-B*K;
% linsys_lqr2 = ss(A_lqr2, B, C, D);
% [K3,S,e] = lqr(A, B, Q2, R, 0);
% A_lqr3 = A-B*K3;
% linsys_lqr3 = ss(A_lqr3, B, C, D);
% subplot(1,3,1)
% step(linsys_lqr1)
% subplot(1,3,2)
% step(linsys_lqr2)
% subplot(1,3,3)
% step(linsys_lqr3)

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
%% time sequence

time = 1400;              % stoppingtime in sec
H1 = zeros(1,time);    
T_setpoint2 = zeros(1,time+1);   

T_ambient = 30;

set_T1 =        [T_ambient      40            55                  45          T_ambient];
set_T1_time =   1.2*floor([1        time*0.1       time*0.4           time*0.7    time*0.9]);

% adjust level for heater 1
if size(set_T1) == size(set_T1_time)
    for ii = 1:length(set_T1)
    T_setpoint1(1,set_T1_time(ii):time+1)=set_T1(ii);
    end
end
    
% set heating values for heater 2
% column 1 and 2: interval begin and end as fraction of total time
% column 3: heater setting for the corresponding interval
set_T2 =        [T_ambient          50            40            55          T_ambient];
set_T2_time =   1.2*floor([1          time*0.2      time*0.5      time*0.7    time*0.9]);

% adjust level for heater 2
if size(set_T2) == size(set_T2_time)
    for ii = 1:length(set_T2)
        T_setpoint2(1,set_T2_time(ii):time+1)=set_T2(ii);
    end
end

T_setpoint= [T_setpoint1;T_setpoint2]'


