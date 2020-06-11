clear all; close all; clc;

focus = 'simulation';
% focus = 'prediction';

% Get identification data
% [data, datap, datai, datar, datari, Tnom, T0, outputOffset] = get_id_data;
[~, ~, ~, datap, datai, Tnom, T0, outputOffset] = get_id_data;

% Get optimized parameters as initial guesses
if isunix
    load ../model_parameters/model_parameters_luca.mat
elseif ispc
    load ../model_parameters/model_parameters_halithan.mat
else
    disp('Platform not supported')
end

%% Greybox models identification

% Initialize greybox model with 1 tau

odefun = 'linearTclabModel';
fcn_type =  'c';
parameters = {'heatCoef1',U;'heatCoef2',Us;'alpha1',alpha1;....
    'alpha2',alpha2;'timeConstant',tau;};
init_sys = idgrey(odefun,parameters,fcn_type,'InputName',{'Heater 1','Heater 2'},...
           'OutputName',{'Temp 1','Temp 2'});

% Define parameter bounds for greybox model
% U
init_sys.Structure.Parameters(1).Minimum = 1;
init_sys.Structure.Parameters(1).Maximum = 20;
% Us
init_sys.Structure.Parameters(2).Minimum = 5;
init_sys.Structure.Parameters(2).Maximum = 40;
% alpha1
init_sys.Structure.Parameters(3).Minimum = 0.001;
init_sys.Structure.Parameters(3).Maximum = 0.03;
% alpha2
init_sys.Structure.Parameters(4).Minimum = 0.001;
init_sys.Structure.Parameters(4).Maximum = 0.03;
% tau
init_sys.Structure.Parameters(5).Minimum = 3;
init_sys.Structure.Parameters(5).Maximum = 60;

% Estimate Greybox model with 1 tau

opt = greyestOptions('SearchMethod','fmincon','InitialState','zero',...
    'Focus',focus);
greysys_1tau = greyest(datap,init_sys,opt);

% clear old variables
clear U Us tau alpha1 alpha2

% Get optimized parameters as initial guesses
if isunix
    load ../model_parameters/model_parameters_luca_2tau.mat
elseif ispc
    load ../model_parameters/model_parameters_halithan_2tau.mat
else
    disp('Platform not supported')
end

% Initialize greybox model with 2 tau

odefun = 'linearTclabModel_2tau';
fcn_type =  'c';
parameters = {'heatCoef1',U;'heatCoef2',Us;'alpha1',alpha1;....
    'alpha2',alpha2;'timeConstant1',tau1;'timeConstant2',tau2};
init_sys = idgrey(odefun,parameters,fcn_type,'InputName',{'Heater 1','Heater 2'},...
           'OutputName',{'Temp 1','Temp 2'});

% Define parameter bounds for greybox model
% U
init_sys.Structure.Parameters(1).Minimum = 1;
init_sys.Structure.Parameters(1).Maximum = 20;
% Us
init_sys.Structure.Parameters(2).Minimum = 5;
init_sys.Structure.Parameters(2).Maximum = 40;
% alpha1
init_sys.Structure.Parameters(3).Minimum = 0.001;
init_sys.Structure.Parameters(3).Maximum = 0.03;
% alpha2
init_sys.Structure.Parameters(4).Minimum = 0.001;
init_sys.Structure.Parameters(4).Maximum = 0.03;
% tau1
init_sys.Structure.Parameters(5).Minimum = 3;
init_sys.Structure.Parameters(5).Maximum = 60;
% tau2
init_sys.Structure.Parameters(6).Minimum = 3;
init_sys.Structure.Parameters(6).Maximum = 60;

% Estimate Greybox model with 2 tau

opt = greyestOptions('SearchMethod','fmincon','InitialState','zero',...
    'Focus',focus);
greysys_2tau = greyest(datap,init_sys,opt);

%% Blackbox model estimation

% Identify system and print report
opt = ssestOptions('InitializeMethod','n4sid','InitialState','zero',...
    'EnforceStability',true,'Focus',focus);
blacksys = ssest(datap,4,opt);
blacksys.Report

[A,B,C,D,K] = idssdata(blacksys);

%% Plot validation results and save images

% Get validation data
[~, ~, ~, datap, datai, Tnom, T0, outputOffset] = get_val_data;

opt = compareOptions('InitialCondition','z','OutputOffset',outputOffset');

% Greybox model 1 tau
% figure
% compare(data,greysys_1tau,opt);
% legend('Location','SE')
% saveas(gca,'../plots/comparison_greybox_1tau.png')
[y_grey1,gr_fit1,gr_x01] = compare(datai,greysys_1tau,opt);

figure
compare(datai,greysys_1tau,opt);
legend('Location','SE')
saveas(gca,'../plots/comparison_prepross_greybox_1tau.png')

figure
iopzmap(greysys_1tau)
saveas(gca,'../plots/polezero_greybox_1tau.png')

figure
bodemag(greysys_1tau)
saveas(gca,'../plots/bodemag_greybox_1tau.png')

% Greybox model 2 tau
% figure
% compare(data,greysys_2tau,opt);
% legend('Location','SE')
% saveas(gca,'../plots/comparison_greybox_2tau.png')
[y_grey2,gr_fit2,gr_x02] = compare(datai,greysys_2tau,opt);

figure
compare(datai,greysys_2tau,opt);
legend('Location','SE')
saveas(gca,'../plots/comparison_prepross_greybox_2tau.png')

figure
iopzmap(greysys_2tau)
saveas(gca,'../plots/polezero_greybox_2tau.png')

figure
bodemag(greysys_2tau)
saveas(gca,'../plots/bodemag_greybox_2tau.png')


% Blackbox Model
figure
opt = compareOptions('InitialCondition','z','OutputOffset',outputOffset');
compare(datai,blacksys,opt);
legend('Location','SE')
saveas(gca,'../plots/comparison_prepross_blackbox.png')
[y_black,bl_fit,bl_x0] = compare(datai,blacksys,opt);

% Pole-Zero map
figure
iopzmap(blacksys)
saveas(gca,'../plots/polezero_blackbox.png')

%  Plot residuals
opt=residOptions('MaxLag',30);
figure
resid(datap,blacksys,opt)
saveas(gca,'../plots/residuals_blackbox.png')

%% Variance accounted for

% Greybox model 1 tau
vaf_grey1 = compute_vaf(datai.OutputData,y_grey1.OutputData);

% Greybox model 2 tau
vaf_grey2 = compute_vaf(datai.OutputData,y_grey2.OutputData);

% Blackbox model
vaf_black = compute_vaf(datai.OutputData,y_black.OutputData);


%% Comparison plots

% figure
% subplot(2,1,1)
% plot(t,measdata(:,1),t,T_lin(:,1),t,T_grey(:,1)); hold on;
% ylabel('Temperature (degC)')
% legend('T1 Measured','T1 optimized state space model','T1 greybox model','Location','SE')
% subplot(2,1,2)
% plot(t,measdata(:,2),t,T_lin(:,2),t,T_grey(:,2))
% ylabel('Temperature (degC)')
% legend('T2 Measured','T2 optimized state space model','T2 greybox model','Location','SE')
% xlabel('Time (min)')
% sgt = sgtitle('Comparison of optimized state space model and greybox model');
% sgt.FontSize = 10;
% saveas(gca,'../plots/comparison_greybox_statespace.png');

% t = 0:Ts:t(end);
% ygrey=lsim(greysys,[Q1 Q2],t,T0);
% 
% plot(data.OutputData);
% hold on;
% plot(t,ygrey)


% %% Compare greybox model to optimized state space model
% 
% % Get state space system for linearized 2nd order physics model
% linsys = stateSpaceModel(Tnom);
% 
% % Simulate state space responses
% T_lin  = lsim(linsys,[Q1 Q2],t,T0);
% T_grey = lsim(greysys,[Q1 Q2],t,T0);
% 
% measdata=datap.OutputData;
% %measdata=[T1meas T2meas];
% 
% 
% figure
% subplot(2,1,1)
% plot(t,measdata(:,1),t,T_lin(:,1),t,T_grey(:,1)); hold on;
% ylabel('Temperature (degC)')
% legend('T1 Measured','T1 optimized state space model','T1 greybox model','Location','SE')
% subplot(2,1,2)
% plot(t,measdata(:,2),t,T_lin(:,2),t,T_grey(:,2))
% ylabel('Temperature (degC)')
% legend('T2 Measured','T2 optimized state space model','T2 greybox model','Location','SE')
% xlabel('Time (min)')
% sgt = sgtitle('Comparison of optimized state space model and greybox model');
% sgt.FontSize = 10;
% saveas(gca,'../plots/comparison_greybox_statespace.png');

