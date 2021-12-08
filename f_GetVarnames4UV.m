function [u_varname, v_varname] = f_GetVarnames4UV (wind_dir_varname)
    if (strcmp (wind_dir_varname, 'est_windd'))
        u_varname = 'est_wind_u';
        v_varname = 'est_wind_v';
    elseif (strcmp (wind_dir_varname, 'imu_windd'))
        u_varname = 'imu_wind_u';
        v_varname = 'imu_wind_v';
    elseif (strcmp (wind_dir_varname, 'yaw'))
        u_varname = 'yaw_u';
        v_varname = 'yaw_v';
    end

end

