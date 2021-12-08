function [data] = f_XF_ProcessCH4 (data, words, date_num)
    
    if (numel (words) >= 4)
        cur_val1 = str2num (words {2});
        cur_val2 = str2num (words {3});
        cur_val3 = str2num (words {4});
    else 
        cur_val1 = nan;
        cur_val2 = nan;
        cur_val3 = nan;
    end
        
    
    data.val1 = [data.val1; cur_val1];
    data.val2 = [data.val2; cur_val2];
    data.val3 = [data.val3; cur_val3];
    
    data.date_num = [data.date_num; date_num];
    
end


