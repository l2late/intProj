function [vaf] = compute_vaf(phik,phik_est)

[n,T1] = size(phik);
[~,T2] = size(phik_est);

if T1>=T2
    T = T2;
elseif T2>=T1
    T = T1;
end

vaf_num = zeros(T,1);
vaf_den = zeros(T,1);
phik_est_piston_removed = zeros(n,T);
phik_piston_removed     = zeros(n,T);

for r = 1 : T
    phik_est_piston_removed(:,r) = phik_est(:,r) - mean(phik_est(:,r));
    phik_piston_removed(:,r) = phik(:,r) - mean(phik(:,r));
    vaf_num(r) = norm(phik_piston_removed(:,r) - phik_est_piston_removed(:,r));
    vaf_den(r) = norm(phik(:,r));
end

vaf_num = 1 / T * sum(vaf_num);
vaf_den = 1 / T * sum(vaf_den);
vaf = max(0, (1 - vaf_num / vaf_den) * 100);

end