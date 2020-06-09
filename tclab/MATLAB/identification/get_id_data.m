function [data, datap, datai, Tnom, T0, outputOffset] = get_id_data

% load test data depending on OS

if isunix
    load ../data/luca/semi_random_test_60min_luca.mat
elseif ispc
    load ../data/halithan/semi_random_test_60min_halithan.mat
else
    disp('Platform not supported')
end

% Extract data columns
% t = data(:,1);
% Q1 = data(:,2);
% Q2 = data(:,3);
% T1meas = data(:,4);
% T2meas = data(:,5);

T0 = ([data(1,4) data(1,5) data(1,4) data(1,5)]');
Ts = mean(diff(data(:,1)));

% Nominal temperature in K around which to linearize
Tnom = mean([data(1,4) data(1,5)]) + 273.15;

% Constuct data object for sys id
data = iddata([data(:,4) data(:,5)],[data(:,2) data(:,3);],Ts);

%% Preprocess output data to remove hi freq noise content and bias
datap = data;

% Substract equilibrium temperature (initial value) 
outputOffset = datap.OutputData(1,:);
datap.OutputData = datap.OutputData - outputOffset;

% low pass filter implemented as bandpass Butterworth
filter = [0 0.2];
datap.OutputData = idfilt(datap.OutputData,filter);

% Copy of filtered dataset without offset correction for comparison
datai = datap;
datai.OutputData = datai.OutputData + outputOffset;

% ADD RESAMPLED DATASET

end