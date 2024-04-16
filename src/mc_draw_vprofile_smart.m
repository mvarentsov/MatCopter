function [leg_h, leg_str, val_lim, west_cutoff] = mc_draw_vprofile_smart (pr, varname, color, opts)

    assert (isstruct (pr) && isfield (pr, 'asc') && isfield (pr, 'dsc') && ...
            istable (pr.asc) && istable (pr.dsc), 'pr should have asc and dsc fields')

    if (~isfield (opts, 'WEST_WIND_CORR'))
        opts.WEST_WIND_CORR = nan;
    end
    
    if (~isfield (opts, 'BAD_DSC'))
        opts.BAD_DSC = false;
    end
    
    if (~isfield (opts, 'RADIAL_PLOT'))
        opts.RADIAL_PLOT = false;
    end


    z_levels = pr.asc.z;

    %if (~isfield (pr, 'mean'))
    [pr.mean, pr.min, pr.max, west_cutoff] = mc_average_asc_and_dsc_segments (pr.asc, pr.dsc, opts.WEST_WIND_CORR);
    %end
    
    %[val_mean, val, west_cutoff] = mc_profiles2draw (pr_asc, pr_dsc, varname, opts.WEST_WIND_CORR);
    
    leg_h = zeros (0);
    leg_str = cell (0);
    if (opts.SEPARATE_ASC_DSC == 0)
        
         if (~opts.RADIAL_PLOT)
             p1 = plot (pr.asc.(varname),  z_levels, ':k', 'LineWidth', 2, 'Color', color);
             p2 = plot (pr.dsc.(varname),  z_levels, '-k', 'LineWidth', 2, 'Color', color);
         else
             p1 = polarplot (pr.asc.(varname)*pi/180, z_levels, ':k', 'LineWidth', 2, 'Color', color);
             p2 = polarplot (pr.dsc.(varname)*pi/180, z_levels, '-k', 'LineWidth', 2, 'Color', color);
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
         try
            x = pr.mean.(varname);
         catch 
             disp ('aaa')
         end
         
         ok_ind = find (~isnan (x));
         
         x1 = pr.min.(varname); 
         x2 = pr.max.(varname); 
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
                if (opts.SEPARATE_ASC_DSC >= 3)
                    plot (pr.asc.(varname),  z_levels, ':k', 'LineWidth', 0.5, 'Color', color);
                    plot (pr.dsc.(varname),  z_levels, '--k', 'LineWidth', 0.5, 'Color', color);
                end
            end
            p1 = plot (x, y, '-k', 'LineWidth', 2, 'Color', color);
         else
            p1 = polarplot (x*pi/180, y, '-k', 'LineWidth', 2, 'Color', color);
         end

         leg_str1 = [varname, ', %CORR'];
         leg_str = [leg_str, leg_str1];
         leg_h = [leg_h, p1];         
    end
    
    if (opts.SEPARATE_ASC_DSC == 0 || opts.SEPARATE_ASC_DSC >= 2)
        if (strcmp (varname, 'est_windd'))
            ind = find (z_levels > 10);
        else
            ind = 1:numel (z_levels);
        end
        
        max_val = max (pr.max.(varname) (ind, :));
        min_val = min (pr.min.(varname) (ind, :));
    else
        max_val = max (pr.mean.(varname));
        min_val = min (pr.mean.(varname));
    end
    val_lim = [min_val, max_val];
    

    
end

