function [pr_mean, pr_min, pr_max, west_cutoff] = mc_average_asc_and_dsc_segments (pr_asc, pr_dsc, WEST_WIND_CORR)
    try
        WEST_WIND_CORR;
    catch exc
        WEST_WIND_CORR = nan;
    end
    
    varnames_asc = pr_asc.Properties.VariableNames;
    varnames_dsc = pr_dsc.Properties.VariableNames;

    assert (isequal (varnames_asc, varnames_dsc), 'asc and dsc profiles should have equal set of variables');
    assert (isequal (pr_asc.z, pr_dsc.z), 'z levels for asc and dsc profiles should be equal');
    
    pr_mean = table;
    pr_min  = table;
    pr_max  = table;

    pr_mean.z = pr_asc.z;
    pr_min.z  = pr_asc.z;
    pr_max.z  = pr_asc.z;

    extra_vars = {};

    for i_var = 1:numel (varnames_asc)
        cur_var = varnames_asc {i_var};
        if (contains (cur_var, 'winds') && contains (cur_var, '_u'))
            extra_var = strrep (strrep (cur_var, 'winds', 'windd'), '_u', '');
            extra_vars = [extra_vars, extra_var];  
        end
    end

    varnames = [varnames_asc, extra_vars];

    for i_var = 1:numel (varnames)
        cur_var = varnames {i_var};
        if (strcmp (cur_var, 'z'))
            continue;
        end

        [pr_mean.(cur_var), cur_val, west_cutoff.(cur_var)] = mc_profiles2draw (pr_asc, pr_dsc, cur_var, WEST_WIND_CORR);
        pr_min.(cur_var) = min (cur_val, [], 2);
        pr_max.(cur_var) = max (cur_val, [], 2);
    end
    
    
end