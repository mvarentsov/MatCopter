function mc_export_vprofiles (pr, export_dir)
    
    assert (isstruct (pr) && isfield (pr, 'asc') && isfield (pr, 'dsc') && ...
            istable (pr.asc) && istable (pr.dsc), 'pr should have asc and dsc fields')

    try 
        export_dir;
    catch
        export_dir = fileparts (pr.info.sensor_data_path);
        export_dir = [export_dir, '\processed_profiles\'];
        mkdir (export_dir);
    end
    
    pr.mean = mc_average_asc_and_dsc_segments (pr.asc, pr.dsc, nan);

    out = table;
    out.z = pr.asc.z;
    
    varnames = pr.asc.Properties.VariableNames;

    for i_v = 1:numel (varnames)
        varname = varnames {i_v};
        if (strcmp (varname, 'z'))
            continue;
        end
        out.([varname, '_asc'])  = pr.asc.(varname);
        out.([varname, '_dsc'])  = pr.dsc.(varname);
        out.([varname, '_mean']) = pr.mean.(varname);
    end
    
    filename_csv = [pr.info.mean_time_str4file, ' ', pr.info.fly_str, ' ', pr.info.z_var, '.csv'];
    filename_mat = [pr.info.mean_time_str4file, ' ', pr.info.fly_str, ' ', pr.info.z_var, '.mat'];
    
    writetable (out, [export_dir, '\', filename_csv], 'delimiter', ';');
    save ([export_dir, '\', filename_mat], 'pr');
end
