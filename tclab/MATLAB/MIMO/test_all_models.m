clc; clear all; close all; format shortg

% include tclab
tclab

% simulation time
time = 10;           % time in min
loops = time*60;        % simulation time in seconds

% Measurements and Predictions
time = zeros(1,loops);
T1 = ones(1,loops) * T1C();       % measured T (sensor 1)
T2 = ones(1,loops) * T2C();       % measured T (sensor 2)
Tp1_nl = ones(1,loops) * T1C();   % pred T1 (non-linear energy balance model)
Tp2_nl = ones(1,loops) * T2C();   % pred T2 (non-linear energy balance model)
Tp1_l = ones(1,loops) * T1C();    % pred T1 (linear energy balance model)
Tp2_l = ones(1,loops) * T2C();    % pred T2 (linear energy balance model)

% Error allocation
error1_nl = zeros(loops,1);        % error vector for non-linear T1 model
error2_nl = zeros(loops,1);        % error vector for non-linear T2 model
error1_l = zeros(loops,1);         % error vector for linear T1 model
error2_l = zeros(loops,1);         % error vector for linear T2 model

% Power allocation
Q = zeros(loops,2);

% adjust heater levels
Q(10:end,1) = 90;   % heater 1
Q(300:end,2) = 80;  % heater 2

start_time = clock;
prev_time = start_time;

% dynamic plot (note: subplots needs to be declared here first)
figure(1)
subplot(3,1,1)
hold on, grid on
% measured temperature
anexp1_1 = animatedline('LineStyle','-', 'Color', 'k', 'LineWidth', 2);
anexp2_1 = animatedline('LineStyle','-', 'Color', 'g', 'LineWidth', 2);
% predicted non-linear temperature
anpred1_nl = animatedline('LineStyle','--','Color', 'b','LineWidth', 2);
anpred2_nl = animatedline('LineStyle','--','Color', 'r', 'LineWidth', 2);
xlabel('Time (sec)')
ylabel('Temperature \circC')
legend('T_1 Measured', 'T_2 Measured', ...
    'T_1 NL Predicted', 'T_2 NL Predicted', ...
    'Location', 'northwest')
title('Non-Linear Temperature Simulation')

subplot(3,1,2)
hold on, grid on
% measured temperature
anexp1_2 = animatedline('LineStyle','-', 'Color', 'k', 'LineWidth', 2);
anexp2_2 = animatedline('LineStyle','-', 'Color', 'g', 'LineWidth', 2);
% predicted linear temperature
anpred1_l = animatedline('LineStyle','--','Color', 'm','LineWidth', 2);
anpred2_l = animatedline('LineStyle','--','Color', 'c', 'LineWidth', 2);
xlabel('Time (sec)')
ylabel('Temperature \circC')
legend('T_1 Measured', 'T_2 Measured', ...
    'T_1 L Predicted', 'T_2 L Predicted', ...
    'Location', 'northwest')
title('Linear Temperature Simulation')

subplot(3,1,3)
hold on, grid on
yyaxis left
anerror_nl = animatedline('LineStyle','-', 'Color', 'b', 'LineWidth', 2);
anerror_l = animatedline('LineStyle','-', 'Color', 'r', 'LineWidth', 2);
xlabel('Time (sec)')
ylabel('Cumulative Error')
yyaxis right
title('Step and Error Simulation')
anQ1 = animatedline('LineStyle','-', 'Color', 'k', 'LineWidth', 2);
anQ2 = animatedline('LineStyle','--', 'Color', 'r', 'LineWidth', 2);
ylabel('Power Level Q (%)')
xlabel('time (sec)')
legend('Non-Linear Energy Balance Error',...
    'Linear Energy Balance Error',...
    'Q_1', 'Q_2', 'Location', 'northwest')

for ii = 1:loops
    % adjust power level
    Q1s(ii) = Q(ii,1);
    Q2s(ii) = Q(ii,2);
    h1(Q1s(ii));
    h2(Q2s(ii));
    
    % Pause Sleep time
    pause_max = 1.0;
    pause_time = pause_max - etime(clock,prev_time);
    if pause_time >= 0.0
        pause(pause_time - 0.01)
    else
        pause(0.01)
    end
    
    % Record time and change in time
    t = clock;
    dt = etime(t,prev_time);
    if ii>=2
        time(ii) = time(ii-1) + dt;
    end
    prev_time = t;
    
    % next time step, for prediction
    jj = ii+1;
    
    % non-linear energy balance
    [tsim_nl, Tnext_fnd_nl] = ode45(@(tsim,x)heat2(tsim,x,...
        Q1s(ii),Q2s(ii)), [0 dt],...
        [Tp1_nl(jj-1)+273.15,Tp2_nl(jj-1)+273.15]);
    Tp1_nl(jj) = Tnext_fnd_nl(end,1) - 273.15;
    Tp2_nl(jj) = Tnext_fnd_nl(end,2) - 273.15;
    
    % linear energy balance
    [tsim_l, Tnext_fnd_l] = ode45(@(tsim,x)heat2_lin(tsim,x,...
        Q1s(ii),Q2s(ii)), [0 dt],...
        [Tp1_l(jj-1)+273.15,Tp2_l(jj-1)+273.15]);
    Tp1_l(jj) = Tnext_fnd_l(end,1) - 273.15;
    Tp2_l(jj) = Tnext_fnd_l(end,2) - 273.15;
        
    % read and record from temperature controller
    T1(ii) = T1C();
    T2(ii) = T2C();
    
    % calculate error for non-linear model
    error1_nl(jj) = error1_nl(ii) + dt * abs(T1(ii) - Tp1_nl(ii));
    error2_nl(jj) = error2_nl(ii) + dt * abs(T2(ii) - Tp2_nl(ii));
    error_nl(jj) = error1_nl(jj) + error2_nl(jj);
    
    % calculate error for linear model
    error1_l(jj) = error1_l(ii) + dt * abs(T1(ii) - Tp1_l(ii));
    error2_l(jj) = error2_l(ii) + dt * abs(T2(ii) - Tp2_l(ii));
    error_l(jj) = error1_l(jj) + error2_l(jj);
    
    % plot
    addpoints(anexp1_1,time(ii),T1(ii))
    addpoints(anexp2_1,time(ii),T2(ii))
    addpoints(anexp1_2,time(ii),T1(ii))
    addpoints(anexp2_2,time(ii),T2(ii))
    % Non-linear
    addpoints(anpred1_nl,time(ii),Tp1_nl(ii))
    addpoints(anpred2_nl,time(ii),Tp2_nl(ii))
    addpoints(anerror_nl,time(ii),error_nl(ii))
    % Linear
    addpoints(anpred1_l,time(ii),Tp1_l(ii))
    addpoints(anpred2_l,time(ii),Tp2_l(ii))
    addpoints(anerror_l,time(ii),error_l(ii))
    % Heater setting
    addpoints(anQ1,time(ii),Q1s(ii))
    addpoints(anQ2,time(ii),Q2s(ii))
    drawnow
    
end

disp(['Non-Linear Energy Balance Cumulative Error =',...
    num2str(error_nl(end,1))]);
disp(['Linear Energy Balance Cumulative Error =',...
    num2str(error_l(end,1))]);
h1(0);
h2(0);
disp('Heaters off')
% turn off heater but keep LED on if T > 50
if (T1C() || T2C()) > 50
    led(1)
    disp(['Warning, heater temperature 1 =', num2str(T1C())])
    disp(['Warning, heater temperature 2 =', num2str(T2C())])
else
    led(0)
end

% save txt file with data
data = [time',Q1s',Q2s',T1',T2',Tp1_nl',Tp2_nl',Tp1_l',Tp2_l'];
csvwrite('data.txt',data);
