%% Script to helps define a sine input for tclab 


close all; clear all; clc

time = 30;              % simulation time in min
n_samples = time*60;    % simulation time in seconds
per = 0.01;
mag = 20;
offset1 = 20;
offset2 = 40;

t = 0:1:n_samples;
sin_in = mag*sin(per*t);
in1 = sin_in + offset1;
in2 = sin_in + offset2;

% generate identification input
Q = [in1' in1'];

figure
plot(Q(:,1)); hold on
title('Q')
save('../data/inputs/sine_heater_input1','Q');

Q = [in2' in2'];

plot(Q(:,1))
title('Shifted sinusoidal heater inputs')
ylabel('%')
xlabel('Time (sec)')
xlim([0 n_samples])
legend({'First test input','Second test input'},'Location','SW');
save('../data/inputs/sine_heater_input2','Q');