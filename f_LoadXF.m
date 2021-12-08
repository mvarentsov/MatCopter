function [data] = f_LoadXF (path, listeners)
    
    GPS_ID = 3;

    data.info.groupnames = cell (0);
    
    [filepath,name,ext] = fileparts(path);
    data.info.name = name;
    data.info.path = path;
    
    for i_l = 1:numel (listeners)
        cur_listener = listeners {i_l};
        cur_list_name = cur_listener {2};
        init_func_name = ['f_XF_Init', cur_list_name];
        init_func = str2func (init_func_name);
        data.(cur_list_name) = init_func ();
        data.info.groupnames = cat (2, data.info.groupnames, cur_list_name);
    end
    
    last_gps_date_num = nan;
    
    in_id = fopen (path);

    n_line = 0;
    
    while (~feof (in_id))
        line = fgets (in_id);
        %if (mod (n_line, 1000) == 0)
        %    disp (n_line);
        %end
%         if (~isempty (strfind (line, '2018/02/04,08:08:07')))
%             disp ('aaa');
%         end
        words = strsplit (line, ',');
        id_str = words {1};
        id = str2num (id_str);
        if (~isempty (id))
            for i_l = 1:numel (listeners)
                cur_listener = listeners {i_l};
                cur_list_id   = cur_listener {1};
                cur_list_name = cur_listener {2};
                
                if (cur_list_id == id && (~isnan (last_gps_date_num) || id == GPS_ID))
                    process_func_name = ['f_XF_Process', cur_list_name];
                    process_func = str2func (process_func_name);
                    data.(cur_list_name) = process_func (data.(cur_list_name), words, last_gps_date_num);
                    
                    if (id == GPS_ID)
                        last_gps_date_num = data.GPS.date_num (end);
                    end
                    
%                     if (~isnan (last_gps_date_num) && strcmp (cur_list_name, 'MainBoard'))
%                         delta_t1 = data.GPS.date_num (1) - data.MainBoard.date_num (1);
%                         delta_t = data.GPS.date_num (end) - data.MainBoard.date_num (end);
%                     
%                         disp ([delta_t1, delta_t]);
%                         %pause;
%                         %n1 = numel (data.GPS.date_num);
%                         %n2 = numel (data.MainBoard.date_num);
%                         %disp ([n1, n2]);
%                     end
                    
                end
                
               
                
            end
        end
        n_line = n_line + 1;
    end
    
    fclose (in_id);
    
    data.info.first_gps_ind = find (data.GPS.date_num > datenum (2014, 1, 1, 0, 0, 0));
    if (isempty (data.info.first_gps_ind))
        CRIT_DELTA = datenum (0, 0, 0, 0, 10, 0);
        for it = 2:numel (data.GPS.date_num)
            delta = data.GPS.date_num (it) - data.GPS.date_num (it-1);
            if (delta > CRIT_DELTA)
               data.info.first_gps_ind = it; 
               fprintf ('f_LoadXF(): first_gps_ind succesfully found (2): %s\n', datestr (data.GPS.date_num (data.info.first_gps_ind)));
               break;
            end
        end
    else
        data.info.first_gps_ind = data.info.first_gps_ind  (1);
        fprintf ('f_LoadXF(): first_gps_ind succesfully found (1): %s\n', datestr (data.GPS.date_num (data.info.first_gps_ind)));
    end
    
    if (~isempty (data.info.first_gps_ind))
        data.info.first_gps_date_num = data.GPS.date_num (data.info.first_gps_ind);
        TIME_STEP = datenum (0, 0, 0, 0, 0, 1);

        for i_l = 1:numel (listeners)
            cur_listener = listeners {i_l};
            cur_list_id   = cur_listener {1};
            cur_list_name = cur_listener {2};
            if (isempty (data.(cur_list_name).date_num))
                continue;
            end

            cur_gps_ind = find (data.(cur_list_name).date_num == data.info.first_gps_date_num);

            if (cur_gps_ind == 1)
                continue;
            end

            for it = cur_gps_ind - 1:-1:1
                data.(cur_list_name).date_num (it) = data.(cur_list_name).date_num (it+1) - TIME_STEP;
            end
        end
    else
    	fprintf ('f_LoadXF(): impossible to find first_gps_ind\n');
    end
    
    str1 = datestr (data.GPS.date_num (1));
    str2 = datestr (data.GPS.date_num (end));
    
    disp (['f_LoadXF(): XF data time range: ', str1, ' - ', str2]);
    
    data.info.p_sensor_name = 'MainBoard';
    
    
end