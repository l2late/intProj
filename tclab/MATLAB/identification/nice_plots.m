clear all
close all

who = {'luca'};
focus = {'simulation','prediction'};
resampleFactor = 1;

[data, datap_id, datai_id, Tnom, T0, outputOffset] = ....
    get_data(who{1},resampleFactor,'id');

%% input id
figure;
subplot(1,2,1)
plot(datap_id.u(:,1))
title('Q1')
xlabel('Time (sec)')
ylabel('%')
xlim([0 3600])
subplot(1,2,2)
plot(datap_id.u(:,2))
title('Q2')
xlabel('Time (sec)')
ylabel('%')
xlim([0 3600])
sgtitle('Inputs for system identification');
set(gcf, 'Position',  [100, 2000, 800, 200])

%% output id

% subset
figure;
subplot(2,1,1)
plot(data.y(:,2))
title('T2 - Raw') 
xlabel('Time (sec)')
ylabel('Degree Celcius')
xlim([700 1300])
subplot(2,1,2)
plot(datap_id.y(:,2))
title('T2 - Processed')
xlabel('Time (sec)')
ylabel('Degree Celcius')
xlim([700 1300])
set(gcf, 'Position',  [100, 2000, 800, 400])

% id output
figure;
plot(datap_id.y(:,1),'-k'); hold on
xlabel('Time (sec)')
ylabel('Degree Celcius')
xlim([0 3600])
plot(datap_id.y(:,2),'--k')
xlabel('Time (sec)')
ylabel('Degree Celcius')
legend({'T1','T2'});
title('Output identification data')
xlim([0 3600])
set(gcf, 'Position',  [100, 2000, 800, 200])



datafd = fft(data);
opt = iddataPlotOptions('frequency');
opt.PhaseVisible = 'off'; 
opt.FreqUnits = 'Hz';
figure
plot(datafd(:,2,[]),opt)
title('Frequency content of second output of identification data')

[data, datap_val, datai_val, Tnom, T0, outputOffset] = ....
    get_data(who{1},resampleFactor,'val');

figure;
subplot(1,2,1)
plot(datap_val.u(:,1))
title('Q1')
xlabel('Time (sec)')
ylabel('%')
xlim([0 3600])
subplot(1,2,2)
plot(datap_val.u(:,2))
title('Q2')
xlabel('Time (sec)')
ylabel('%')
xlim([0 3600])
sgtitle('Inputs for system validation');
set(gcf, 'Position',  [100, 2000, 800, 200])


% val output
figure;
plot(datap_val.y(:,1),'-k'); hold on
xlabel('Time (sec)')
ylabel('Degree Celcius')
xlim([0 3600])
plot(datap_val.y(:,2),'--k')
xlabel('Time (sec)')
ylabel('Degree Celcius')
legend({'T1','T2'});
title('Output validation data')
xlim([0 3600])
set(gcf, 'Position',  [100, 2000, 800, 200])


