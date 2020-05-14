%% helper script for setting and visualizing heater inputs
clear all; close all; clc

time = 30;              % simulation time in min
loops = time*60;        % simulation time in seconds
time = 1:1:loops;
Q1 = zeros(loops,1);    
Q2 = zeros(loops,1);   

% set heating values for heater 1
% column 1 and 2: interval begin and end as fraction of total time
% column 3: heater setting for the corresponding interval
set_h1 =    [.1     .2      90;
             .2     .5      30;
             .5     .8      100;
             .8     1       10];

% adjust level for heater 1
for ii = 1:size(set_h1,1)
    Q1(floor(set_h1(ii,1)*loops):ceil(set_h1(ii,2)*loops),1) = set_h1(ii,3);
end
    
% set heating values for heater 2
% column 1 and 2: interval begin and end as fraction of total time
% column 3: heater setting for the corresponding interval
set_h2 =    [.01    .1      40;
             .1     .3      10;
             .3     .6      60;
             .6     .7      50;
             .7      1      100];

% adjust level for heater 2
for ii = 1:size(set_h2,1)
    Q2(floor(set_h2(ii,1)*loops):ceil(set_h2(ii,2)*loops),1) = set_h2(ii,3);
end

Q = [Q1 Q2];

% plot heater input
plot(time,Q)
ylabel('Heater setting');
xlabel('Time (in seconds)');
legend('Heater 1','Heater 2')

save('semirandom_heater_input','Q');