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


TF_pole = pole(TF);
TF_zero = tzero(TF);


% figure("Name","stepfunction openloop")
% step(linsys)

% To find the MIMO zeros we fill in different zeros for s (a in this case),
% If the rank drops, it is a MIMO zero
% #### do this later if wanted
figure("Name","Margin off each system")
subplot(2,2,1)
margin(TF(1,1))
subplot(2,2,2)
margin(TF(2,1))
subplot(2,2,3)
margin(TF(1,2))
subplot(2,2,4)
margin(TF(2,2))


figure("Name","Nyquist")
nyquist(TF)
[DMI,MMI]=diskmargin(TF)

display(DMI(1))
display(DMI(2))
display(MMI)


%% Check robust stability

% opt = robOptions('Display','on','Sensitivity','on');
% [StabilityMargin,wcu] =robstab(linsys,opt)

%% H_infity

% get(linsys)
s = zpk('s'); % Laplace variable s
Gd = 8/s; % desired loop shape

% Compute the optimal loop shaping controller K
[K,CL,GAM] = loopsyn(linsys,Gd);

% Compute the loop L, sensitivity S and complementary sensitivity T:
L = linsys*K;
I = eye(size(L));
S = feedback(I,L); % S=inv(I+L);
T = I-S;

% Plot the results:
% step response plots
Timefinal= 1
step(T,Timefinal);title('\alpha and \theta command step responses');


%% Check robust stability

% opt = robOptions('Display','on','Sensitivity','on');
% [StabilityMargin,wcu] =robstab(CL,opt);
% 
% Gclw = usubs(Gcl, wcu);

%% frequency response plots

figure;
sigma(L,'r--',Gd,'k-.',Gd/GAM,'k:',Gd*GAM,'k:',{.1,100})
legend('\sigma(L) loopshape',...
	'\sigma(Gd) desired loop',...
	'\sigma(Gd) \pm GAM, dB');

figure;
sigma(T,I+L,'r--',{.1,100})
legend('\sigma(T) robustness','1/\sigma(S) performance')    

%% Performance and Robustness
%## add error and Later check NP,NS, RP, RS