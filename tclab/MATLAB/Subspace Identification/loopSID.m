function[var_eps, vaf] = AOloopSID(G,H,As,Cs,Ks,sigmae,phisim)

% Extract data from input
N   = length(phisim);
m   = size(G,1);
ns  = size(H,1);
np  = size(As,1);

% Define matrix sizes
s                           = zeros(m,N);
u                           = zeros(ns,N);
x_est                       = zeros(np,N);
sk_est                      = zeros(m,N);
phi_est                     = zeros(ns,N);
eps_est                     = zeros(ns,N);
epsk_piston_removed         = zeros(ns,N);
var_eps                     = zeros(1,N);

[Ug, Sg, Vg]    = svd(G);
dim             = rank(Sg);
U1g             = Ug(:,1:dim);
V1g             = Vg(1:dim,:)';
Sigma           = Sg(1:dim,1:dim);
Gamma           = V1g * Sigma^-1 * U1g';

for k = 1:N-1
    s(:,k)          = G * phisim(:,k) + sigmae * randn(m,1);
    x_est(:,k+1)    = As * x_est(:,k) + Ks * (s(:,k) - Cs * x_est(:,k));
    sk_est(:,k)     = Cs * x_est(:,k+1) ;
    u(:,k+1)        = H \ (Gamma * Cs * ((As-Ks*Cs) * x_est(:,k) + Ks * sk_est(:,k)));
    eps_est(:,k)    = Gamma * sk_est(:,k) - H * u(:,k);
    phi_est(:,k+1)  = eps_est(:,k+1) + H * u(:,k);  
    epsk_piston_removed(:,k) = eps_est(:,k) - mean(eps_est(:,k));
    var_eps(k)      = var(epsk_piston_removed(:,k));
end

%Compute variance and VAF
var_eps = mean(var_eps);
vaf     = compute_vaf(phisim, phi_est);


end