% define objective

function obj = objective(p,t,Q1,Q2,T1meas,T2meas)

    % simulate model
    [Tc,~] = simulate(p,t,Q1,Q2,T1meas(1),T2meas(1));
    % calculate objective
    obj =  sum(((Tc(:,1)-T1meas)./T1meas).^2) ...
         + sum(((Tc(:,2)-T2meas)./T2meas).^2);
end