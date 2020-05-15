% Source: https://apmonitor.com/pdc/index.php/Main/ArduinoModeling2
% define energy balance model
function dTdt = heat2_lin(t,x,Q1,Q2)
    % Parameters
    Ta = 23 + 273.15;   % K
    U = 10.0;           % W/m^2-K
    m = 4.0/1000.0;     % kg
    Cp = 0.5 * 1000.0;  % J/kg-K    
    A = 10.0 / 100.0^2; % Area in m^2
    As = 2.0 / 100.0^2; % Area in m^2
    alpha1 = 0.0100;    % W / % heater 1
    alpha2 = 0.0075;    % W / % heater 2
    eps = 0.9;          % Emissivity
    sigma = 5.67e-8;    % Stefan-Boltzman

    % Temperature States
    T1 = x(1);
    T2 = x(2);
    
    % average temperature between 1 and 2
    % BEWARE: violates LTI assumption
    T_bar = mean([T1 T2]);

    % Linearized Heat Transfer Exchange Between 1 and 2
    conv12 = U*As*(T2-T1);
    rad12  = eps*sigma*As * 4*T_bar*(T2-T1);
    
    % Partial derivatives around Ta = 23 and Q = 0
    dfdT    = - U*A/(m*Cp) - 4*eps*sigma*A*(Ta)^3/(m*Cp);
    dfdQ1   = alpha1/(m*Cp);
    dfdQ2   = alpha2/(m*Cp);
    
    % Linear Energy Balances
    dT1dt = dfdT * (T1-23) + conv12 + rad12 + dfdQ1 * (Q1-0);
    dT2dt = dfdT * (T2-23) - conv12 - rad12 + dfdQ2 * (Q2-0);
        
    dTdt = [dT1dt,dT2dt]';
end