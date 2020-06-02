function sys = stateSpaceModel(Tnom)
% Returns a state space model for the 2nd order physics model
 
% get optimized parameters from file
load ../model_parameters/model_parameters_luca;
%load ../model_parameters/model_parameters_halithan;

% General Model Parameters
m       = 4.0/1000.0;       % kg
Cp      = 0.5 * 1000.0;     % J/kg-K    
A       = 10.0 / 100.0^2;   % Area in m^2
As      = 2.0 / 100.0^2;    % Area in m^2
eps     = 0.9;              % Emissivity
sigma   = 5.67e-8;          % Stefan-Boltzman

% set coefficient of state space matrices
a11 = -(1/(m*Cp))*(U*A + 4*eps*sigma*A*Tnom^3 + Us*As + 4*eps*sigma*As*Tnom^3);
a12 = -(1/(m*Cp))*(Us*As + 4*eps*sigma*As*Tnom^3);
a13 = 0;
a14 = 0;
a21 = (1/(m*Cp))*(Us*As + 4*eps*sigma*As*Tnom^3);
a22 = (1/(m*Cp))*(-U*A - 4*eps*sigma*A*Tnom^3 + Us*As + 4*eps*sigma*As*Tnom^3);
a23 = 0;
a24 = 0;
a31 = 1\tau;
a32 = 0;
a33 = -1\tau;
a34 = 0;
a41 = 0;
a42 = 1\tau;
a43 = 0;
a44 = -1\tau;

b11 = alpha1;
b12 = 0;
b21 = 0;
b22 = alpha2;
b31 = 0;
b32 = 0;
b41 = 0;
b42 = 0;

A = [a11 a12 a13 a14;
     a21 a22 a23 a24;
     a31 a32 a33 a34;
     a41 a42 a43 a44];

B = [b11 b12;
     b21 b22;
     b31 b32;
     b41 b42];

C = [0 0 1 0;
     0 0 0 1];

D = zeros(2,2);

sys = ss(A,B,C,D,'StateName',{'T_{H1}' 'T_{H2}' 'T_{C1}' 'T_{C2}'},...
    'InputName',{'Heater 1' 'Heater 2'});

end