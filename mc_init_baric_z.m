function [sensor_data] = mc_init_baric_z (sensor_data, t_varname, t_inertion_corr, p_sensor_name)
    
    %t_varname = 't';
    try
        p_sensor_name;
    catch    
        p_sensor_name = sensor_data.info.pressure_var;
    end
    
    if (~ismember (t_varname, sensor_data.vars.Properties.VariableNames))
        warning ([t_varname, ' not availible']);
        return;
    end
    
    sensor_data.vars.([t_varname, '_corr']) = mc_apply_inertion_corr (sensor_data.vars.(t_varname), t_inertion_corr);
    
    baric_model   = mc_create_baric_model (sensor_data, sensor_data.flight_ind, [t_varname, '_corr']);

    baric_z_var = strrep (p_sensor_name, 'p', 'baric_z');

	sensor_data.vars.(baric_z_var) = mc_apply_baric_model (sensor_data.vars.(p_sensor_name), baric_model, sensor_data.flight_start_ind, sensor_data.flight_end_ind); 

    [~, ind] = sort (sensor_data.vars.Properties.VariableNames);
    sensor_data.vars = sensor_data.vars(:, ind);

end

