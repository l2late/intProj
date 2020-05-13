%% helper script for setting and visualizing heater inputs
clear all; close all; clc

time = 30;              % simulation time in min
loops = time*60;        % simulation time in seconds
time = 1:1:loops;
Q1 = zeros(loops,1);    
Q2 = zeros(loops,1);   

% set interval begin and end as fraction of total time
int_h1 = [.1 0.2;
          0.2 0.5;
          0.5 0.8;
          0.8 1  ];

indx_h1 = [floor(int_h1(:,1)*loops) ceil(int_h1(:,2)*loops)];

% adjust level for heater 1
Q1(indx_h1(1,1):indx_h1(1,2),1) = 90;
Q1(indx_h1(2,1):indx_h1(2,2),1) = 30;
Q1(indx_h1(3,1):indx_h1(3,2),1) = 100;
Q1(indx_h1(4,1):indx_h1(4,2),1) = 10;


% set interval begin and end as fraction of total time
int_h2 = [.01 0.1;
          .1   .3;
          0.3 0.6;
          0.6 0.7;
          0.7 1  ];

indx_h2 = [floor(int_h2(:,1)*loops) ceil(int_h2(:,2)*loops)];

% adjust level for heater 2
Q2(indx_h2(1,1):indx_h2(1,2),1) = 40;
Q2(indx_h2(2,1):indx_h2(2,2),1) = 10;
Q2(indx_h2(3,1):indx_h2(3,2),1) = 60;
Q2(indx_h2(4,1):indx_h2(4,2),1) = 50;
Q2(indx_h2(5,1):indx_h2(5,2),1) = 100;

Q = [Q1 Q2];

% plot heater input
plot(time,Q) 
ylabel('Heater setting');
xlabel('Time (in seconds)');
legend('Heater 1','Heater 2')

save('semirandom_heater_input','Q');