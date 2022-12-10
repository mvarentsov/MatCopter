function [xf_data_tab, pressure_var] = mc_read_xf (xf_path, XF_LISTENERS)

    try 
        XF_LISTENERS;
    catch exc
        XF_LISTENERS = {{3, 'GPS'}, {0, 'MainBoard'}, {1, 'EE03'}, {5, 'NTC'}, {7, 'CH4'}};
    end
    xf_data = f_LoadXF (xf_path, XF_LISTENERS);
    
    varnames = fieldnames (xf_data);
    
    xf_data_tab = [];
    for i_var = 1:numel (varnames)
        varname = varnames {i_var};
        if (strcmp (varname, 'info'))
            continue;
        end
          
        xf_data.(varname) = struct2table (xf_data.(varname));
        xf_data.(varname).time = datetime (datevec (xf_data.(varname).date_num));
        xf_data.(varname).date_num = [];
        xf_data.(varname) = table2timetable (xf_data.(varname));
        
        for i_col = 1:numel (xf_data.(varname).Properties.VariableNames)
            col_name = xf_data.(varname).Properties.VariableNames {i_col};
            if (strcmp (varname, 'MainBoard'))
                tab_varname = 'MB';
            else
                tab_varname = varname;
            end
            xf_data.(varname).Properties.VariableNames {i_col} = ['XF_', tab_varname, '_', col_name];
        end
        if (isempty (xf_data_tab))
            xf_data_tab = xf_data.(varname);
        else
            xf_data_tab = synchronize (xf_data_tab, xf_data.(varname));
        end
    end
    
    xf_data_tab.time = dateshift (xf_data_tab.time, 'start', 'second');
    
    t1 = dateshift (min (xf_data_tab.time), 'start', 'second');
    t2 = max (xf_data_tab.time);
    dt = f_median_dt (xf_data_tab.time);
    
    new_times = t1:seconds(1):t2;
    
    xf_data_tab = retime (xf_data_tab, new_times);
    
    pressure_var = 'XF_MB_p';

end

