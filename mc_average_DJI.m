function [dji_data_ave] = mc_average_DJI (dji_data, time_step)
    dji_varnames = dji_data.vars.Properties.VariableNames;
    
    compass_vars = cell (0);
    cart_vars = cell (0);
    
    
    for i_var = 1:numel (dji_varnames)
        cur_var = dji_varnames {i_var};
        if (~isnumeric (dji_data.vars.(cur_var)))
            dji_data.vars.(cur_var) = double (dji_data.vars.(cur_var));
        end
        if (strcmp (cur_var, 'yaw') || ~isempty (strfind (cur_var, 'windd')))
            [u_var, v_var, vel_var] = mc_cart_varnames (cur_var);
            compass_vars = [compass_vars; cur_var];
            
            if (~ismember (vel_var, dji_varnames))
                vel_data = dji_data.vars.(vel_var);
            else
                vel_data = ones (size (dji_data.vars.(cur_var)));
            end

            dji_data.vars.(cur_var) (dji_data.vars.(cur_var) < 0) = dji_data.vars.(cur_var) (dji_data.vars.(cur_var) < 0) + 360;
            
            [dji_data.vars.(u_var), dji_data.vars.(v_var)] = ...
                compass2cart_my (dji_data.vars.(cur_var), -vel_data);
        end
    end
    
     t1 = dateshift (dji_data.vars.time (1),  'start', 'second');
     t2 = dateshift (dji_data.vars.time (end), 'end', 'second');
     
     dji_data_ave = dji_data;
     
     dji_data_ave.vars = retime (dji_data.vars, t1:time_step:t2, 'mean');
     
     for i_var = 1:numel (compass_vars)
        cur_var = compass_vars {i_var};
        [u_var, v_var] = mc_cart_varnames (cur_var);
        dji_data_ave.vars.(cur_var) = cart2compass_my (-dji_data_ave.vars.(u_var), -dji_data_ave.vars.(v_var));
        dji_data_ave.vars.(u_var) = [];
        dji_data_ave.vars.(v_var) = [];
     end

     
    [~, dji_data_ave.flight_start_ind] = min (abs (dji_data_ave.vars.time - dji_data.flight_start_time));
    [~, dji_data_ave.flight_end_ind]   = min (abs (dji_data_ave.vars.time - dji_data.flight_end_time));

    if (~isnan (dji_data.gohome_ind))
        [~, dji_data_ave.gohome_ind]       = min (abs (dji_data_ave.vars.time - dji_data.gohome_time));
    else
        dji_data_ave.gohome_ind = nan;
    end

    dji_data_ave.flight_start_time = dji_data_ave.vars.time (dji_data_ave.flight_start_ind);
    dji_data_ave.flight_end_time   = dji_data_ave.vars.time (dji_data_ave.flight_end_ind);
end

