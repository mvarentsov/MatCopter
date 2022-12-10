function [data] = f_XF_SynchronyseData (data)

    max_t1 = -1/eps;
    min_t2 = 1/eps;
    
    fnames = fieldnames (data);
    
    for i_f = 1:numel (fnames)
        cur_fname = fnames {i_f};
        if (strcmp (cur_fname, 'info'))
            continue;
        end
        
        if (isempty (data.(cur_fname).date_num))
            continue;
        end
        
        cur_t1 = data.(cur_fname).date_num (1);
        cur_t2 = data.(cur_fname).date_num (end);
        
        if (cur_t1 > max_t1)
            max_t1 = cur_t1;
        end
        
        if (cur_t2 < min_t2)
            min_t2 = cur_t2;
        end
    end
    
    if (min_t2 < max_t1)
        error ('error here, check the data');
    end
    
    for i_f = 1:numel (fnames)
        cur_fname = fnames {i_f};
        if (strcmp (cur_fname, 'info'))
            continue;
        end
        
        if (isempty (data.(cur_fname).date_num))
            continue;
        end
        
        cur_ind1 = find (data.(cur_fname).date_num == max_t1);
        cur_ind2 = find (data.(cur_fname).date_num == min_t2);
        
        cur_ind = cur_ind1:cur_ind2;
        
        fnames2 = fieldnames (data.(cur_fname));
        for i_f2 = 1:numel (fnames2)
            cur_fname2 = fnames2 {i_f2};
            for i_ind = 1:numel (cur_ind)
                try
                if (data.GPS.date_num (cur_ind (i_ind)) ~= data.GPS.date_num (cur_ind (i_ind)))
                    disp ('bbb');
                end
                catch exc
                disp ('q');
                end
            end

            if (~isempty (data.(cur_fname).(cur_fname2)))
                try
                    data.(cur_fname).(cur_fname2) = data.(cur_fname).(cur_fname2) (cur_ind);
                catch 
                    disp ('aaa');
                end
            end
        end
    end
    
    fname1 = nan;
    for i_f = 2:numel (fnames)
        cur_fname = fnames {i_f};
        if (strcmp (cur_fname, 'info'))
            continue;
        end
        if (isnan (fname1))
            fname1 = cur_fname;
        end
        
        if (isempty (data.(cur_fname).date_num))
            continue;
        end
        
        try
        if (numel (data.(cur_fname).date_num) ~= numel (data.(fname1).date_num))
            error ('error here, check the data');
        end
        catch exc
            disp ('aaa');
        end
    end
     
    data.info.t1 = max_t1;
    data.info.t2 = min_t2;
    
    data.date_num = data.GPS.date_num;
    
    
end

