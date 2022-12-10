function [corr_info] = mc_estimate_inertion (sens_data, varnames, max_intertion, z_varname)

    try
        max_intertion;
    catch exc
        max_intertion = 30;
    end

    try
        z_varname;
    catch exc
        z_varname = sens_data.info.pressure_var;
    end
    
    if (~iscell (varnames))
        varnames = {varnames};
    end
    
    for i_var = 1:numel (varnames)
        varname = varnames {i_var};
        if (~ismember (sens_data.vars.Properties.VariableNames, varname))
            warning ([varname ' is not availibe']);
            continue;
        end

    
        varname_corr = [varname, '_corr'];

        if (numel (sens_data.flight_ind_dsc) < 0.25 * numel (sens_data.flight_ind_asc))
            warning('too low points for dsc flight, inertion correction is skipped');
            cur_corr_info.best_corr = 0;
            cur_corr_info.best_rmse = 0;
        else

            best_corr = -1/eps;
            best_rmse = 1/eps;

            best_corr_inertion  = 0;
            best_rmse_inertion = 0;


            z_all = sens_data.vars.(z_varname) (sens_data.flight_ind);

            min_z = min (z_all);
            max_z = max (z_all);

            z_step = (max_z - min_z) / 100;

            z_levels = min_z:z_step:max_z;

            nan_warning = false;

            for inertion = 0:max_intertion

                sens_data.vars.(varname_corr) = ...
                    mc_apply_inertion_corr (sens_data.vars.(varname), inertion);

                reg_asc.(varname) = ...
                    mc_intmean4scalar (z_levels, ...
                                  sens_data.vars.(z_varname)    (sens_data.flight_ind_asc), ...
                                  sens_data.vars.(varname_corr) (sens_data.flight_ind_asc));

                reg_dsc.(varname) = ...
                    mc_intmean4scalar (z_levels, ...
                                  sens_data.vars.(z_varname)    (sens_data.flight_ind_dsc), ...
                                  sens_data.vars.(varname_corr) (sens_data.flight_ind_dsc));

                ok_ind = find (~isnan (reg_asc.(varname) .*  reg_dsc.(varname)));


                try
                    c = corr (reg_asc.(varname) (ok_ind), reg_dsc.(varname) (ok_ind));
                catch
                    c = nan; 
                    nan_warning = true;
                end
                %corr = corrcoef (reg_asc.(sname).(vname) (ok_ind), reg_dsc.(sname).(vname) (ok_ind));
                %corr = corr (1, 2);
                delta = reg_asc.(varname) (ok_ind) - reg_dsc.(varname) (ok_ind);
                rmse = sqrt (mean (delta .^ 2));


                if (c > best_corr)
                    best_corr = c;
                    best_corr_inertion = inertion;
                end

                if (rmse < best_rmse)
                    best_rmse = rmse;
                    best_rmse_inertion = inertion;
                end
            end


            if (nan_warning)
                warning(['nan correlation found for ', varname]);
            end

            cur_corr_info.best_corr = best_corr_inertion;
            cur_corr_info.best_rmse = best_rmse_inertion;
        end
        
        cur_corr_info.no_corr   = 0;
        corr_info.(varname) = cur_corr_info;
        
    end
end


