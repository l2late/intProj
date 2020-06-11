% define second order eenergy balance model
function dTdt = heat2_2order(t,x,Q1,Q2,p)
    U       = p(1);
    alpha1  = p(2);
    alpha2  = p(3);
    Us      = p(4);
    tau     = p(5);         % Conduction coefficient
    
    % Parameters
    Ta      = 23 + 273.15;      % K
    m       = 4.0/1000.0;       % kg
    Cp      = 0.5 * 1000.0;     % J/kg-K    
    A       = 10.0 / 100.0^2;   % Area in m^2
    As      = 2.0 / 100.0^2;    % Area in m^2
    eps     = 0.9;              % Emissivity
    sigma   = 5.67e-8;          % Stefan-Boltzman
        
    % Temperature States
    Tc1 = x(1) + 273.15; % temperature from sensor 1
    Tc2 = x(2) + 273.15; % temperature form sensor 2
    Th1 = x(3) + 273.15; % temperature heater 1
    Th2 = x(4) + 273.15; % temperature heater 2

    % Heat Transfer Exchange Between 1 and 2
    conv12 = Us*As*(Th2-Th1);
    rad12  = eps*sigma*As * (Th2^4 - Th1^4);

    % Nonlinear Energy Balances
    dTh1dt = (1.0/(m*Cp))*(U*A*(Ta-Th1) ...
            + eps * sigma * A * (Ta^4 - Th1^4) ...
            + conv12 + rad12 ...
            + alpha1*Q1);
    dTh2dt = (1.0/(m*Cp))*(U*A*(Ta-Th2) ...
            + eps * sigma * A * (Ta^4 - Th2^4) ...
            - conv12 - rad12 ...
            + alpha2*Q2);
        
    dTc1dt = (Th1 - Tc1)*tau;
    dTc2dt = (Th2 - Tc2)*tau;
    
    dTdt = [dTc1dt,dTc2dt,dTh1dt,dTh2dt]';
    
end