function [leg_h, leg_str, val_lim, west_cutoff] = mc_draw_vprofile_smart (pr_asc, pr_dsc, varname, color, opts)

    if (~isfield (opts, 'WEST_WIND_CORR'))
        opts.WEST_WIND_CORR = nan;
    end
    
    if (~isfield (opts, 'BAD_DSC'))
        opts.BAD_DSC = false;
    end
    
    if (~isfield (opts, 'RADIAL_PLOT'))
        opts.RADIAL_PLOT = false;
    end


    try
        z_levels = pr_asc.z_levels2draw;
    catch
        z_levels = pr_asc.z_levels;
    end
    
    [val_mean, val, west_cutoff] = mc_profiles2draw (pr_asc, pr_dsc, varname, opts.WEST_WIND_CORR);
    
    leg_h = zeros (0);
    leg_str = cell (0);
    if (opts.SEPARATE_ASC_DSC == 0)
        
         if (~opts.RADIAL_PLOT)
             p1 = plot (val (:, 1),  z_levels, ':k', 'LineWidth', 2, 'Color', color);
             p2 = plot (val (:, 2),  z_levels, '-k', 'LineWidth', 2, 'Color', color);
         else
             p1 = polarplot (val (:, 1)*pi/180, z_levels, ':k', 'LineWidth', 2, 'Color', color);
             p2 = polarplot (val (:, 2)*pi/180, z_levels, '-k', 'LineWidth', 2, 'Color', color);
         end

         if (strcmp (opts.LANG, 'RUS'))
            leg_str1 = [varname, ' (восх.)'];
            leg_str2 = [varname, ' (нисх.)'];
         else
            leg_str1 = [varname, ' (asc.)'];
            leg_str2 = [varname, ' (dsc.)'];
         end
         
         leg_str = [leg_str, leg_str1, leg_str2];
         leg_h = [leg_h, p1, p2];
     elseif (opts.SEPARATE_ASC_DSC > 0)
         x = val_mean;
         
         ok_ind = find (~isnan (x));
         
         x1 = min (val, [], 2);
         x2 = max (val, [], 2);
         x1 (isnan (x1)) = x (isnan (x1));
         x2 (isnan (x2)) = x (isnan (x2));
         
         y = z_levels;

         y_ok = y (ok_ind);
         x1_ok = x1 (ok_ind);
         x2_ok = x2 (ok_ind);
         
         
         y_plot =[y_ok; flipud(y_ok)];
         x_plot=[x1_ok; flipud(x2_ok)];
         
         if (numel (find (isnan (x_plot))) > 0)
             error ('EPARATE_ASC_DSC=2 could not be used with nans in profiles');
         end
         
         if (~opts.RADIAL_PLOT)
            if (opts.SEPARATE_ASC_DSC >= 2)
                f = fill (x_plot, y_plot, color, 'EdgeColor', 'none');
                set (f, 'FaceAlpha', 0.2);
            end
            p1 = plot (x, y, '-k', 'LineWidth', 2, 'Color', color);
         else
            p1 = polarplot (x*pi/180, y, '-k', 'LineWidth', 2, 'Color', color);
         end

         leg_str1 = [varname];
         leg_str = [leg_str, leg_str1];
         leg_h = [leg_h, p1];         
    end
    
    if (opts.SEPARATE_ASC_DSC == 0 || opts.SEPARATE_ASC_DSC >= 2)
        if (strcmp (varname, 'est_windd'))
            ind = find (z_levels > 10);
        else
            ind = 1:numel (z_levels);
        end
        
        max_val = max (max (val (ind, :)));
        min_val = min (min (val (ind, :)));
    else
        max_val = max (val_mean);
        min_val = min (val_mean);
    end
    val_lim = [min_val, max_val];
    

    
end

