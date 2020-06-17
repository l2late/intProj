clear all; close all; clc;


%focus = 'simulation';
focus = 'prediction';

% iterate for both casas: luca and halithan
for who = 1:2


% Get identification data
% [data, datap, datai, datar, datari, Tnom, T0, outputOffset] = get_id_data(who);

% with resample
[~, ~, ~, datap, datai, Tnom, T0, outputOffset] = get_id_data(who);
% no resample
%[~, datap, datai, ~, ~, Tnom, T0, outputOffset] = get_id_data(who);

% Get optimized parameters as initial guesses
if who == 1
    load ../model_parameters/model_parameters_luca;
elseif who == 2
    load ../model_parameters/model_parameters_halithan;
else
    disp('Error reading optimized parameters for 1 tau model')
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

% get optimized parameters from file
if who == 1
    load ../model_parameters/model_parameters_luca_2tau.mat;
elseif who == 2
    load ../model_parameters/model_parameters_halithan_2tau.mat;
else
    disp('Error reading optimized parameters for 2 tau model')
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
% blacksys.Report

% [A,B,C,D,K] = idssdata(blacksys);

%% Plot validation results and save images

% Get validation data
%[data, datap, datai, datar, datari, Tnom, T0, outputOffset] = get_val_data(who);

% With resample
[~, ~, ~, datap, datai, Tnom, T0, outputOffset] = get_val_data(who);
% Without resample
%[~, datap, datai, ~, ~, Tnom, T0, outputOffset] = get_val_data(who);

% Set path for plots
if who == 1
   plotPath = '../plots/luca/';
elseif who == 2
   plotPath = '../plots/halithan/';
else
    disp('plot path not right')
end

opt = compareOptions('InitialCondition','z','OutputOffset',outputOffset');

% Greybox model 1 tau
[y_grey1,gr_fit1,gr_x01] = compare(datai,greysys_1tau,opt);

figure
compare(datai,greysys_1tau,opt);
legend('Location','SE')
saveas(gca,[plotPath, 'comparison_prepross_greybox_1tau.png'])

figure
iopzmap(greysys_1tau)
saveas(gca,[plotPath, 'polezero_greybox_1tau.png'])

%  Plot residuals
opt=residOptions('InitialCondition','z','OutputOffset',outputOffset');
figure
resid(datai,greysys_1tau,opt)
saveas(gca,[plotPath, 'residuals_greybox_1tau.png'])

% compare bode plots
figure
bodemag(greysys_1tau,greysys_2tau,blacksys)
legend('Greybox Model 1','Greybox Model 2','Blackbox Model','Location','SW')
saveas(gca,[plotPath, 'bodemag_comparison.png'])



% Greybox model 2 tau
[y_grey2,gr_fit2,gr_x02] = compare(datai,greysys_2tau,opt);

figure
compare(datai,greysys_2tau,opt);
legend('Location','SE')
saveas(gca,[plotPath, 'comparison_prepross_greybox_2tau.png'])

figure
iopzmap(greysys_2tau)
saveas(gca,[plotPath, 'polezero_greybox_2tau.png'])

%  Plot residuals
opt=residOptions('InitialCondition','z','OutputOffset',outputOffset');
figure
resid(datai,greysys_2tau,opt)
saveas(gca,[plotPath, 'residuals_greybox_2tau.png'])

% Blackbox Model
figure
opt = compareOptions('InitialCondition','z','OutputOffset',outputOffset');
compare(datai,blacksys,opt);
legend('Location','SE')
saveas(gca,[plotPath, 'comparison_prepross_blackbox.png'])
[y_black,bl_fit,bl_x0] = compare(datai,blacksys,opt);

% Pole-Zero map
figure
iopzmap(blacksys)
saveas(gca,[plotPath, 'polezero_blackbox.png'])

%  Plot residuals
opt=residOptions('InitialCondition','z','OutputOffset',outputOffset');
figure
resid(datai,blacksys,opt)
saveas(gca,[plotPath, 'residuals_blackbox.png'])

%% Variance accounted for

% Greybox model 1 tau
vaf_grey1 = compute_vaf(datai.OutputData,y_grey1.OutputData);
% Greybox model 2 tau
vaf_grey2 = compute_vaf(datai.OutputData,y_grey2.OutputData);
% Blackbox model
vaf_black = compute_vaf(datai.OutputData,y_black.OutputData);

%% Save all model

% Set path for models
if who == 1
   modelPath = '../models/luca/';
elseif who == 2
   modelPath = '../models/halithan/';
else
    disp('plot path not right')
end

save([modelPath,'models'],'greysys_1tau','greysys_2tau','blacksys');
save([modelPath,'vaf'],'vaf_grey1','vaf_grey2','vaf_black');

%% Time domain comparison plots

t = datai.SamplingInstants;

figure
plot(t,datai.y(:,1)); hold on;
plot(t,y_grey1.y(:,1)+outputOffset(1)); hold on;
plot(t,y_grey2.y(:,1)+outputOffset(1)); hold on;
plot(t,y_black.y(:,1)+outputOffset(1));
ylabel('Temperature (deg C)')
legend('Measured','Greybox Model 1','Greybox Model 2','Blackbox Model','Location','SE')
title('Time Domain Reponses Temperature sensor 2')
saveas(gca,[plotPath,'timedomain_comparison_all_T1.png']);


figure
plot(t,datai.y(:,2)); hold on;
plot(t,y_grey1.y(:,2)+outputOffset(1)); hold on;
plot(t,y_grey2.y(:,2)+outputOffset(1)); hold on;
plot(t,y_black.y(:,2)+outputOffset(1));
ylabel('Temperature (deg C)')
legend('Measured','Greybox Model 1','Greybox Model 2','Blackbox Model','Location','SE');
title('Time Domain Reponses Temperature sensor 2')
saveas(gca,[plotPath,'timedomain_comparison_all_T2.png']);


end