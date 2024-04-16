function [pr] = mc_equalize_pressure4vprofiles (pr, pressure_vars)

    try
        pressure_vars;
        default_pressure = false;
    catch 
        default_pressure = true;
    end
    
    if (isempty (pressure_vars))
        default_pressure = true;
    end

    p0 = [];
    
    for i_pr = 1:numel (pr)
        if (default_pressure)
            pressure_vars = {pr(i_pr).info.pressure_var};
        end
        for i_v = 1:numel (pressure_vars)
            cur_var = pressure_vars {i_v};
            if (~ismember (cur_var, pr(i_pr).asc.Properties.VariableNames))
                if (~default_pressure)
                    warning ([cur_var, ' is not availible']);
                    continue;
                else
                    error ([cur_var, ' is not availible']);
                end
            end
            pr(i_pr).(['mean_', cur_var]) = mc_profiles2draw (pr(i_pr).asc, pr(i_pr).dsc,  cur_var);
            if (isempty (p0))
                p0 = pr(i_pr).(['mean_', cur_var]);
            end
        
            if (i_pr > 1 || i_v > 1)
                pr(i_pr).(['corr_', cur_var]) = -nanmean (pr(i_pr).(['mean_', cur_var]) - p0);
            else
                pr(i_pr).(['corr_', cur_var]) = 0;
            end
        
            pr(i_pr).asc.(cur_var) =  pr(i_pr).asc.(cur_var) +  pr(i_pr).(['corr_', cur_var]);
            pr(i_pr).dsc.(cur_var) =  pr(i_pr).dsc.(cur_var) +  pr(i_pr).(['corr_', cur_var]);
        end
    end
    
%     try
%         pr = rmfield (pr, 'p_corr');
%         pr = rmfield (pr, 'mean_p');
%     catch exc
%         disp ('aaa');
%     end
    
    %for i_pr = 1:numel (pr)
    %    pr(i_pr) = rmfield (pr(i_pr), 'p_corr');
    %    pr(i_pr) = rmfield (pr(i_pr), 'mean_p');
    %end
end

