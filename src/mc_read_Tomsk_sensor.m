function [data, p_sensor_name] = f_read_Tomsk_sensor (sensor_data_path)

    data = readtable (sensor_data_path); 
    data.Properties.VariableNames = {'time', 'sens_t', 'sens_rh', 'sens_p'};
    data = table2timetable (data);
    data = retime (data, "secondly", @nanmean);
    p_sensor_name = 'sens_p';