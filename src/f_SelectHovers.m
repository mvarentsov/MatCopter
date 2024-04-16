function [hovers, is_hover] = f_SelectHovers(data, min_hover_len, min_vert_vel, draw)

    dji_vert_vel0 = f_CalcVertSpeed (data.DJI.rel_height_corr, 1);
    dji_hor_vel0 = data.DJI.vel_h;

    dji_hor_vel = smooth (dji_hor_vel0, 5);
    dji_vert_vel = smooth (dji_vert_vel0, 5);
    
    is_hover = nan (size (data.date_num));
    is_hover (data.flight_ind) = 1;
    is_hover (dji_hor_vel  > 0.5)  = nan;
    is_hover (abs (dji_vert_vel) > min_vert_vel) = nan;

    hover_ind = find (is_hover > 0);

    hover_start = nan;

    hovers = zeros (0);
    
    for i = 1:numel (is_hover)
        if (~isnan (is_hover (i)) && isnan (hover_start))
            hover_start = i;
            max_dji_height = max (data.DJI.rel_height_corr (hover_start:i));
            min_dji_height = min (data.DJI.rel_height_corr (hover_start:i));
            if (max_dji_height - min_dji_height > 10)
                is_hover (i) = nan;
            end
        elseif (isnan (is_hover (i)) && ~isnan (hover_start))
            cur_hover.start_ind = hover_start;
            cur_hover.end_ind = i;
            cur_hover.start_date_num = data.date_num (cur_hover.start_ind);
            cur_hover.end_date_num = data.date_num (cur_hover.end_ind);
            cur_hover.len = cur_hover.end_ind - cur_hover.start_ind;
            cur_hover.max_dji_height = max_dji_height;
            cur_hover.min_dji_height = min_dji_height;
            
            if (cur_hover.len > min_hover_len)
                hovers = [hovers; cur_hover];
            end
            hover_start = nan;
        end
    end
    
    
    if (draw)
        figure; 
        subplot (3, 1, 1); hold on;
        %plot (data.date_num, data.vgrid.baric_z, '-k');
        %plot (xq_data.date_num, xq_data.vgrid.baric_z, '-c');
        plot (data.date_num, data.DJI.rel_height_corr, '-b');
        plot (data.date_num, data.DJI.rel_height_corr .* is_hover, '-r');
        y_lim = get (gca, 'YLim');
        y1 = y_lim (1);
        y2 = y_lim (2);

        for i = 1:numel (hovers)
            x1 = data.date_num (hovers(i).start_ind);
            x2 = data.date_num (hovers(i).end_ind);
            plot ([x1, x2], [y1, y1], '-k');
            plot ([x1, x2], [y2, y2], '-k');
            plot ([x1, x1], y_lim, '-k');
            plot ([x2, x2], y_lim, '-k');
        end

        xlim ([data.flight_start_time, data.flight_end_time]);
        title ('Height');


        subplot (3, 1, 2); hold on;
        plot (data.date_num, dji_vert_vel);
        plot (data.date_num, dji_vert_vel .* is_hover, '-r');
        xlim ([data.flight_start_time, data.flight_end_time]);
        title ('Vertical velocity');

        subplot (3, 1, 3);
        plot (data.date_num, dji_hor_vel);
        xlim ([data.flight_start_time, data.flight_end_time]);
        title ('Horizontal velocity')
    end

    is_hover (isnan (is_hover)) = 0;

end

