function [data] = f_XF_ProcessMainBoard (data, words, date_num)
    
    STEP = datenum (0, 0, 0, 0, 0, 1);
    
    if (numel (words) >= 5)
        cur_p    = str2num (words {2}) / (10 .^ 2);
        cur_t_p  = str2num (words {3}) / (10 .^ 2);
        cur_rh   = str2num (words {4}) / (10 .^ 1);
        cur_t_rh = str2num (words {5}) / (10 .^ 2);
    else
        cur_p = nan;
        cur_t_p = nan;
        cur_rh = nan;
        cur_t_rh = nan;
    end
    
    data.p    = [data.p;    cur_p];
    data.t_p  = [data.t_p;  cur_t_p];
    data.rh   = [data.rh;   cur_rh];
    data.t_rh = [data.t_rh; cur_t_rh];
    
    data.date_num = [data.date_num; date_num];
    
end


