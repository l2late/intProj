%%
clc
clear
close all

load semi_random_test_Halithan.mat

%%
% plot heater input
time = data(:,1);
Q1 = data(:,2);
Q2 = data(:,3);
T1 = data(:,4);
T2 = data(:,5);

%% plot
hold on 
plot(time,[Q1 T1],'r')
plot(time,[Q2 T2],'b')

ylabel('Heater setting');
xlabel('Time (in seconds)');
legend('Heater 1 input and sensor 1 output','Heater 2 input and sensor 2 output')