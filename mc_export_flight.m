function mc_export_flight (data, export_dir)

    try 
        export_dir;
    catch
        export_dir = fileparts (data.info.sensor_data_path);
        export_dir = [export_dir, '\processed_flights\'];
        mkdir (export_dir);
    end

    out = table ();
    out.time = datetime (data.date_num (data.flight_ind), 'ConvertFrom', 'datenum');

    snames = fieldnames (data);
    for i_s = 1:numel (snames)
        sname = snames {i_s};
        if (~isstruct (data.(sname)))
            continue;
        end
        
        varnames = fieldnames (data.(sname));
        [varnames, sort_ind] = sort (varnames);
        for i_v = 1:numel (varnames)
            varname = varnames {i_v};
            if (~strcmp (varname, 'date_num') && ~strcmp (varname, 'date_vec') && ...
                length (data.(sname).(varname)) == length (data.date_num) && ...
                numel (find (~isnan (data.(sname).(varname)))) > 0)
                tab_name = [sname, '_', varname];
                out.(tab_name) = data.(sname).(varname) (data.flight_ind);
            end
        end
    end
    filename = [data.info.mean_time_str4file, ' ', data.info.fly_str, '.csv'];
    writetable (out, [export_dir, '\', filename], 'delimiter', ';');
end