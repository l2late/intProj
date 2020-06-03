%% Subspace Identification

% load test data
load ../results/luca/semi_random_test_60min_luca.mat

% percentage of data to use for identification
pcnt_id = 0.7;

% Split data in Identification and validation set
n_data = length(t);
indx_split = floor(n_data*pcnt_id);
u_id     = [Q1(1:indx_split,1)          Q2(1:indx_split,1)];
u_val    = [Q1(indx_split+1:end,1)      Q2(indx_split+1:end,1)];
y_id     = [T1meas(1:indx_split,1)      T2meas(1:indx_split,1)];
y_val    = [T1meas(indx_split+1:end,1)  T2meas(indx_split+1:end,1)];

%number of realizations
N_real = 1;

% init matrices for variance accounted for
vaf_sid     = zeros(1,N_real);
sigma_sid   = zeros(1,N_real);

for ii = 1:N_real
    
    s       = 2;
    n       = 4; % Order of subspace model
    
    sing_val_plot       = true; % Plot magnitude of singular values
    [A, C, K]           = SubId(u_id, y_id, s, n, sing_val_plot);
    [var_eps, vaf]      = loopSID(G,H,A,C,K,sigmae,data_val);
    vaf_sid(ii)         = vaf;
    sigma_sid(ii)       = var_eps;
end