function[A, B, C, D, K] = SubId(U, Y, s, n, sing_val_plot)
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

% Extract R22 and R32 p(333)
R22 = r(s*m+1:3*s*m, s*m+1:3*s*m);
R32 = r(3*m*s + 1:end, s*m+1:3*s*m);

[~,S,V] = svd((R32/R22) * Z_N);

if sing_val_plot == true 
    figure
    semilogy(diag(S),'xb')
    title('Magnitude of singular values for $$(R_{32}/R_{22}) * Z_{N}^T$$',...
        'Interpreter','Latex','FontSize',22);
    ylabel('Magnitude','FontSize',24);
    xlabel('Model order','FontSize',24);
    h = findobj('NameFont','Helvetica');
    set(h,'FontSize',18)
    %saveas(gca,'singVal.png');
end

V1          = V(1:n, :)';
Sigma       = S(1:n,1:n);
X_est_sN    = sqrtm(Sigma) * V1';

% Compute least squares solution (p332 Eq. 9.69)
% NOT ENTIRELY SURE ABOUT THIS ONE
sol	= [X_est_sN(:, 2:end); Y_ssN(1:m, 1:end-1)] /...
      [X_est_sN(:, 1:end-1); U_ssN(1:m, 1:end-1)];
    
A  = sol(1:n, 1:n);
B  = sol(1:n, n+1:end);
C  = sol(n+1:end, 1:n);
D  = sol(n+1:end, n+1:end);

% Compute residuals (p333, Eq. 9.70)
NM = [X_est_sN(:, 2:end); Y_ssN(1:m, 1:end-1)]-...
    [A B; C D]*[X_est_sN(:,1:end-1); U_ssN(1:m, 1:end-1)];
% Extract residuals
W = NM(1:n,:);
V = NM(n+1:end,:);

% Compute covariance matrices
Q = 1/N * (W * W');
R = 1/N * (V * V');
S = 1/N * (W * V');

% Compute Kalman gain
[~,~,K] = dare(A', C', Q, R, S);
K = K';

end

% Back up code
% size(X_est_sN(:, 2:end))
% size(Y_ssN(1:m, 1:end-1))
% size(X_est_sN; U_ssN(1:m, 1:end-1)
%W = X_est_sN(:,2:end) - As * X_est_sN(:,1:end -1);
%V = Y_ssN(1:m,1:end -1 ) - Cs * X_est_sN(:,1:end -1);