function [sens_data, dji_data] = mc_load_flight (sensor_data_path, read_sensor_func, read_dji_func, reload_dji, correct_time_shift, dji_path)

    try 
        read_dji_func;
    catch exc
        read_dji_func = [];
    end

    use_DJI = isa(read_dji_func,'function_handle');

    if (use_DJI)
    
        try 
            correct_time_shift;
        catch exc
            correct_time_shift = true;
        end
        
        try 
            reload_dji;
        catch exc
            reload_dji = false;
        end

        try
            dji_path;
            fly_str = '';
        catch exc
            [dji_path, fly_str] = mc_default_DJI_path (sensor_data_path);
        end

        if (isempty (dji_path))
            [dji_path, fly_str] = f_DefaultDJIPath (sensor_data_path);
        end
    else
        dji_path = [];
    end
    
    [sens_data.vars, sens_data.info.pressure_var] = read_sensor_func (sensor_data_path);
     
    if (use_DJI)
        if (ischar (dji_path))
            dji_data = read_dji_func (dji_path, reload_dji); 
        else
            dji_data = dji_path;
        end
        
        
        if (max (dji_data.vars.time) < datetime (2016, 1, 1, 0, 0, 0))
            error ('Wrong time in DJI data');
            %diff = f_GetTopPointTimeShift (sens_data.date_num, sens_data.(sens_data.info.p_sensor_name).p, dji_data.date_num, dji_data.vars.rel_height);
            %dji_data.date_num = dji_data.date_num - diff;
            %dji_data.flight_start_time = dji_data.flight_start_time - diff;
            %dji_data.flight_end_time   = dji_data.flight_end_time - diff;
        end
        
        dji_data_ave = mc_average_DJI (dji_data, seconds (1));

        
        if (correct_time_shift)

            data_time_range = [min(dji_data_ave.vars.time), max(dji_data_ave.vars.time)];
            dji_time_range  = [min(sens_data.vars.time), max(sens_data.vars.time)];
            
            fprintf ('dji time range:  %s - %s\n', datestr (min(dji_data_ave.vars.time)), datestr (max(dji_data_ave.vars.time)))
            fprintf ('data time range: %s - %s\n', datestr (min(sens_data.vars.time)),    datestr (max(sens_data.vars.time)))

            if (dji_time_range (2) < data_time_range (1) || dji_time_range (1) >  data_time_range (2))
                warning ('time ranges do not intersect, try to apply correction');
                diff = dji_time_range (2) - data_time_range (2);
                display(diff);
                dji_data_ave.vars.time = dji_data_ave.vars.time + diff;
                dji_data_ave.flight_start_time = dji_data_ave.flight_start_time + diff;
                dji_data_ave.flight_end_time   = dji_data_ave.flight_end_time + diff;
            end

            [best_dt, best_dt_asc, best_dt_w] = mc_correct_time_shift (dji_data_ave, sens_data.vars.time, sens_data.vars.(sens_data.info.pressure_var));
            % ����� ����� �������� ������ ��������� ���������� ������ 
            % best_dt_w, best_dt_asc � ������� best_dt)
            best_dt = best_dt; %best_dt_w;
        else
            best_dt = 0;
        end
        
        dji_data_ave.vars.time = dji_data_ave.vars.time + best_dt;
        dji_data_ave.gohome_time       = dji_data_ave.gohome_time       + best_dt; 
        
        dji_data_ave.flight_start_time_old = dji_data_ave.flight_start_time + best_dt;
        dji_data_ave.flight_end_time_old   = dji_data_ave.flight_end_time   + best_dt;
        
        % Updating flight index
        flight_ind_new = find (dji_data_ave.vars.time > dji_data_ave.flight_start_time_old & ...
                               dji_data_ave.vars.time < dji_data_ave.flight_end_time_old & ...
                               dji_data_ave.vars.rel_height > 0.5);
                              
        dji_data_ave.flight_start_time = dji_data_ave.vars.time (flight_ind_new (1));
        dji_data_ave.flight_end_time   = dji_data_ave.vars.time (flight_ind_new (end));
        
        
        DELTA_T = minutes (1);
        
        sens_data.vars = sens_data.vars (sens_data.vars.time >= dji_data_ave.flight_start_time - DELTA_T & ...
                                         sens_data.vars.time <= dji_data_ave.flight_end_time + DELTA_T, :);
        
        for i_var = 1:numel (dji_data_ave.vars.Properties.VariableNames)
            cur_name = dji_data_ave.vars.Properties.VariableNames {i_var};
            dji_data_ave.vars.Properties.VariableNames {i_var} = ['DJI_', cur_name];
        end
        
        sens_data.vars = synchronize (sens_data.vars, dji_data_ave.vars);
        dji_info_vars = fieldnames (dji_data_ave.info);
        for i_v = 1:numel (dji_info_vars)
            sens_data.info.(dji_info_vars{i_v}) = dji_data_ave.info.(dji_info_vars{i_v});
        end
        
        [~, sens_data.flight_start_ind] = min (abs (sens_data.vars.time - (dji_data_ave.flight_start_time)));
        [~, sens_data.flight_end_ind]   = min (abs (sens_data.vars.time - (dji_data_ave.flight_end_time)));
        sens_data.info.fly_str = fly_str;
        try
            sens_data.info.drone_model;
        catch
            sens_data.info.drone_model = '';
        end
        sens_data.info.is_P4PV2 = strcmp (sens_data.info.drone_model, 'P4PV2');
    else
        [sens_data.flight_start_ind, sens_data.flight_end_ind] = mc_find_flight_start_and_end_idx_by_pressure (sens_data.vars.time, sens_data.vars.(sens_data.info.pressure_var));
        sens_data.info.fly_str = '';
    end
    
    sens_data.vars.(sens_data.info.pressure_var) = mc_correct_pressure (sens_data.vars.(sens_data.info.pressure_var), sens_data.flight_start_ind, sens_data.flight_end_ind);
    
    if (use_DJI && ~isnan (dji_data.gohome_ind))
        [~, sens_data.gohome_ind] = min (abs (sens_data.vars.time - dji_data_ave.gohome_time));
        sens_data.gohome_time = sens_data.vars.time (sens_data.gohome_ind);
    else
        sens_data.gohome_ind = nan;
        sens_data.gohome_time = NaT;
    end

    sens_data.flight_start_time = sens_data.vars.time (sens_data.flight_start_ind);
    sens_data.flight_end_time   = sens_data.vars.time (sens_data.flight_end_ind);
    sens_data.flight_ind =  sens_data.flight_start_ind : sens_data.flight_end_ind;

    sens_data.info.sensor_data_path = sensor_data_path;

    sens_data.info.flight_log_path  = dji_path;
    
    sens_data.info.mean_time = mean (sens_data.vars.time (sens_data.flight_ind));
    
    sens_data.info.mean_time_str      = datestr (sens_data.info.mean_time, 'dd.mm.yyyy HH:MM');
    sens_data.info.mean_time_str4file = datestr (sens_data.info.mean_time, 'yyyymmdd_HHMM');
    
    sens_data.info.t1_str      = datestr (sens_data.flight_start_time, 'dd.mm.yyyy HH:MM');
    sens_data.info.t2_str      = datestr (sens_data.flight_end_time,   'dd.mm.yyyy HH:MM');
end