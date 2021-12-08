function mc_export_vprofiles (pr, export_dir)
    try 
        export_dir;
    catch
        export_dir = fileparts (pr.info.sensor_data_path);
        export_dir = [export_dir, '\processed_profiles\'];
        mkdir (export_dir);
    end
    
    
    out = table;
    out.z = pr.asc.z_levels2draw;
    
    snames = fieldnames (pr.asc);
    for i_s = 1:numel (snames)
        sname = snames {i_s};
        if (~isstruct (pr.asc.(sname)))
            continue;
        end
        varnames = fieldnames (pr.asc.(sname));
        for i_v = 1:numel (varnames)
            varname = varnames {i_v};
            out.([varname, '_asc']) = pr.asc.(sname).(varname);
            out.([varname, '_dsc']) = pr.dsc.(sname).(varname);
        end
    end
    
    filename = [pr.info.mean_time_str4file, ' ', pr.info.fly_str, ' ', pr.info.var2zcrd, '.csv'];
    writetable (out, [export_dir, '\', filename], 'delimiter', ';');
end
