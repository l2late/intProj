function[As, Cs, Ks] = SubId(U, Y, s, n, sing_val_plot)
% l: # of outputs
% m: # of inputs
% n: # of states
% Y = l*N
% U = m*N

% Extract data from input
m = size(U,1); % input vector size
N = size(U,2); % sample size

% Initialize Hankel matrices (past Output and current output)
Y_0sN = zeros(s*m, N - 2*s +1);
Y_ssN = zeros(s*m, N - 2*s +1);
U_0sN = zeros(s*m, N - 2*s +1);
U_ssN = zeros(s*m, N - 2*s +1);

% Populate Hankel matrices
for i = 1 : s
    if i == 1
        Y_0sN(1:i*m, :) = Y(:, i:N - 2*s + i);
        Y_ssN(1:i*m, :) = Y(:, s + i:N - s + i);
        U_0sN(1:i*m, :) = U(:, i:N - 2*s + i);
        U_ssN(1:i*m, :) = U(:, s + i:N - s + i);
    else
        Y_0sN((i-1)*m +1 :i*m, :) = Y(:, i:N - 2*s + i);
        Y_ssN((i-1)*m +1 :i*m, :) = Y(:, s + i : N - s + i);
        U_0sN((i-1)*m +1 :i*m, :) = U(:, i:N - 2*s + i);
        U_ssN((i-1)*m +1 :i*m, :) = U(:, s + i : N - s + i);
    end
end

% Define instrumental variable
Z_N = [U_0sN;
       Y_0sN];
   
M = [U_ssN ; Z_N; Y_ssN];

% Perform RQ factorization
r = triu(qr(M'))';

% Extract R11 and R21
R22 = r(s*m+1:3*s*m, s*m+1:3*s*m);
R32 = r(3*m*s + 1:end, s*m+1:3*s*m);

[~,S,V] = svd((R32/R22) * Z_N);

if sing_val_plot == true 
    figure
    semilogy(diag(S),'xb')
    title('Magnitude of singular values for $$(R_{32}/R_{22}) * Z_{N}^T$$','Interpreter','Latex','FontSize',22);
    ylabel('Magnitude','FontSize',24);
    xlabel('Model order','FontSize',24);
    h = findobj('NameFont','Helvetica');
    set(h,'FontSize',18)
    saveas(gca,'singVal.png');
end

V1          = V(1:n, :)';
Sigma       = S(1:n,1:n);
X_est_sN    = sqrtm(Sigma) * V1';

% Compute least squares solution
sol	= [X_est_sN(:, 2:end); Y_ssN(1:m, 1:end - 1)] / X_est_sN(:,1:end - 1);
As  = sol(1:n, 1:n);
Cs  = sol(n + 1:end, :);

% Compute residuals
W = X_est_sN(:,2:end) - As * X_est_sN(:,1:end -1);
V = Y_ssN(1:m,1:end -1 ) - Cs * X_est_sN(:,1:end -1);

% Compute covariance matrices
Q_est = 1/N * (W * W');
R_est = 1/N * (V * V');
S_est = 1/N * (W * V');

% Compute Kalman gain
[~,~,K] = dare(As', Cs', Q_est, R_est, S_est);
Ks = K';

end