% define objective

function obj = objective(p,t,Q1,Q2,T1meas,T2meas)

    % simulate model
    Tp = simulate(p,t,Q1,Q2,T1meas,T2meas);
    % calculate objective
    obj =  sum(((Tp(:,1)-T1meas)./T1meas).^2) ...
         + sum(((Tp(:,2)-T2meas)./T2meas).^2);
end