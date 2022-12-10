function [pr] = mc_prepare_vprofiles (data, pr, z_levels, z_var, vars2draw, corr_info, corr_mode)
    
    if (~iscell (vars2draw))
        vars2draw = {vars2draw};
    end
    
    for i_var = 1:numel (vars2draw)
        var2draw = vars2draw {i_var};
        
        if (~ismember (var2draw, data.vars.Properties.VariableNames))
            warning ([var2draw, ' is not availible']);
            continue;
        end

        if (~isempty (pr) && isfield (pr, 'z_levels') && ~isequal (pr.z_levels, z_levels))
            error ('different z_levels are used');
        elseif (isempty (pr) || ~isfield (pr, 'z_levels'))
            pr.asc = table;
            pr.dsc = table;
            pr.z_levels = z_levels;
            z_levels2draw = zeros (0);
            for i_z = 1:numel (z_levels)-1
                cur_z = 0.5 * (z_levels (i_z) +z_levels (i_z+1));
                z_levels2draw = [z_levels2draw; cur_z];
            end
            pr.asc.z = z_levels2draw;
            pr.dsc.z = z_levels2draw;
        end

        if (~isempty (strfind (var2draw, 'windd')) || ~isempty (strfind (var2draw, 'yaw')))
            [u_var, v_var] = mc_cart_varnames (var2draw);

            if (ischar (corr_mode))
                u_corr = corr_info.(var2draw).(corr_mode);
                v_corr = corr_info.(var2draw).(corr_mode);
            else
                u_corr = 0;
                v_corr = 0;
            end
            
            corr = u_corr;

            [pr.asc.(u_var), ...
             pr.dsc.(u_var)] = mc_prepare_vprofile (data, z_levels, z_var, u_var, u_corr);

            [pr.asc.(v_var), ...
             pr.dsc.(v_var)] = mc_prepare_vprofile (data, z_levels, z_var, v_var, v_corr);
        else
            if (~isempty (strfind (var2draw, '_p')))
                corr = 0;
            else
                if (ischar (corr_mode))
                    corr = corr_info.(var2draw).(corr_mode);
                    fprintf ('%s -> %s, %.2f\n', var2draw, corr_mode, corr);
                else
                    corr = 0;
                end
            end
            [pr.asc.(var2draw), ...
             pr.dsc.(var2draw)] = mc_prepare_vprofile (data, z_levels, z_var, var2draw, corr);
        end

        pr.flight_start_time = data.flight_start_time;
        pr.flight_end_time   = data.flight_end_time;
        pr.flight_mean_time  = mean ([pr.flight_start_time, pr.flight_end_time]);
        pr.flight_mean_lon   = nanmean (data.vars.DJI_lon (data.flight_ind));
        pr.flight_mean_lat   = nanmean (data.vars.DJI_lat (data.flight_ind));
        pr.info = data.info;
        pr.info.z_var = z_var;
        pr.corr_info.(var2draw) = corr;
        pr.corr_str.(var2draw) = sprintf ('%s = %ds', '{\Delta}t', corr); 
    end
end