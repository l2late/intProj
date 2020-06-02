%% Subspace Identification

% load test data
load ../results/luca/semi_random_test_60min_luca.mat

vaf_sid     = zeros(1,N_real);
sigma_sid   = zeros(1,N_real);

for ii = 1:N_real
    
    phisim  = phiSim{ii};
    phiid   = phiIdent{ii};
    s       = 3;
    n       = 60; % Order of subspace model
    
    % Generate identification data
    sid = G * phiid + sigmae * randn(size(G,1),size(phiid,2));   
    sing_val_plot       = false; % Plot magnitude of singular values
    [As, Cs, Ks]        = SubId(sid, s, n, sing_val_plot);
    [var_eps, vaf]      = AOloopSID(G,H,As,Cs,Ks,sigmae,phisim);
    vaf_sid(ii)         = vaf;
    sigma_sid(ii)       = var_eps;
end