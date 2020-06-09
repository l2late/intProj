%% Script to helps define a Pseudo Random Binary Sequence input for tclab 

% If Type is 'prbs' — Specify Band as [0 B], where B is the inverse of 
% the clock period of the signal. The clock period is the minimum number 
% of sampling intervals for which the value of the signal does not change.
% Thus, the generated signal is constant over intervals of length 1/B samples.


time = 60;              % simulation time in min
n_samples = time*60;    % simulation time in seconds
n_inputs = 2;
band = [0 0.01];
range = [0 100];

Q = idinput([n_samples n_inputs],'prbs', band, range);

figure
subplot(2,1,1)
plot(Q(:,1))
title('Q1')
subplot(2,1,2)
plot(Q(:,2))
title('Q2')

save('../data/inputs/prbs_heater_input_60min','Q');