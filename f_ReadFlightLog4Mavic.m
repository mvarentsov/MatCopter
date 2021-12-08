function [data] = f_ReadFlightLog4Mavic (csv_path, time_belt, reload)

    mat_path = [csv_path, '.mat'];
    
    if (~reload)
        try 
            load (mat_path);
            fprintf ('f_ReadDJI_csv(): succesfully loaded from .mat file\n');
        catch exc
            reload = true;
        end
    end
    
    if (~reload)
       return;
    end
    
    in_id = fopen (csv_path);
    
    line = fgets (in_id);
        
       headers1 = strsplit (line, ';');
       headers2 = strsplit (line, ',');
        if (numel (headers1) > numel (headers2))
            headers = headers1;
            dlm = ';';
        else
            headers = headers2;
            dlm = ',';
        end
        if (numel (headers)) == 1
            error ('Wrong delimiter is used');
        end

        yaw_clmn = cell_find (headers, 'Yaw(360)');
        if (isempty (yaw_clmn))
            yaw_clmn = cell_find (headers, 'yaw360');
        end

        rel_h_clmn =  cell_find (headers, 'OSD.height');
        home_h_clmn = cell_find (headers, 'HOME.height');

        flight_time_clmn = cell_find (headers, 'flyTime');
        lon_clmn   =  cell_find (headers, 'longitude');
        lat_clmn   =  cell_find (headers, 'latitude');

        fly_state_clmn = cell_find (headers, 'flycState');
        is_sky_clmn = cell_find (headers, 'groundOrSky');
        
        gps_time_clmn = cell_find (headers, 'dateTimeStamp');


        if (isempty (rel_h_clmn))
            error (['No relativeHeight data found in ', csv_path])
        end

        %if (isempty (gps_time_clmn))
        %    error (['No GPS timestamp data found in ', csv_path])
        %end


        if (isempty (lon_clmn))
            error (['No Longitute data found in ', csv_path])
        end

        if (isempty (lat_clmn))
            error (['No Latitude data found in ', csv_path])
        end

        vel_n_clmn = cell_find (headers, 'Vel:N');
        if (isempty (vel_n_clmn))
            vel_n_clmn = cell_find (headers, 'velN');
        end

        vel_e_clmn = cell_find (headers, 'Vel:E');
        if (isempty (vel_e_clmn))
            vel_e_clmn = cell_find (headers, 'velE');
        end

        vel_h_clmn = cell_find (headers, 'Vel:H');
        if (isempty (vel_h_clmn))
            vel_h_clmn = cell_find (headers, 'velH');
        end

        vel_gps_h_clmn = cell_find (headers, 'Vel:GPS-H');

        airspeed_x_clmn = cell_find (headers, 'AirSpeedBody:X');
        if (isempty (airspeed_x_clmn))
            airspeed_x_clmn = cell_find (headers, 'air_vbx');
        end
        airspeed_y_clmn = cell_find (headers, 'AirSpeedBody:Y');
        if (isempty (airspeed_y_clmn))
            airspeed_y_clmn = cell_find (headers, 'air_vby');
        end

        wind_x_clmn = cell_find (headers, 'Wind:X');
        wind_y_clmn = cell_find (headers, 'Wind:Y');

        wind_e_clmn = cell_find (headers, 'WindE');
        wind_n_clmn = cell_find (headers, 'WindN');


        wind_clmn = cell_find (headers, 'WindSpeed');
        if (isempty (wind_clmn))
            wind_clmn = cell_find (headers, 'windSpeed');
        end

        windd_clmn = cell_find (headers, 'windDirection');

        ctrl_elv_clmn = cell_find (headers, 'Controller:Elevator');
        ctrl_rud_clmn = cell_find (headers, 'Controller:Rudder');
        ctrl_thr_clmn = cell_find (headers, 'Controller:Throttle');
        ctrl_aer_clmn = cell_find (headers, 'Controller:Aileron');
    
    N = numel (headers)+1;
    ask_str = '';
    for i = 1:N
        str = '%s ';
        ask_str = [ask_str, str];
    end
    
    C = textscan (in_id, ask_str, 'delimiter', dlm);
    
    
    data.flight_time = str2double (C {flight_time_clmn});
    data.date_num = datenum (C{1}(1), 'yyyy/mm/dd HH:MM:SS') + data.flight_time / (24 * 3600); 
    %%- time_belt / 24;
    
    data.vars.rel_height = str2double (C {rel_h_clmn});
    home_height = str2double (C {home_h_clmn});
    data.vars.abs_height = data.vars.rel_height + home_height;
    data.vars.lat        = str2double (C {lat_clmn});
    data.vars.lon        = str2double (C {lon_clmn});
    
    
    if (~isempty (fly_state_clmn))
        fly_state = C {fly_state_clmn};
        data.gohome_ind = find (ismember (fly_state, 'GoHome'));
        data.vars.is_atti = ismember (fly_state, 'Atti');
        data.vars.is_gps_atti = ismember (fly_state, 'GPS_Atti');
        if (isempty (data.gohome_ind))
            data.gohome_ind = nan;
        else
            data.gohome_ind = data.gohome_ind (1);
        end
    else
        data.gohome_ind = nan;
    end
    
    if (~isempty (is_sky_clmn))
        is_sky = C {is_sky_clmn};
        data.vars.is_flight = ismember (is_sky, 'Sky');
    else
        data.vars.is_flight = nan (size (data.vars.lat));
    end
    
    if (~isempty (wind_x_clmn))
        data.vars.wind_x = str2double (C {wind_x_clmn});
    else
        data.vars.wind_x = nan (size (data.vars.lat));
    end

    if (~isempty (wind_y_clmn))
        data.vars.wind_y     = str2double (C {wind_y_clmn});
    else
        data.vars.wind_y = nan (size (data.vars.lat));
    end
    
    if (~isempty (wind_e_clmn))
        data.vars.wind_e = str2double (C {wind_e_clmn});
    else
        data.vars.wind_e = nan (size (data.vars.lat));
    end

    if (~isempty (wind_n_clmn))
        data.vars.wind_n     = str2double (C {wind_n_clmn});
    else
        data.vars.wind_n = nan (size (data.vars.lat));
    end

    if (~isempty (wind_clmn))
        data.vars.wind     = str2double (C {wind_clmn});
    else
        data.vars.wind = nan (size (data.vars.lat));
    end
    
    if (~isempty (windd_clmn))
        data.vars.windd     = str2double (C {windd_clmn});
    else
        data.vars.windd = nan (size (data.vars.lat));
    end
    
    if (~isempty (ctrl_elv_clmn))
        data.vars.ctrl_elv     = str2double (C {ctrl_elv_clmn});
    else
        data.vars.ctrl_elv = nan (size (data.vars.lat));
    end
    
    if (~isempty (ctrl_rud_clmn))
        data.vars.ctrl_rud     = str2double (C {ctrl_rud_clmn});
    else
        data.vars.ctrl_rud = nan (size (data.vars.lat));
    end
    
    if (~isempty (ctrl_thr_clmn))
        data.vars.ctrl_thr     = str2double (C {ctrl_thr_clmn});
    else
        data.vars.ctrl_thr = nan (size (data.vars.lat));
    end
    
    if (~isempty (ctrl_elv_clmn))
        data.vars.ctrl_elv     = str2double (C {ctrl_elv_clmn});
    else
        data.vars.ctrl_elv = nan (size (data.vars.lat));
    end
    
    if (~isempty (ctrl_aer_clmn))
        data.vars.ctrl_aer     = str2double (C {ctrl_aer_clmn});
    else
        data.vars.ctrl_aer = nan (size (data.vars.lat));
    end
    
    if (~isempty (vel_n_clmn))
        data.vars.vel_n = str2double (C {vel_n_clmn});
    else
        data.vars.vel_n = nan (size (data.vars.lat));
    end
    
    if (~isempty (vel_e_clmn))
        data.vars.vel_e = str2double (C {vel_e_clmn});
    else
        data.vars.vel_e = nan (size (data.vars.lat));
    end
    
    if (~isempty (vel_h_clmn))
        data.vars.vel_h = str2double (C {vel_h_clmn});
    else
        data.vars.vel_h = nan (size (data.vars.lat));
    end
    
    if (~isempty (vel_gps_h_clmn))
        data.vars.vel_gps_h = str2double (C {vel_gps_h_clmn});
    else
        data.vars.vel_gls_h = nan (size (data.vars.lat));
    end
    
    if (~isempty (airspeed_x_clmn))
        data.vars.airspeed_x = str2double (C {airspeed_x_clmn});
    else
        data.vars.airspeed_x = nan (size (data.vars.lat));
    end
    
    if (~isempty (airspeed_y_clmn))
        data.vars.airspeed_y = str2double (C {airspeed_y_clmn});
    else
        data.vars.airspeed_y = nan (size (data.vars.lat));
    end
    
    if (~isempty (yaw_clmn))
        data.vars.yaw = str2double (C {yaw_clmn});
    else
        data.vars.yaw = nan (size (data.vars.lat));
    end

%     if (nargin > 3)
%         flight_ind = find (data.vars.rel_height > min_rel_h);
%         data.flight_start_ind = flight_ind (1);
%         data.flight_end_ind = flight_ind (end);
%     else
%         data.flight_start_ind = nan;
%         data.flight_end_ind = nan;
%     
%         for i = 2:numel (data.flight_time)
%             if (isnan (data.flight_start_ind) && data.flight_time (i) > data.flight_time (i - 1) && data.vars.rel_height (i) > 0)
%                 data.flight_start_ind = i;
%             elseif (~isnan (data.flight_start_ind) && data.flight_time (i) == data.flight_time (end))
%                 data.flight_end_ind = i;
%                 break;
%             end
%         end
%     end

    is_sky_ind = find (data.vars.is_flight);
    data.flight_start_ind = is_sky_ind (1);
    data.flight_end_ind   = is_sky_ind (end);
    
    if (~isnan (data.gohome_ind))
        data.gohome_time =  data.date_num (data.gohome_ind);
    else
        data.gohome_time = nan;
    end
    
    data.flight_start_time  = data.date_num (data.flight_start_ind);
    data.flight_end_time = data.date_num (data.flight_end_ind);
    data.flight_ind = data.flight_start_ind : data.flight_end_ind - 1;
    
    first_flight_height = data.vars.rel_height (data.flight_start_ind);
    last_flight_height  = data.vars.rel_height (data.flight_end_ind - 1);
    
    corr = linspace (first_flight_height, last_flight_height, numel (data.flight_ind))';
    
    data.vars.rel_height_corr = data.vars.rel_height;
    data.vars.rel_height_corr (data.flight_ind) = data.vars.rel_height_corr (data.flight_ind) - corr;
    
    str1 = datestr (data.date_num (1));
    str2 = datestr (data.date_num (end));
    
    fprintf ('f_ReadDJI_csv(): DJI time range: %s - %s\n', str1, str2);
    fprintf ('f_ReadDJI_csv(): height corr: %.1f\n', last_flight_height);
    
    save (mat_path, 'data');

    function res = cell_find (headers, str)
        find_res = strfind (headers, str);
        res = zeros (0);
        for i_h = 1:numel (find_res)
            cur_res = find_res {i_h};
            if (~isempty (cur_res))
                res = i_h;
                break
            end
        end
    end
end


