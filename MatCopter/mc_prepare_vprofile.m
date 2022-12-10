function [reg_asc, reg_dsc] = mc_prepare_vprofile (sens_data, z_levels, z_var, var2draw, inertion)

    var2draw_corr = [var2draw, '_corr'];
    
    sens_data.vars.(var2draw_corr) = mc_apply_inertion_corr (sens_data.vars.(var2draw), inertion);
    
    reg_asc = ... 
        mc_intmean4scalar (z_levels, sens_data.vars.(z_var)        (sens_data.flight_ind_asc), ...
                                     sens_data.vars.(var2draw_corr)(sens_data.flight_ind_asc));
    
    reg_dsc = ...
        mc_intmean4scalar (z_levels, sens_data.vars.(z_var)        (sens_data.flight_ind_dsc), ...
                                     sens_data.vars.(var2draw_corr)(sens_data.flight_ind_dsc));
end

