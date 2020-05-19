function [T_c,T_h] = simulate(p,t,Q1,Q2,T1meas_init,T2meas_init)


T_c         = zeros(length(t),2);
T_c(1,1)    = T1meas_init;      % only need first measurement
T_c(1,2)    = T2meas_init;
T_h         = T_c;              % initialize heater temp to sensor temp
T0          = [T_c(1,1),T_c(1,2),T_h(1,1),T_h(1,2)];

for i = 1:length(t)-1
    ts = [t(i),t(i+1)];
    sol = ode15s(@(t,x)heat2_2order(t,x,Q1(i),Q2(i),p),ts,T0);
    T0 = [sol.y(1,end),sol.y(2,end),sol.y(3,end),sol.y(4,end)];
    T_c(i+1,1) = T0(1);
    T_c(i+1,2) = T0(2);
    T_h(i+1,1) = T0(3);
    T_h(i+1,2) = T0(4);
end

end