% source: https://apmonitor.com/pdc/index.php/Main/ArduinoModeling
% Adapted by Luca for linearization
% define linearized energy balance model
function dTdt = heat_lin(t,x,Q)
    % Parameters
    Ta      = 23 + 273.15;      % K
    U       = 10.0;             % W/m^2-K
    m       = 4.0/1000.0;       % kg
    Cp      = 0.5 * 1000.0;     % J/kg-K    
    A       = 12.0 / 100.0^2;   % Area in m^2
    alpha   = 0.01;             % W / % heater
    eps     = 0.9;              % Emissivity
    sigma   = 5.67e-8;          % Stefan-Boltzman

    % Temperature State
    T = x(1);
   
    % Partial derivatives around Ta = 23 and Q = 0
    dfdT    = -U*A/(m*Cp) - 4*eps*sigma*A*(Ta)^3/(m*Cp);
    dfdQ    = alpha/(m*Cp);
    
    % Linear Energy Balance
    dTdt = dfdT * (T-23) + dfdQ * (Q-0);
end