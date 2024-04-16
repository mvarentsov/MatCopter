function [u_var, v_var, vel_var] = mc_cart_varnames (dir_var)
    vel_var = strrep (dir_var, 'windd', 'winds');
    u_var = [vel_var, '_u'];
    v_var = [vel_var, '_v'];
end

