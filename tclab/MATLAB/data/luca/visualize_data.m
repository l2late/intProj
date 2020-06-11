close all; clear all; clc


%datafiles = dir('../inputs/prbs*.mat');
datafiles = dir('both*.mat');

nf = length(datafiles);

for ii = 1:1
    
    load([sprintf('%s',datafiles(ii).folder), filesep, sprintf('%s',datafiles(ii).name)]);
    
    if exist('data','var') == 1
        % Extract data columns
        t = data(:,1);
        Q1 = data(:,2);
        Q2 = data(:,3);
        T1meas = data(:,4);
        T2meas = data(:,5);

        figure
        plot(t,T1meas,t,T2meas)
        title(sprintf('%s',datafiles(ii).name))
        
    elseif exist('Q','var') == 1
        figure
        plot(Q)
        title(sprintf('%s',datafiles(ii).name))
    end
    
end