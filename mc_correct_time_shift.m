function [best_dt, best_dt_asc, best_dt_w] = mc_correct_time_shift (dji_data_src, meteo_time, meteo_p)

    best_dt = 0;
    best_dt_asc = 0;
    best_dt_dsc = 0;
    
    
    max_corr = 0;
    max_corr_asc = 0;
    max_corr_dsc = 0;
    
    max_corr_w = 0;
    
    try
        time_step = meteo_time (2) - meteo_time (1);
    catch exc
        disp ('aaa');
    end
    
    dji_data = dji_data_src;
    

    for dt = -90 * time_step : time_step : 90 * time_step
        
        dji_heigh0 = dji_data.vars.rel_height_corr;
        dji_heigh0 (1:dji_data.flight_start_ind-1) = nan;
        dji_heigh0 (dji_data.flight_end_ind+1:end) = nan;
        
        dji_rel_height = interp1 (dji_data.vars.time + dt, dji_heigh0, meteo_time);
        
        
        ok_ind = find (~isnan (dji_rel_height .* meteo_p));

        [~, max_height_ind] = min (meteo_p(ok_ind));

        ok_ind_asc = ok_ind (1:max_height_ind);
        ok_ind_dsc = ok_ind (max_height_ind+1:end);

        corr = corrcoef (dji_rel_height (ok_ind), meteo_p(ok_ind));
        corr_asc = corrcoef (dji_rel_height (ok_ind_asc), meteo_p (ok_ind_asc));
        corr_dsc = corrcoef (dji_rel_height (ok_ind_dsc), meteo_p (ok_ind_dsc));

        if (numel (corr) > 2)
            corr     = abs (corr (1, 2));
        else
            corr = 0;
        end
        if (numel (corr_asc) > 2)
            corr_asc = abs (corr_asc (1, 2));
        else
            corr_asc = 0;
        end
        if (numel (corr_dsc) > 2)
            corr_dsc = abs (corr_dsc (1, 2));
        else
            corr_dsc = 0;
        end
        corr_w = (corr_asc * numel (ok_ind_asc) + corr_dsc * numel (ok_ind_dsc)) / (numel (ok_ind_asc) + numel (ok_ind_dsc));

        if (corr > max_corr)
            max_corr = corr;
            best_dt = dt;
        end

        if (corr_w > max_corr_w)
            max_corr_w = corr_w;
            best_dt_w = dt;
        end


        if (corr_asc > max_corr_asc)
            max_corr_asc = corr_asc;
            best_dt_asc = dt;
        end
        
        if (corr_dsc > max_corr_dsc)
            max_corr_dsc = corr_dsc;
            best_dt_dsc = dt;
        end


    end

    try
        fprintf ('mc_correct_time_shift(): Time shift correction done, best dt = %d, best dt_asc = %d;  best dt_asc = %d; best dt_w = %d\n', ...
                 round (best_dt / time_step), round (best_dt_asc / time_step), round (best_dt_dsc / time_step), round (best_dt_w / time_step));
    catch exc
        figure; hold on; plot (dji_data_src.vars.time, dji_data_src.vars.rel_height);plot (meteo_time, meteo_p);
        error ('Something wrong here');
    end

    if (abs (round (best_dt / time_step)) >= 30)
        warning ('Too big best_dt, check here');
    end
end

