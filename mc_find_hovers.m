function [ hovers ] = mc_find_hovers (data, mode, min_hover_len, smooth_size)

    is_hover = zeros (size (data.vars.time));

    switch mode
        case 'ctrl'
            is_hover = data.vars.DJI_ctrl_aer == 0 & data.vars.DJI_ctrl_elev == 0 & data.vars.DJI_ctrl_thr == 0 & data.vars.DJI_vel_h < 1;
    end

    is_hover (data.vars.time < data.flight_start_time) = 0;
    is_hover (data.vars.time > data.flight_end_time) = 0;
    
    if (isdatetime (data.gohome_time))
       is_hover (data.vars.time >= data.gohome_time) = 0;
    end

    is_hover = round (movmean (is_hover, smooth_size));
    
    hovers = zeros (0);
    hover_start = nan;
    
    for i = 1:numel (is_hover)
        if (is_hover (i) && isnan (hover_start))
            hover_start = i;
        elseif (~is_hover (i) && ~isnan (hover_start))
            cur_hover.start_ind = hover_start;
            cur_hover.end_ind = i;
            cur_hover.start_time = data.vars.time (cur_hover.start_ind);
            cur_hover.end_time   = data.vars.time (cur_hover.end_ind);
            cur_hover.len = cur_hover.end_ind - cur_hover.start_ind;
            if (cur_hover.len > min_hover_len)
                 varnames = data.vars.Properties.VariableNames;
                 for i_n = 1:numel (varnames)
                    varname = varnames {i_n};
                    cur_hover.mean_vars.(varname) = nanmean (data.vars.(varname)(cur_hover.start_ind:cur_hover.end_ind));
                 end
                hovers = [hovers; cur_hover];
            end
            hover_start = nan;
        end
    end

     figure;  hold on;
%     %plot (data.time, data.DJI_rel_height)
%     %plot (data.time (is_hover == 1), data.DJI_rel_height (is_hover == 1), 'o')
     plot (data.vars.time,  data.vars.DJI_rel_height)
     plot (data.vars.time (is_hover == 1), data.vars.DJI_rel_height (is_hover == 1), 'o')
     
     y_lim = get (gca, 'YLim');
     y1 = y_lim (1);
     y2 = y_lim (2);

     
     for i = 1:numel (hovers)
        x1 = data.vars.time (hovers(i).start_ind);
        x2 = data.vars.time (hovers(i).end_ind);
        plot ([x1, x2], [y1, y1], '-k');
        plot ([x1, x2], [y2, y2], '-k');
        plot ([x1, x1], y_lim, '-k');
        plot ([x2, x2], y_lim, '-k');
    end

end

