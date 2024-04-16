function [thetta, rho] = cart2compass_my (u, v)
    
    u_notnan = u;
    v_notnan = v;
    
    u_notnan (isnan (u)) = 0;
    v_notnan (isnan (v)) = 0;
    
    [thetta, rho] = cart2compass (u_notnan, v_notnan);
    
    thetta (isnan (u)) = nan;
    thetta (isnan (v)) = nan;

    thetta (rho == 0) = nan;
    
    rho (isnan (u)) = nan;
    rho (isnan (v)) = nan;

    
end