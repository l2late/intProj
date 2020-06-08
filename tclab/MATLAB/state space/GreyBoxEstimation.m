odefun = 'LinearTclabModel';
fcn_type = 'c';
parameters = {'heatCoef1',U,'heatCoef2',Us,'alpha1',a1,'alpha2',a2,...
    'timeConstant',tau,'nominalTemp',Tnom};

sys = idgrey(odefun,parameters,fcn_type);

% Parameter bounds
% U
sys.stucture.parameters(1).Minimum = 1;
sys.stucture.parameters(1).Maximum = 20;
% Us
sys.stucture.parameters(2).Minimum = 5;
sys.stucture.parameters(2).Maximum = 40;
% alpha1
sys.stucture.parameters(3).Minimum = 0.001;
sys.stucture.parameters(3).Maximum = 0.03;
% alpha2
sys.stucture.parameters(4).Minimum = 0.001;
sys.stucture.parameters(4).Maximum = 0.03;
% tau
sys.stucture.parameters(5).Minimum = 5;
sys.stucture.parameters(5).Maximum = 60;
% set Tnom as fixed variable
sys.stucture.parameters(6).Free = False;

