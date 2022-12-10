function [data] = f_XF_ProcessEE03 (data, words, date_num)
    
    if (numel (words) >= 3)
        cur_rh  = str2num (words {2}) / (10 .^ 1);
        cur_t   = str2num (words {3}) / (10 .^ 2);
    else 
        cur_rh = nan;
        cur_t = nan;
    end
    
    if (isempty (cur_t))
        warning ('Empty T reading');
        cur_t = data.t (end);
    end
    
    if (isempty (cur_rh))
        warning ('Empty RH reading');
        cur_rh = data.rh (end);
    end
    
    data.t    = [data.t;    cur_t];
    data.rh   = [data.rh;   cur_rh];
    
    if (numel (data.t) ~= numel (data.rh))
        disp ('aaa');
    end
    
    data.date_num = [data.date_num; date_num];
    
end


