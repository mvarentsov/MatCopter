function [ data ] = mc_read_xq_new_format (path)
    
    tab_data = readtable (path);
    
    var_headers.time   = {'XQ-iMet-XQ Time'};
    var_headers.date   = {'XQ-iMet-XQ Date'};
    var_headers.p      = {'XQ-iMet-XQ Pressure'};
    var_headers.t      = {'XQ-iMet-XQ Air Temperature'};
    var_headers.rh     = {'XQ-iMet-XQ Humidity'};
    var_headers.rh_t   = {'XQ-iMet-XQ Humidity Temp'};
    var_headers.lon    = {'XQ-iMet-XQ Longitude'};
    var_headers.lat    = {'XQ-iMet-XQ Latitude'};
    var_headers.gps_z  = {'XQ-iMet-XQ Altitude'}; 
    
    headers = tab_data.Properties.VariableDescriptions;
    if (isempty (headers))
        headers = tab_data.Properties.VariableNames;
    end

    if (strcmp (headers{1}, 'Var1'))
        in = fopen (path);
        line = fgetl (in);
        fclose (in);
        headers = strsplit (line, ',');
    end
    
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
             %fprintf ('%s%s<- []\n', varnames {i_v}, repmat (' ', 1, 20 - length (varnames {i_v})));
             %if (ismember (varnames {i_v}, var_headers_critical))
             error (sprintf ('Variable %s is not found in %s', varnames {i_v}, path));
             %end
        else
             fprintf ('%s%s<- %s\n', varnames {i_v}, repmat (' ', 1, 20 - length (varnames {i_v})), headers {cur_ind});
        end
        var_clnm_ind.(varnames {i_v}) = cur_ind;
    end
    
    
    data = table;

    % Different Matlab versions perform in different way 

    if (iscell (table2array(tab_data (1, var_clnm_ind.date))))
        first_date_str = table2cell (tab_data (:, var_clnm_ind.date));
        if (contains (first_date_str, '/'))
            dates = datetime (table2cell (tab_data (:, var_clnm_ind.date)), 'InputFormat', 'yyyy/MM/dd');
        else
            try
                dates = datetime (table2array (tab_data (:, var_clnm_ind.date)), 'InputFormat', 'dd.MM.yyyy');
            catch exc
                try
                    dates = datetime (table2array (tab_data (:, var_clnm_ind.date)), 'InputFormat', 'yyyy.MM.dd');        
                catch exc
                    dates = datetime (table2array (tab_data (:, var_clnm_ind.date)), 'InputFormat', 'dd-MM-yyyy');    
                end
            end
        end
    elseif (isdatetime (table2array(tab_data (1, var_clnm_ind.date))))
        dates = table2array(tab_data (:, var_clnm_ind.date));
    end

    if (isduration (table2array(tab_data (1, var_clnm_ind.time))))
        times = table2array(tab_data (:, var_clnm_ind.time)); 
    else
        error ('Unknown time type, debug here')
    end
    data.time = datetime (year (dates), month (dates), day (dates)) + times;

%     first_date_str = data.date_str {1};
%     
%     if (~isempty (strfind (first_date_str, '/')))
%         data.time = datetime (data.date_str, 'InputFormat', 'yyyy/MM/dd_HH:mm:ss');
%         if (max (data.time) < datetime (2000, 1, 1, 0, 0, 0))
%             fprintf ('mc_read_xq_new(): dd/MM/yyyy_HH:mm:ss is used\n');
%             data.time = datetime (data.date_str, 'InputFormat', 'dd/MM/yyyy_HH:mm:ss');
%         end
%     else
%         try
%             data.time = datetime (data.date_str, 'InputFormat', 'dd.MM.yyyy_HH:mm:ss');
%         catch exc
%             data.time = datetime (data.date_str, 'InputFormat', 'yyyy.MM.dd_HH:mm:ss');        
%         end
%     end
%     
%     data.date_str = [];

    for i_v = 1:numel (varnames)
        cur_varname = varnames {i_v};
        if (~ismember  (cur_varname, {'date', 'time'}))
            column_data = table2array (tab_data (:, var_clnm_ind.(cur_varname)));
            if (~isnumeric (column_data))
                error ('data for ', cur_varname, ' is not numeric');
            end
            data.(cur_varname) = column_data;
        end
    end
    
    data = table2timetable (data);
    data = data (data.time >= datetime (2016, 1, 1, 0, 0, 0), :);
    
    str1 = datestr (data.time (1));
    str2 = datestr (data.time (end));
    
    fprintf ('mc_read_xq_new(): time range is %s - %s\n', str1, str2);

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

