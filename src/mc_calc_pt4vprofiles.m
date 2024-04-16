function profiles = mc_calc_pt4vprofiles (profiles, t_varnames, p_varnames)

    try
        p_varnames;
    catch
        p_varnames = [];
    end

    if (~iscell (t_varnames))
        t_varnames = {t_varnames};
    end

    profiles = mc_equalize_pressure4vprofiles (profiles, p_varnames);
    for i_pr = 1:numel (profiles)
        for i_var = 1:numel (t_varnames)
            t_varname = t_varnames {i_var};
            if (~isempty (p_varnames))
                p_varname = p_varnames {i_var};
            else
                p_varname = profiles(i_pr).info.pressure_var;
            end
            
            pt_varname = strrep (t_varname, '_t', '_pt');
            if (ismember (t_varname, profiles(i_pr).asc.Properties.VariableNames))
                profiles(i_pr).asc.(pt_varname) = mc_calc_pt (profiles(i_pr).asc.(p_varname), ...
                                                              profiles(i_pr).asc.(t_varname));
                profiles(i_pr).dsc.(pt_varname) = mc_calc_pt (profiles(i_pr).dsc.(p_varname), ...
                                                              profiles(i_pr).dsc.(t_varname));

                profiles(i_pr).corr_info.(pt_varname) = profiles(i_pr).corr_info.(t_varname);
                profiles(i_pr).corr_str.(pt_varname)  = profiles(i_pr).corr_str.(t_varname);
            end
        end
    end
end