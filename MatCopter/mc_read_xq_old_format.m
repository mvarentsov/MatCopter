function [ data ] = mc_read_xq_old_format (path)
    
    tab_data = readtable (path);
    
%     test_clmn = C {1, 5};
%     is_empty = zeros (size (test_clmn));
%     
%     for i = 1:numel (is_empty)
%         is_empty (i) = isempty (test_clmn {i});
%     end
%     not_empty_ind = find (~is_empty);
    
    start = 1;
    gps_date0 = table2array (tab_data (:, start + 8));
    gps_time0 = table2array (tab_data (:, start + 9));

    if (~isdatetime (gps_date0(1)))
        try
            gps_date0 = datetime (gps_date0, 'InputFormat', 'yyyy/MM/dd');
        catch exc
            error ('Something wrong with date column, check here');
        end
    end
    
    
    if (~isduration (gps_time0(1)))
        error ('type of time collumn is not duration')
    end
   
    data = table;
    data.time = gps_date0 + gps_time0; %datetime (gps_date_str1, 'InputFormat', 'yyyy/MM/dd_HH:mm:ss');
    
    data.p     = table2array (tab_data (:, start + 4)) / 100;
    data.t     = table2array (tab_data (:, start + 5)) / 100;
    data.rh    = table2array (tab_data (:, start + 6)) / 10;
    data.lon   = table2array (tab_data (:, start + 10)) / (10^7);
    data.lat   = table2array (tab_data (:, start + 11)) / (10^7);
    data.gps_z = table2array (tab_data (:, start + 12)) / (10^3);
    
    data = table2timetable (data);
    
    data = data (data.time >= datetime (2016, 1, 1, 0, 0, 0), :);
    
    str1 = datestr (data.time (1));
    str2 = datestr (data.time (end));
    
    fprintf ('mc_read_xq_old_format(): XQ time range is %s - %s\n', str1, str2);
end

