function run_one_test(Arduino,Q1,Q2,FileName)
% Peform test with tclab and save results to filename
% Inputs:   Q1 - Percent Heater 1 (0-100%)
%           Q2 - Percent Heater 2 (0-100%)
%           filename - filename for results

% format used for the time so that floating-point values 
% display with up to five digits
format shortg

% perform some checks on input
assert(size(Q1,2)==1);
assert(isequal(size(Q1),size(Q2)));

if isfile(strcat(FileName,'.mat'))
  % File already exist.
  msg=sprintf('Warning: file already exists:\n%s\n', FileName);
  warndlg(msg)
  return
end

a = Arduino;

% include tclab functions
tclab_functions

% set start time
start_time = clock;
prev_time = start_time;

% Intialize Time and Measurements
loops = size(Q1,1);
time = zeros(1,loops);
T1 = ones(1,loops) * T1C();     % measured T (sensor 1)
T2 = ones(1,loops) * T2C();     % measured T (sensor 2)

disp('Test starting...')

for ii = 1:loops
    % try/catch for gracefull shutdown and
    % save results if loop is interrupted
    try 
        % adjust power level
        h1(Q1(ii));
        h2(Q2(ii));

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

        % read and record from temperature controller
        T1(ii) = T1C();
        T2(ii) = T2C();
        
        %Display temperature reading
        fprintf('Time:\t%d\tTime left:\t%d\n',round(time(ii)),loops-ii);
        fprintf('Q:\t%4.2f\t%4.2f\n',Q1(ii),Q2(ii));
        fprintf('Temp:\t%4.2f\t%4.2f\n\n',T1(ii),T2(ii));
    catch
        % turn off heaters
        h1(0);
        h2(0);
        disp('Heaters off')
        % turn off heater but keep LED on if T > 50
        if (T1C() > 50) || (T2C() > 50)
            led(1)
            disp(['Warning, heater temperature 1 =', num2str(T1C())])
            disp(['Warning, heater temperature 2 =', num2str(T2C())])
        else
            % the line below gives an error for no apparent reason
            led(0)
        end
        
        % save txt file with data
        data = [time',Q1,Q2,T1',T2'];
        save(strcat(FileName,'.mat'),'data');
        
        disp('Test Interrupted...')
        return
    end
end

% turn off heaters
h1(0);
h2(0);
disp('Heaters off')
% turn off heater but keep LED on if T > 50
if (T1C() || T2C()) > 50
    led(1)
    disp(['Warning, heater temperature 1 =', num2str(T1C())])
    disp(['Warning, heater temperature 2 =', num2str(T2C())])
else
    % the line below gives an error for no apparent reason
    %led(0)
end

% save txt file with data
data = [time',Q1,Q2,T1',T2'];
save(strcat(FileName,'.mat'),'data');

disp('Test Complete')