function [xq_data, p_sensor_name] = mc_read_xq (sensor_data_path)
    in_id = fopen (sensor_data_path);
    line = fgets (in_id);
    if (strcmp (line (1:4), 'Time') || ...
        line (5) == '.' || line (5) == '\')
        new_xq_format = true;
        fprintf ('mc_read_xq(): new XQ format detected\n');
    else
        new_xq_format = false;
        fprintf ('mc_read_xq(): old XQ format detected\n');
    end
    
    fclose (in_id);
    
    if (new_xq_format)
        xq_data = mc_read_xq_new_format (sensor_data_path);
    else
        xq_data = mc_read_xq_old_format (sensor_data_path);
    end
    
    for i_var = 1:numel (xq_data.Properties.VariableNames)
        cur_name = xq_data.Properties.VariableNames {i_var};
        xq_data.Properties.VariableNames {i_var} = ['XQ_', cur_name];
    end

    
    p_sensor_name = 'XQ_p'; 
    
    [~, ind] = sort (xq_data.time);
    xq_data = xq_data (ind, :);
    
    dt = seconds (1);
    t1 = xq_data.time (1);
    t2 = xq_data.time (end);
    
    xq_data = retime (xq_data, t1:dt:t2);    
end

