function [data] = mc_read_flightlog_phantom (csv_path, reload)
    
    mat_path = [csv_path, '_tt.mat'];
    
    if (~reload)
        try 
            load (mat_path);
            fprintf ('mc_read_flightlog_phantom(): succesfully loaded from .mat file\n');
        catch exc
            reload = true;
        end
    end
    
    if (~reload)
       return;
    end
        
    in_id = fopen (csv_path);
    if (in_id == -1)
        error (['file not found: ', csv_path]);
    end
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
    
    var_headers.yaw         = {'Yaw(360)', 'yaw360'};
    var_headers.alti        = {'alti:D'};
    var_headers.rel_height  = {'relativeHeight'};
    var_headers.abs_height  = {'absoluteHeight'};
    var_headers.flight_time = {'flightTime'};
    var_headers.lon         = {'Longitude'};
    var_headers.lat         = {'Latitude'};
    var_headers.fly_state   = {'flyCState'}; 
    var_headers.gps_time    = {'dateTimeStamp'};
    var_headers.vel_n       = {'Vel:N', 'velN'};
    var_headers.vel_e       = {'Vel:E', 'velE'};
    var_headers.vel_h       = {'Vel:H', 'velH'};
    var_headers.vel_gps_h   = {'Vel:GPS-H'};
    var_headers.airspeed_x  = {'AirSpeedBody:X', 'air_vbx'};
    var_headers.airspeed_y  = {'AirSpeedBody:Y', 'air_vby'};
    var_headers.wind_x      = {'Wind:X'};
    var_headers.wind_y      = {'Wind:Y'};
    var_headers.wind_n      = {'WindN'};
    var_headers.wind_e      = {'WindE'};
    var_headers.winds       = {'WindSpeed', 'windSpeed'};
    var_headers.windd       = {'windDirection'};
    var_headers.ctrl_elev   = {'Controller:Elevator', 'Controller:ctrl_pitch:D'};
    var_headers.ctrl_rud    = {'Controller:Rudder', 'Controller:ctrl_yaw:D'};
    var_headers.ctrl_thr    = {'Controller:Throttle', 'Controller:ctrl_thr:D'};
    var_headers.ctrl_aer    = {'Controller:Aileron', 'Controller:ctrl_roll:D'};
    var_headers.attribute   = {'Attribute'};
    
    var_headers_txt      = {'gps_time', 'fly_state', 'attribute'};
    var_headers_critical = {'gps_time', 'lon', 'lat', 'rel_height'};
    
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
    
    N = numel (headers)+1;
    ask_str = '';
    for i = 1:N
        str = '%s ';
        ask_str = [ask_str, str];
    end
    
    C = textscan (in_id, ask_str, 'delimiter', dlm);
    
    
    data.vars.offset = str2double (C {2});
    %data.vars.offset_time = data.offset_time - data.offset_time (1);
    
    for i_v = 1:numel (varnames)
        if (~ismember (varnames {i_v}, var_headers_txt))
            if (~isempty (var_clnm_ind.(varnames {i_v})))
                data.vars.(varnames {i_v}) = str2double (C {var_clnm_ind.(varnames {i_v})});
            else
                data.vars.(varnames {i_v}) = nan (size (data.vars.offset));
            end
        else
            if (~isempty (var_clnm_ind.(varnames {i_v})))
                txt_vars.(varnames {i_v}) = C {var_clnm_ind.(varnames {i_v})};
            else
                txt_vars.(varnames {i_v}) = [];
            end
        end
    end

    read_date_ind = numel (txt_vars.gps_time) - 100;
    if (read_date_ind < 1)
        error ('Too short file, debug here');
    end
    
    
    txt_vars.gps_time = strrep (txt_vars.gps_time, 'T', ' ');
    txt_vars.gps_time = strrep (txt_vars.gps_time, 'Z', '');
    data.vars.time = datetime (txt_vars.gps_time, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
    
    % Determining the last moment with timestamp, assuming possible empty
    % date strings in the end of file
    
    % last_gps_time = nan;
    %gps_time = nan (size (txt_vars.gps_time)); %  - read_date_ind, 1);
    %gps_time = NaT (size (txt_vars.gps_time)); %  - read_date_ind, 1);    
    %last_time_str = 
    
    
%     n = numel (txt_vars.gps_time);
%     for it = read_date_ind : n
%         if (isempty (txt_vars.gps_time {it}))
%             gps_time (it) = nan;
%         else
%             time_str = txt_vars.gps_time {it};
%             time_str = strrep (time_str, 'T', ' ');
%             time_str = strrep (time_str, 'Z', '');
%             
%             try                
%                 gps_time  (it) = datetime (time_str, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
%             catch
%                 error ('Problem with defining datetime, probably wrong format');
%             end
%         end
%         if (isnan (gps_time (it)) && ~isnan (gps_time (it-1)))
%             last_gps_time = gps_time (it-1);
%             last_gps_date_num_ind = it-1;
%             break;
%         elseif (~isnan (gps_time (it)) && it == n)
%             last_gps_time = gps_time (it);
%             last_gps_date_num_ind = it;
%         end
%     end
%     
%     if (isnan (last_gps_time))
%         error ('last_gps_date_num is not availible, debug is needed');
%     end
    
    
    if (~isempty (var_clnm_ind.attribute))
        key = 'ACType|';
        data.info.drone_model = '';
        for i = 1:numel (txt_vars.attribute)
            cur_txt = txt_vars.attribute {i};
            key_ind = strfind (cur_txt, key);
            if (~isempty (key_ind))
                data.info.drone_model = cur_txt (key_ind + length (key):end);
            end
        end
    end
    
    if (~isempty (var_clnm_ind.fly_state))
        data.gohome_ind = find (ismember (txt_vars.fly_state, 'GoHome'));
        data.vars.is_atti = ismember (txt_vars.fly_state, 'Atti');
        if (isempty (data.gohome_ind))
            data.gohome_ind = nan;
        else
            data.gohome_ind = data.gohome_ind (1);
        end
    else
        data.gohome_ind = nan;
    end

%     offset_dt = nan (size (data.offset_time));
%     for it = 2:numel (offset_dt)
%         offset_dt (it) = data.offset_time (it) - data.offset_time (it - 1);
%     end
%     
%     
%     if (max (offset_dt) > 10)
%         warning ('huge iregularity in offset_dt, max (offset_dt) > 10');
%     end
%     
%     mean_dt   = nanmean   (offset_dt (offset_dt < 1));
%     median_dt = nanmedian (offset_dt (offset_dt < 1));
    
    %dt = (data.offset_time (end) - data.offset_time (end-1))/(24*3600);
    %dt_gps = (last_gps_date_num (end) - last_gps_date_num (1)) / numel (last_gps_date_num);
    %dt_offset = ((data.offset_time (end) - data.offset_time (end-100)) / numel (data.offset_time (end-100:end)))/(24*3600);
    %dt_offset_all = ((data.offset_time (end) - data.offset_time (1)) / numel (data.offset_time))/(24*3600);
    
    %n = numel (data.offset_time);
    %data.date_num = last_gps_date_num + linspace (-n+1,0, n) * min (median_dt, mean_dt) / (24*3600);
    %data.date_num = last_gps_time + (linspace (-last_gps_date_num_ind+1,n-last_gps_date_num_ind, n))' * min (median_dt, mean_dt) / (24*3600);

    data.vars = struct2table (data.vars);
    data.vars = table2timetable (data.vars);
    
    data.vars (isnan (minute (data.vars.time)), :) = [];
    
    remove_ind = find (data.vars.time < datetime (2016, 1, 1, 0, 0, 0));
    if (numel (remove_ind) > 0.5 * numel (data.vars.time))
        errror ('too many time steps for 2015, check here!');
    end
    data.vars (remove_ind, :) = [];

    ofset1 = data.vars.offset (1:2:end);
    ofset2 = data.vars.offset (2:2:end);
    
    if (numel (ofset1) > numel (ofset2))
        ofset1 (end) = [];
    end
        
    if (numel (ofset2) > numel (ofset1))
        ofset2 (end) = [];
    end
    
    med_offset_dt = nanmedian (ofset2 - ofset1);
    
    
    last_unique_ind = 1;
    delta_time = zeros (size (data.vars.time)); 
    for it = 1:numel (data.vars.time)
        if (data.vars.time (it) == data.vars.time (last_unique_ind))
            delta_time (it) = (it - last_unique_ind) * med_offset_dt; %data.vars.offset (it) - data.vars.offset (last_unique_ind);
        else
            last_unique_ind = it;
        end
    end
    
    data.vars.time.Format = [data.vars.time.Format, '.SSS'];
    data.vars.time = data.vars.time + seconds (delta_time);
    
    [~, unique_ind] = unique (data.vars.time);
    data.vars = data.vars (unique_ind, :);
    
    if (numel (find (~isnan (data.vars.rel_height))) == 0 || numel (find (~isnan (data.vars.rel_height))) < numel (find (~isnan (data.vars.alti))))
        if (numel (find (~isnan (data.vars.alti))) > 0)
            warning ('alti is used instead of rel_height');
            data.vars.alti (data.vars.alti == 0) = nan;
            data.vars.abs_height = data.vars.alti;
            data.vars.rel_height = data.vars.alti - min (data.vars.alti);
        else
            error ('rel_height data in empty, alti data is also empty');
        end
    end    

    data.flight_start_ind = nan;
    data.flight_end_ind = nan;
    
%     data.vars.flight_time_sm = movmean (data.vars.flight_time, 10);
%     dtime = nan (size (data.vars.flight_time_sm));
%     for i = 2:numel (data.vars.flight_time_sm)
%         dtime(i) = data.vars.flight_time_sm (i) - data.vars.flight_time_sm (i - 1);
%     end
%     
%     
%     for i = 2:numel (data.vars.flight_time_sm)
%         if (isnan (data.flight_start_ind) && dtime (i) > 0 && data.vars.rel_height (i) > 0)
%             data.flight_start_ind = i;
%         elseif (i > data.flight_start_ind && )
%             data.flight_end_ind = i;
%             break;
%         end
%     end

    for i = 2:numel (data.vars.flight_time)
        if (isnan (data.flight_start_ind) && data.vars.flight_time (i) > data.vars.flight_time (i-1) && data.vars.rel_height (i) > 0)
            data.flight_start_ind = i;
        elseif (i > data.flight_start_ind && data.vars.flight_time (i) == data.vars.flight_time (end))
            data.flight_end_ind = i;
            break;
        end
    end
    
    if (isnan (data.flight_start_ind))
        warning ('Impossible to determine flight start time');
    end
    
    if (isnan (data.flight_end_ind))
        warning ('Impossible to determine flight end time');
    end

    if (~isnan (data.gohome_ind))
        data.gohome_time =  data.vars.time (data.gohome_ind);
    else
        data.gohome_time = nan;
    end
    
    data.flight_start_time  = data.vars.time (data.flight_start_ind);
    data.flight_end_time = data.vars.time (data.flight_end_ind);
    data.flight_ind = data.flight_start_ind : data.flight_end_ind - 1;
    
    first_flight_height = data.vars.rel_height (data.flight_start_ind);
    last_flight_height  = data.vars.rel_height (data.flight_end_ind - 1);
    
    corr = linspace (first_flight_height, last_flight_height, numel (data.flight_ind))';
    
    data.vars.rel_height_corr = data.vars.rel_height;
    data.vars.rel_height_corr (data.flight_ind) = data.vars.rel_height_corr (data.flight_ind) - corr;
    
    str1 = datestr (data.vars.time (1));
    str2 = datestr (data.vars.time (end));

    fprintf ('mc_read_flightlog_phantom(): time range: %s - %s\n', str1, str2);

    if (max (data.vars.time) - min (data.vars.time) > days (1))
        error ('time difference > 1 day, something is likely wrong');
    end
    

    fprintf ('mc_read_flightlog_phantom(): height corr: %.1f\n', last_flight_height);
    save (mat_path, 'data', '-v7.3');

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


