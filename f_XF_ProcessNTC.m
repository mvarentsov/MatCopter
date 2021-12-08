function [data] = f_XF_ProcessNTC (data, words, date_num)
    
    if (numel (words) >= 2)
        cur_t = str2num (words {2}) / (10 .^ 2);
    else
        cur_t = nan;
    end
    
    
    data.t    = [data.t;    cur_t];
    
    data.date_num = [data.date_num; date_num];
    
end


