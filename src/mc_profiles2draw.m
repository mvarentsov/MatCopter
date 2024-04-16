function [val_mean, val, west_cutoff] = mc_profiles2draw (pr_asc, pr_dsc, varname, WEST_WIND_CORR)
    try
        WEST_WIND_CORR;
    catch exc
        WEST_WIND_CORR = nan;
    end
    
    west_cutoff = nan;
    
    if (contains (varname, 'windd') || contains (varname, 'yaw'))
        vel_varname = strrep (varname, 'windd', 'winds');
        u_varname = [vel_varname, '_u'];
        v_varname = [vel_varname, '_v'];

        u_asc = pr_asc.(u_varname);
        v_asc = pr_asc.(v_varname);
        u_dsc = pr_dsc.(u_varname);
        v_dsc = pr_dsc.(v_varname);
    
        val_asc = cart2compass_my (-u_asc, -v_asc);
        val_dsc = cart2compass_my (-u_dsc, -v_dsc);
        u = [u_asc, u_dsc];
        v = [v_asc, v_dsc];
        
        u_mean = nanmean (u, 2);
        v_mean = nanmean (v, 2);
        val_mean = cart2compass_my (-u_mean, -v_mean);
        
%         if (~isnan (WEST_WIND_NEGATIVE) && ...
%              ((max (val_mean) - min (val_mean)) > 180 || ...
%               (max (val_asc)  - min (val_asc))  > 180 || ...
%               (max (val_dsc)  - min (val_dsc))  > 180))
%             val_asc  (val_asc > WEST_WIND_NEGATIVE)  = val_asc  (val_asc  > WEST_WIND_NEGATIVE) - 360; 
%             val_dsc  (val_dsc > WEST_WIND_NEGATIVE)  = val_dsc  (val_dsc  > WEST_WIND_NEGATIVE) - 360; 
%             val_mean (val_mean > WEST_WIND_NEGATIVE) = val_mean (val_mean > WEST_WIND_NEGATIVE) - 360; 
%             west_corr = true;
%         else
%             west_corr = false;
%         end
        
         spread_asc0  = max (val_asc)  - min (val_asc);
         spread_dsc0  = max (val_dsc)  - min (val_dsc);
         spread_mean0 = max (val_mean) - min (val_mean);

         max_spread0 = max ([spread_asc0, spread_dsc0, spread_mean0]);
         
         if (~isempty (WEST_WIND_CORR) && WEST_WIND_CORR < 0 && max_spread0 > 180)
            best_spread = 1/eps;  
            for cutoff = 170:10:270
                cur_val_asc = val_asc;
                cur_val_dsc = val_dsc;
                cur_val_mean = val_mean;
                cur_val_asc  (cur_val_asc  > cutoff)  = cur_val_asc  (cur_val_asc  > cutoff) - 360; 
                cur_val_dsc  (cur_val_dsc  > cutoff)  = cur_val_dsc  (cur_val_dsc  > cutoff) - 360; 
                cur_val_mean (cur_val_mean > cutoff)  = cur_val_mean (cur_val_mean > cutoff) - 360; 
                
                spread_asc  = max (cur_val_asc)  - min (cur_val_asc);
                spread_dsc  = max (cur_val_dsc)  - min (cur_val_dsc);
                spread_mean = max (cur_val_mean) - min (cur_val_mean);
                
                max_spread = max ([spread_asc, spread_dsc, spread_mean]);
                if (max_spread < best_spread)
                    best_spread = max_spread;
                    best_spread_mean = spread_mean;
                    west_cutoff = cutoff;
                end
            end
            
            if (best_spread_mean < spread_mean0 || max_spread < max_spread0)
                val_asc  (val_asc > west_cutoff)  = val_asc  (val_asc  > west_cutoff) - 360;
                val_dsc  (val_dsc > west_cutoff)  = val_dsc  (val_dsc  > west_cutoff) - 360; 
                val_mean (val_mean > west_cutoff) = val_mean (val_mean > west_cutoff) - 360; 
            else
                west_cutoff = nan;
            end
        elseif (~isempty (WEST_WIND_CORR) && WEST_WIND_CORR > 0 && max_spread0 > 180)
            west_cutoff = WEST_WIND_CORR;
            val_asc  (val_asc > west_cutoff)  = val_asc  (val_asc  > west_cutoff) - 360;
            val_dsc  (val_dsc > west_cutoff)  = val_dsc  (val_dsc  > west_cutoff) - 360; 
            val_mean (val_mean > west_cutoff) = val_mean (val_mean > west_cutoff) - 360; 
        end
        val = [val_asc, val_dsc];
    else
        
        val_asc = pr_asc.(varname);
        val_dsc = pr_dsc.(varname);
        val = [val_asc, val_dsc];
        val_mean = nanmean (val, 2);
    end
end

