function [leg_str, leg_h, data_val_lim, west_cutoff] = mc_draw_vprofiles (pr, varnames, opts)
    
    if (~iscell (varnames))
        varnames = {varnames};
    end
    
    varname = varnames {1};

    if (~isfield (opts, 'AUTO_TICKS'))
        opts.AUTO_TICKS = false;
    end

    if (~isfield (opts, 'COLORS'))
        opts.COLORS = mc_default_colors ();
    end
    
    if (~isfield (opts, 'SEPARATE_ASC_DSC'))
        opts.SEPARATE_ASC_DSC = true;
    end
    
    if (~isfield (opts, 'WEST_WIND_CORR'))
        opts.WEST_WIND_CORR = nan;
    end
    
    if (~isfield (opts, 'RADIAL_PLOT'))
        opts.RADIAL_PLOT = false;
    end

    set (gca, 'FontSize', 11);
    if (~opts.RADIAL_PLOT)
        hold on; box on; grid on; 
    end
    
    leg_str = cell (0);
    leg_h   = zeros (0);
    
    
    data_val_lim = [1/eps, -1/eps];
    
    for i_pr = 1:numel (pr)
        for i_var = 1:numel (varnames)
            cur_varname = varnames {i_var};
            
            if (~isempty (strfind (cur_varname, 'windd')) || ~isempty (strfind (cur_varname, 'yaw')))
                [u_varname, v_varname] = mc_cart_varnames (cur_varname);
                varname2check = u_varname;
            else
                varname2check = cur_varname;
            end

            if (~ismember (varname2check, pr(i_pr).asc.Properties.VariableNames))
                warning (['variable ' varname2check, ' not found']);
                continue;                    
            end

            if (isfield (pr(i_pr), 'color'))
                color = pr(i_pr).color;
            elseif (numel (varnames) > 1)
                color = opts.COLORS {i_pr, i_var};
            else
                color = opts.COLORS {i_pr};
            end

            [cur_leg_h, cur_leg_str, cur_val_lim, west_cutoff] = mc_draw_vprofile_smart ...
                                       (pr(i_pr), cur_varname, color, opts);

            hold on;
            
             if (isfield (pr(i_pr), 'legend_str'))
                 cur_leg_str = pr(i_pr).legend_str;
             end

             cur_leg_str = strrep (cur_leg_str, '%CORR',  pr(i_pr).corr_str.(cur_varname));


             leg_str = [leg_str, cur_leg_str];
             leg_h = [leg_h, cur_leg_h];

             if (cur_val_lim (1) < data_val_lim (1))
                 data_val_lim (1) = cur_val_lim (1);
             end

             if (cur_val_lim (2) > data_val_lim (2))
                 data_val_lim (2) = cur_val_lim (2);
             end
        end
    end
    
    if (data_val_lim (2) - data_val_lim(1) > 2)
        data_val_lim (2) = ceil (data_val_lim (2));
        data_val_lim (1) = floor (data_val_lim (1));
    end

    if (~opts.RADIAL_PLOT)
        use_data_val_lim = true;
        if (isfield (opts, 'VAL_LIM') && ~isempty (opts.VAL_LIM))
            if (~isstruct (opts.VAL_LIM))
                xlim (opts.VAL_LIM);
                use_data_val_lim = false;
            else
                val_lim_fnames = fieldnames (opts.VAL_LIM);
                for i_f = 1:numel (val_lim_fnames)
                    fname = val_lim_fnames {i_f};
                    for i_v = 1:numel (varnames)
                        if (strcmp (fname, varnames{i_v}) || ...
                            contains (varnames{i_v}, ['_', fname]))
                            xlim (opts.VAL_LIM.(fname));
                            use_data_val_lim = false;
                            break;
                        end
                    end
                    if (~use_data_val_lim)
                        break;
                    end
                end
            end
        end
        if (use_data_val_lim && data_val_lim(2) > data_val_lim(1))
            xlim (data_val_lim);
        end
    end
       
    if (~opts.RADIAL_PLOT)
        ylim (opts.Z_LIM);
    else
        rlim (opts.Z_LIM);
    end
    
    if ( opts.AUTO_TICKS)
        if (strcmp (varname, 't'))
            set (gca, 'XTick', -50:50);
        elseif (strcmp (varname, 'rh'))
            set (gca, 'XTick', 0:10:100);
        end
    end

    def_labels.RUS.height = 'Высота [м]';
    def_labels.RUS.rh     = 'Отн. влажность [%]';
    def_labels.RUS.t      = 'Температура [{\circ}C]';
    def_labels.RUS.pt     = 'Потенциальная температура [K]';
    def_labels.RUS.winds  = 'Скорость ветра [м/с]';
    def_labels.RUS.windd  = 'Направление ветра [{\circ}]';
    def_labels.RUS.conc   = 'Концентрация';

    def_labels.ENG.height = 'Height [m]';
    def_labels.ENG.rh     = 'Rel. humidity [%]';
    def_labels.ENG.t      = 'Temperature [{\circ}C]';
    def_labels.ENG.pt     = 'Potential temperature [K]';
    def_labels.ENG.winds  = 'Wind speed [m/s]';
    def_labels.ENG.windd  = 'Wind direction [{\circ}]';
    def_labels.ENG.conc   = 'Concentration';
    

    if (~opts.RADIAL_PLOT)
        if (strcmp (varname, 't') || contains (varname, '_t'))
            xlabel (def_labels.(opts.LANG).t, 'FontSize', 14, 'FontWeight', 'bold');
        elseif (strcmp (varname, 'pt') || contains (varname, '_pt'))
            xlabel (def_labels.(opts.LANG).pt, 'FontSize', 14, 'FontWeight', 'bold');
        elseif (contains (varname, 'winds'))
            xlabel (def_labels.(opts.LANG).winds, 'FontSize', 14, 'FontWeight', 'bold');
        elseif (contains (varname, 'windd'))
            xlabel (def_labels.(opts.LANG).windd, 'FontSize', 14, 'FontWeight', 'bold');
        elseif (contains (varname, 'rh'))
            xlabel (def_labels.(opts.LANG).rh, 'FontSize', 14, 'FontWeight', 'bold');
        elseif (contains (varname, 'Snif_'))
            xlabel (def_labels.(opts.LANG).conc, 'FontSize', 14, 'FontWeight', 'bold');
        end
        ylabel (def_labels.(opts.LANG).height, 'FontSize', 14, 'FontWeight', 'bold');
        
        if (contains (varname, 'windd'))
            x_ticks = [-360:45:360];
            x_tick_labels = {'N', 'NW', 'W', 'SW', 'S', 'SE', 'E', 'NE', ...
                             'N', 'NW', 'W', 'SW', 'S', 'SE', 'E', 'NE'};   
            set (gca, 'XTick', x_ticks);
            set (gca, 'XTickLabel', x_tick_labels);
        else
            %set (gca, 'XTickLabel', get (gca, 'XTick'));
        end
    end
end

