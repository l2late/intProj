function [vaf] = compute_vaf(y,y_est)

[T1,~] = size(y);
[T2,~] = size(y_est);

if T1>=T2
    T = T2;
elseif T2>=T1
    T = T1;
end

vaf_num = sqrt(sum((y - y_est).^2,2));
vaf_den = sqrt(sum(y.^2,2));

vaf = max(0,(1-(1/T*sum(vaf_num)) / (1/T*sum(vaf_den))) *100);

end