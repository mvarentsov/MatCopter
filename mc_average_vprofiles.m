function [pr_mean, pr] = mc_average_vprofiles (pr, weights)

    try
        weights;
    catch
        weights = ones (size (pr));
    end
    
    for i_pr = 1:numel (pr)
        if (~isequal (pr(i_pr).asc.z_levels2draw, pr(1).asc.z_levels2draw) || ...
            ~isequal (pr(i_pr).dsc.z_levels2draw, pr(1).dsc.z_levels2draw))
            error ('different z_levels are used');
        end
    end
    
    if (isfield (pr(1).asc, pr(1).info.pressure_var) && isfield (pr(1).asc.(pr(1).info.pressure_var), 'p'))
        pr = mc_equalize_pressure4vprofiles (pr);
    end

    pr_mean = pr (1);
    
    % Remove information remaining from equalizing_pressure in order to
    % allow concentrating original and averaged profiles
    if (isfield (pr_mean, 'p_corr'))
        pr_mean = rmfield (pr_mean, 'p_corr');
        pr_mean = rmfield (pr_mean, 'mean_p');
    end
    
    varnames = pr_mean.asc.Properties.VariableNames;
    for i_v = 1:numel (varnames)
        cur_varname = varnames {i_v};
        if (~isempty (strfind (cur_varname, 'windd')))
            error ('Wind direction is not supported yet');
        end
        if (strcmp (cur_varname, 'z_levels2draw'))
            continue;
        end
        pr_mean.asc.(cur_varname) = pr(1).asc.(cur_varname) * weights(1);
        pr_mean.dsc.(cur_varname) = pr(1).dsc.(cur_varname) * weights(1);
    end
    
    for i = 2:numel (pr)
        varnames = pr_mean.asc.Properties.VariableNames;
        for i_v = 1:numel (varnames)
            cur_varname = varnames {i_v};
            if (strcmp (cur_varname, 'z_levels2draw'))
                continue;
            end
            pr_mean.asc.(cur_varname) = pr_mean.asc.(cur_varname) + ...
                                          pr(i).asc.(cur_varname) * weights(i);
            pr_mean.dsc.(cur_varname) = pr_mean.dsc.(cur_varname) + ...
                                          pr(i).dsc.(cur_varname) * weights(i);
        end
        if (isfield (pr_mean, 'legend_str'))
            pr_mean.legend_str = strcat (pr_mean.legend_str, ' + ', pr(i).legend_str);
        end
    end
    
    varnames = pr_mean.asc.Properties.VariableNames;
    for i_v = 1:numel (varnames)
        cur_varname = varnames {i_v};
        if (strcmp (cur_varname, 'z_levels2draw'))
            continue;
        end
        pr_mean.asc.(cur_varname) = pr_mean.asc.(cur_varname) / sum (weights);
        pr_mean.dsc.(cur_varname) = pr_mean.dsc.(cur_varname) / sum (weights);
    end

    pr_mean.flight_mean_time  = mean ([pr(:).flight_mean_time]);
    pr_mean.flight_start_time = min ([pr(:).flight_start_time]);
    pr_mean.flight_end_time   = max ([pr(:).flight_end_time]);
    
    pr_mean.info.mean_time_str      = datestr (pr_mean.flight_mean_time, 'dd.mm.yyyy HH:MM');
    pr_mean.info.mean_time_str4file = datestr (pr_mean.flight_mean_time, 'yyyymmddHHMM');
    
    pr_mean.info.t1_str      = datestr (pr_mean.flight_start_time, 'dd.mm.yyyy HH:MM');
    pr_mean.info.t2_str      = datestr (pr_mean.flight_end_time,   'dd.mm.yyyy HH:MM');

    
end

