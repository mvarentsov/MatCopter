function data = mc_read_flightlog_AirData(csv_path, reload)

    data_tab = readtable (csv_path);
    data_tab.flycStateRaw = [];
    headers = data_tab.Properties.VariableNames;

    var_headers.yaw         = {'compass_heading'};
    var_headers.alti        = {'altitude_above_seaLevel'};
    var_headers.rel_height  = {'height_above_takeoff'};
    var_headers.abs_height  = {'altitude_above_seaLevel'};
    var_headers.flight_time = {}; %'time'};
    var_headers.lon         = {'longitude'};
    var_headers.lat         = {'latitude'};
    var_headers.fly_state_raw   = {'flycStateRaw'}; 
    var_headers.fly_state   = {'flycState'}; 
    var_headers.gps_time    = {'datetime'};
    var_headers.vel_n       = {'ySpeed'};
    var_headers.vel_e       = {'xSpeed'};
    var_headers.vel_h       = {'speed'};
    var_headers.vel_gps_h   = {};
    var_headers.airspeed_x  = {}; %'AirSpeedBody:X', 'air_vbx'};
    var_headers.airspeed_y  = {}; %'AirSpeedBody:Y', 'air_vby'};
    var_headers.wind_x      = {}; %'Wind:X'};
    var_headers.wind_y      = {}; %'Wind:Y'};
    var_headers.wind_n      = {}; %'WindN'};
    var_headers.wind_e      = {}; %'WindE'};
    var_headers.winds       = {}; %'WindSpeed', 'windSpeed'};
    var_headers.windd       = {}; % 'windDirection'};
    var_headers.ctrl_elev   = {'rc_elevator'};
    var_headers.ctrl_rud    = {'rc_rudder'};
    var_headers.ctrl_thr    = {'rc_throttle'};
    var_headers.ctrl_aer    = {'rc_aileron'};
    var_headers.attribute   = {}; %Attribute'};
    
    var_headers_txt      = {'gps_time', 'fly_state', 'attribute'};
    var_headers_critical = {'gps_time', 'lon', 'lat', 'rel_height', 'fly_state'};
    
    varnames = fieldnames (var_headers);
    for i_v = 1:numel (varnames)
        cur_ind = [];
        cur_keys = var_headers.(varnames {i_v});
        for i_key = 1:numel (cur_keys)
            cur_ind = cell_find (headers, cur_keys {i_key});
            if (~isempty (cur_ind))
                break;
            end
        end
        if (isempty (cur_ind))
             fprintf ('%s%s<- []\n', varnames {i_v}, repmat (' ', 1, 20 - length (varnames {i_v})));
             if (ismember (varnames {i_v}, var_headers_critical))
                error (sprintf ('Critical variable %s is not found in %s', varnames {i_v}, csv_path));
             end
        else
             fprintf ('%s%s<- %s\n', varnames {i_v}, repmat (' ', 1, 20 - length (varnames {i_v})), headers {cur_ind});
        end
        var_clnm_ind.(varnames {i_v}) = cur_ind;
    end


    data.vars.offset = data_tab.time_millisecond_;

    for i_v = 1:numel (varnames)
        if (~ismember (varnames {i_v}, var_headers_txt))
            if (~isempty (var_clnm_ind.(varnames {i_v})))
                data.vars.(varnames {i_v}) = table2array (data_tab(:, var_clnm_ind.(varnames {i_v})));
            else
                data.vars.(varnames {i_v}) = nan (size (data.vars.offset));
            end
        else
            if (~isempty (var_clnm_ind.(varnames {i_v})))
                txt_vars.(varnames {i_v}) = table2array (data_tab(:, var_clnm_ind.(varnames {i_v})));;
            else
                txt_vars.(varnames {i_v}) = [];
            end
        end
    end
    
    if (isdatetime (txt_vars.gps_time(1)))
        data.vars.time = txt_vars.gps_time;
    else
        error ('this case is not supported yet');
    end

    data.vars = struct2table (data.vars);
    data.vars = table2timetable (data.vars);

    data.info.drone_model = '';

    if (~isempty (var_clnm_ind.fly_state))
        data.gohome_ind = find (ismember (txt_vars.fly_state, 'Go_Home'));
        data.vars.is_atti = ismember (txt_vars.fly_state, 'Atti');
        takeoff_ind1 = find (ismember (txt_vars.fly_state, 'Assisted_Takeoff')); 
        takeoff_ind2 = find (ismember (txt_vars.fly_state, 'AutoTakeoff'));

        landing_ind = find (ismember (txt_vars.fly_state, 'Confirm_Landing'));        
        if (isempty (landing_ind))
            landing_ind = numel (txt_vars.fly_state);
        end
        
        if (~isempty (takeoff_ind1) && isempty (takeoff_ind2))
            data.flight_start_ind = takeoff_ind1(1)+1;
        elseif (isempty (takeoff_ind1) && ~isempty (takeoff_ind2))
            data.flight_start_ind = takeoff_ind2(1)+1;
        else
            error ('this condition is not supported yet');
        end
        
        data.flight_end_ind   = landing_ind(1)-1;

        if (isempty (data.gohome_ind))
            data.gohome_ind = nan;
        else
            data.gohome_ind = data.gohome_ind (1);
        end
    else
        data.gohome_ind = nan;
    end

    if (~isnan (data.gohome_ind))
        data.gohome_time =  data.vars.time (data.gohome_ind);
    else
        data.gohome_time = nan;
    end

    data.vars.rel_height = data.vars.rel_height * 0.3048;
    data.vars.abs_height = data.vars.abs_height * 0.3048;
    data.vars.alti       = data.vars.alti * 0.3048;
    

    data.flight_start_time  = data.vars.time (data.flight_start_ind);
    data.flight_end_time = data.vars.time (data.flight_end_ind);
    data.flight_ind = data.flight_start_ind : data.flight_end_ind - 1;
    
    first_flight_height = data.vars.rel_height (data.flight_start_ind);
    last_flight_height  = data.vars.rel_height (data.flight_end_ind - 1);
    
    corr = linspace (first_flight_height, last_flight_height, numel (data.flight_ind))';
    
    data.vars.rel_height_corr = data.vars.rel_height;
    data.vars.rel_height_corr (data.flight_ind) = data.vars.rel_height_corr (data.flight_ind) - corr;
    
    
    function res = cell_find (headers, str)
        find_res = strfind (lower (headers), lower (str));
        %find_res = strfind (headers, str);
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