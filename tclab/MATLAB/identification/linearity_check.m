% linearity_check
clear all; close all; 

load ../data/luca/sine_test1_30min

xrange = [800:1801];
xlimit = [800 1801];

% Extract data columns
t1 = data(xrange,1);
Q11 = data(xrange,2);
Q21 = data(xrange,3);
T1meas1 = data(xrange,4);
T2meas1 = data(xrange,5);
mq11 = mean(Q11);
mt11 = mean(T1meas1);


figure
plot(t1,T1meas1,t1,T2meas1); hold on


load ../data/luca/sine_test2_30min

% Extract data columns
t2 = data(xrange,1);
Q12 = data(xrange,2);
Q22 = data(xrange,3);
T1meas2 = data(xrange,4);
T2meas2 = data(xrange,5);
mq12 = mean(Q12);
mt12 = mean(T2meas2);

plot(t2,T1meas2,t2,T2meas2)
xlim(xlimit)
xlabel('Time (sec)')
ylabel('Degree Celsius')
legend({'T1_1','T2_1','T1_2','T2_2'},'Location','SW');
title('Temperature measurements for linearity verification');

qdiff = mq11 - mq12
tdiff = mt11 - mt12