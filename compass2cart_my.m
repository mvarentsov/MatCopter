function [u, v] = compass2cart_my (thetta, rho)
    
    thetta_notnan = thetta;
    rho_notnan = rho;
    
    thetta_notnan (isnan (thetta_notnan)) = 0;
    rho_notnan (isnan (rho_notnan)) = 0;
    
    [u, v] = compass2cart (thetta_notnan, rho_notnan);
    
    u (isnan (thetta)) = nan;
    u (isnan (rho)) = nan;
    
    v (isnan (thetta)) = nan;
    v (isnan (rho)) = nan;

    
end