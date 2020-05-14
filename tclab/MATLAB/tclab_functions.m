%% tclab_functions
% only tclab functions
% does not try to make a new connection

% voltage read functions
v1 = @() readVoltage(a, 'A0');
v2 = @() readVoltage(a, 'A2');

% temperature calculations as a function of voltage for TMP36
TC = @(V) (V - 0.5)*100.0;          % Celsius
TK = @(V) TC(V) + 273.15;           % Kelvin
TF = @(V) TK(V) * 9.0/5.0 - 459.67; % Fahrenhiet

% temperature read functions
T1C = @() TC(v1());
T2C = @() TC(v2());

% LED function (0 <= level <= 1)
led = @(level) writePWMDutyCycle(a,'D9',max(0,min(1,level)));  % ON

% heater output (0 <= heater <= 100)
% limit to 0-0.9 (0-100%)
h1 = @(level) writePWMDutyCycle(a,'D3',max(0,min(100,level))*0.9/100);
% limit to 0-0.5 (0-100%)
h2 = @(level) writePWMDutyCycle(a,'D5',max(0,min(100,level))*0.9/100);