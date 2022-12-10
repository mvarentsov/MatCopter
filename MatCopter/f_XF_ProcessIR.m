function [data] = f_XF_ProcessIR (data, words, date_num)
    
    STEP = datenum (0, 0, 0, 0, 0, 1);

    
    cur_t_sensor = str2num (words {2}) / (10 .^ 2);
    
    if (numel (words) > 2)
        cur_t_ir = str2num (words {3}) / (10 .^ 2);
    else
        cur_t_ir = nan;
    end
    
    data.t_sensor = [data.t_sensor; cur_t_sensor];
    data.t_ir = [data.t_ir;     cur_t_ir];
    data.date_num = [data.date_num; date_num];
    
end


