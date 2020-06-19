function [data, datap, datai, Tnom, T0, outputOffset] = get_data(who,resampleFactor,type)


% load test data
if strcmp(type,'id')
    loadName = ['../data/',who,'/prbs_test_60min.mat'];
    load(loadName);
elseif strcmp(type,'val')
    loadName = ['../data/',who,'/prbs_test_60min_val.mat'];
    load(loadName);
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

% Resampled dataset: 
% only if factor is not 1 and if type is 'id'
if (resampleFactor ~= 1) || strcmp(type,'id')% && (resampleFactor ~= 1)
    datap = resample(datap,1,resampleFactor);
    datai = datap;
    datai.OutputData = datai.OutputData + outputOffset;
end

end