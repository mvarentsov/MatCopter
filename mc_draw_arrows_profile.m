function mc_draw_arrows_profile(rel_x, z, dir, varargin)
    %dir_mean = cart2compass_my (-u_mean, -v_mean);
    x_lim = get (gca, 'XLim');
    y_lim = get (gca, 'YLim');
    
    ind2draw = find (z >= y_lim (1) & z <= y_lim (2));
    
    z = z (ind2draw);
    dir = dir (ind2draw);
    
    x = x_lim(1) + (x_lim (2) - x_lim (1)) * rel_x * ones (size (z));
    
    mc_draw_arrows (x, z, dir, varargin {1:end});
end

