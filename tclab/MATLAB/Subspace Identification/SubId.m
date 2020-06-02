function[As, Cs, Ks] = SubId(sid, s, n, sing_val_plot)

% Extract data from input
m = size(sid,1);
N = size(sid,2);

% Initialize Hankel matrices
S_0sN = zeros(s*m, N - 2*s +1);
S_ssN = zeros(s*m, N - 2*s +1);

% Populate Hankel matrices
for i = 1 : s
    if i == 1
        S_0sN(1:i*m, :) = sid(:, i:N - 2*s + i);
        S_ssN(1:i*m, :) = sid(:, s + i:N - s + i);
    else
        S_0sN((i-1)*m +1 :i*m, :) = sid(:, i:N - 2*s + i);
        S_ssN((i-1)*m +1 :i*m, :) = sid(:, s + i : N - s + i);
    end
end

% Define instrumental variable
Z_N = S_ssN;

% Perform RQ factorization
r = triu(qr([S_0sN ; Z_N]'))';

% Extract R11 and R21
R11 = r(1:s*m,1:s*m);
R21 = r(m*s + 1:size(r,1), 1:s*m);

[~,S,V] = svd((R21/R11) * Z_N);

if sing_val_plot == true 
    figure
    semilogy(diag(S),'xb')
    title('Magnitude of singular values for $$(R_{21}/R_{11}) * Z_{N}^T$$','Interpreter','Latex','FontSize',22);
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
sol	= [X_est_sN(:, 2:end); S_ssN(1:m, 1:end - 1)] / X_est_sN(:,1:end - 1);
As  = sol(1:n, 1:n);
Cs  = sol(n + 1:end, :);

% Compute residuals
W = X_est_sN(:,2:end) - As * X_est_sN(:,1:end -1);
V = S_ssN(1:m,1:end -1 ) - Cs * X_est_sN(:,1:end -1);

% Compute covariance matrices
Q_est = 1/N * (W * W');
R_est = 1/N * (V * V');
S_est = 1/N * (W * V');

% Compute Kalman gain
[~,~,K] = dare(As', Cs', Q_est, R_est, S_est);
Ks = K';

end
