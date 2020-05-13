function cool_down_check(a,cool_temp)

tclab_functions

while (T1C() > cool_temp) || (T2C() > cool_temp)
    fprintf('Waiting for setup to cool down\n');
    fprintf('Current temp:\t%4.2f\t%4.2f\n',T1C(),T2C());
    pause(10)
end

end