function [data] = f_XF_ProcessGPS (data, words, date_num)
    
    TIME_STEP = datenum (0, 0, 0, 0, 0, 1);

    if (numel (words) < 3)
        return;
    end
    date_str1 = words {2};
    date_str2 = words {3};
    
    date_str = [date_str1, '_', date_str2];
    try 
        cur_date_num = datenum (date_str, 'yyyy/mm/dd_HH:MM:SS');
    catch exc
        cur_date_num = nan;
    end
    
    cur_date_vec = datevec (cur_date_num);
    
    if (cur_date_vec (1) > 3000)
        disp ('aaa');
    end
    
    if (~isempty (strfind (date_str, '07:54:08')))
        disp ('bbbb');
    end
    
    if (numel (words) >= 6)
        cur_lat    = str2num (words {4}) / (10 .^ 7);
        cur_lon    = str2num (words {5}) / (10 .^ 7);
        cur_height = str2num (words {6}) / (10 .^ 3);
    else
        cur_lat    = nan;
        cur_lon    = nan;
        cur_height = nan;
    end
    
    if (numel (data.date_num) > 0)
        last_date_num = data.date_num (end);
        last_date_vec = datevec (last_date_num);
        if (cur_date_num < last_date_num || isnan (cur_date_num))
            cur_date_num = last_date_num + TIME_STEP;
            %cur_lon    = nan;
            %cur_lat    = nan;
            %cur_height = nan;
        elseif (last_date_vec (1) ~= 2013 && (cur_date_num - last_date_num) / TIME_STEP >= 1.99) 
            %disp ('cccc');
            cur_date_num = last_date_num + TIME_STEP;
        elseif (last_date_vec (1) ~= 2013 && cur_date_num - last_date_num > 100 * TIME_STEP)
            disp (datestr (cur_date_num));
            disp (datestr (last_date_num));
            cur_date_num = last_date_num + TIME_STEP;
            cur_lon    = nan;
            cur_lat    = nan;
            cur_height = nan;
        end
    end
    
    
    data.lat    = [data.lat;    cur_lat];
    data.lon    = [data.lon;    cur_lon];
    data.height = [data.height; cur_height];
    
    data.date_num = [data.date_num; cur_date_num];
    
end

