function mc_export_flight (data, export_dir)

    try 
        export_dir;
    catch
        export_dir = fileparts (data.info.sensor_data_path);
        export_dir = [export_dir, '\processed_flights\'];
        mkdir (export_dir);
    end

    filename = [data.info.mean_time_str4file, ' ', data.info.fly_str, '.csv'];
    writetimetable (data.vars(data.flight_ind, :), [export_dir, '\', filename], 'delimiter', ';');
end