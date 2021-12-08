function mc_draw_vprofiles_arrows (pr, varname, z_intervals, varargin)
    
    x_step = 0.05;
    x_margin = 0.05;
    x_sign = -1;
    
    excl_ind = [];
    
    if nargin >= 2
        for idx = 1:2:length(varargin)
            switch lower(varargin{idx})
                case 'xstep'
                    x_step = varargin{idx+1}; excl_ind = [excl_ind, idx, idx+1];      
                case 'xmargin'
                    x_margin = varargin{idx+1}; excl_ind = [excl_ind, idx, idx+1];      
                case 'location'
                    switch lower(varargin{idx+1})
                        case 'in'
                            x_sign = -1;
                        case 'out'
                            x_sign = 1;
                    end
                    excl_ind = [excl_ind, idx, idx+1];      
            end
        end
    end
    
    varargin (excl_ind) = [];
    

    [u_var, v_var] = mc_cart_varnames (varname);
    for i = 1:numel (pr)
        u = mc_profiles2draw (pr (i).asc, pr(i).dsc, u_var);
        v = mc_profiles2draw (pr (i).asc, pr(i).dsc, v_var);
        [u_mean, z_mean] = mc_intmean4scalar (z_intervals, pr(i).asc.z_levels2draw, u);
        v_mean           = mc_intmean4scalar (z_intervals, pr(i).asc.z_levels2draw, v);
        dir_mean = cart2compass_my (-u_mean, -v_mean);
        rel_x = 1 + x_margin * x_sign + (i - 1) * x_step * x_sign;
        mc_draw_arrows_profile (rel_x, z_mean, dir_mean,  'Color',  pr(i).color, varargin {1:end});
    end
end

