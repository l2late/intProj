%% Subspace Identification

% load test data
load ../results/luca/semi_random_test_60min_luca.mat

% split in Identification and validation set
data_id     = ;
data_val    = ;

%number of realizations
N_real = 1;

vaf_sid     = zeros(1,N_real);
sigma_sid   = zeros(1,N_real);

for ii = 1:N_real
    
    s       = 2;
    n       = 4; % Order of subspace model
    
    sing_val_plot       = false; % Plot magnitude of singular values
    [A, C, K]           = SubId(data_id, s, n, sing_val_plot);
    [var_eps, vaf]      = loopSID(G,H,A,C,K,sigmae,data_val);
    vaf_sid(ii)         = vaf;
    sigma_sid(ii)       = var_eps;
end