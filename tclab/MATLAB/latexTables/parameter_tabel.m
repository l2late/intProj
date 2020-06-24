% make table with optimized parameters
clear all
modelNames = {'State Space 1','State Space 2','Greybox 1','Greybox 2'};

fileName = '../model_parameters/model_parameters_halithan'
load(fileName);
ss1 = [U; Us; alpha1; alpha2;tau; 0];

fileName = '../model_parameters/model_parameters_halithan_2tau'
load(fileName);
ss2 = [U; Us; alpha1; alpha2; tau1; tau2];

% U, Us, alpha1, alpha2,tau1, tau2
grey1 = [11.1272841143270;40;0.0124296949077508;0.0124779239850210;42.9413220650805;0];
grey2 = [11.1722899535390;40;0.0124073148705526;0.0125692652440572;40.2421780470559;45.2359181189284];
varNames = {'Model';'$U$';'$U_s$';'$\alpha_1$';'$\alpha_2$';...
    '$\tau_1$';'$\tau_2$'};


tabmat = [round(ss1,4)';...
    round(ss2,4)';...
    round(grey1,4)';...
    round(grey2,4)']

T = table(modelNames',tabmat(:,1),tabmat(:,2),tabmat(:,3),tabmat(:,4),tabmat(:,5),tabmat(:,6))
T.Properties.VariableNames = varNames

latexTablePath = ['parameter_table.tex'];
table2latex(T,latexTablePath);      
