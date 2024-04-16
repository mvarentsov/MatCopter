function dji_vars_out = mc_calc_wind (dji_vars, est_corr, imu_corr)
     
     dji_vars_out = dji_vars;
     
     use_dji_prefix = false;
     
     for i = 1:numel (dji_vars.Properties.VariableNames)
        cur_name = dji_vars.Properties.VariableNames {i};
        if (~isempty (strfind (cur_name, 'DJI_')))
            cur_name = strrep (cur_name, 'DJI_', '');
            dji_vars.Properties.VariableNames {i} = cur_name;
            use_dji_prefix = true;
        end
     end


     try
         est_corr.kx;
     catch
         est_corr.kx = 1;
     end
     
     try
         est_corr.ky;
     catch
         est_corr.ky = 1;
     end
     
     try
         est_corr.bx;
     catch
         est_corr.bx = 0;
     end
     
     try
         est_corr.by;
     catch
         est_corr.by = 0;
     end
     
     try
         imu_corr.kx;
     catch
         imu_corr.kx = 1;
     end
     
     try
         imu_corr.ky;
     catch
         imu_corr.ky = 1;
     end
     
     try
         imu_corr.bx;
     catch
         imu_corr.bx = 0;
     end
     
     try
         imu_corr.by;
     catch
         imu_corr.by = 0;
     end
        

    dji_vars.winds_imu = dji_vars.winds;
    
    if (isempty (find (~isnan (dji_vars.windd))))
        dji_vars.winds_imu_u = -dji_vars.wind_y;
        dji_vars.winds_imu_v = -dji_vars.wind_x;
        dji_vars.windd_imu = cart2compass_my (-dji_vars.winds_imu_u, -dji_vars.winds_imu_v);
        dji_vars.windd_imu (isnan (dji_vars.winds_imu_u)) = nan;
    else
        dji_vars.windd_imu = dji_vars.windd;
        dji_vars.windd_imu (dji_vars.windd_imu < 0) = dji_vars.windd_imu (dji_vars.windd_imu < 0) + 360;
        [dji_vars.winds_imu_u, dji_vars.winds_imu_v] = compass2cart_my (dji_vars.windd_imu, -dji_vars.winds_imu);
    end
    
    %if (~isfield (dji_vars, 'is_P4PV2') || ~dji_vars.is_P4PV2)
    abs_vel = sqrt (dji_vars.vel_n .^ 2 + dji_vars.vel_e .^ 2);
    delta_x = dji_vars.airspeed_x * est_corr.kx - abs_vel + est_corr.bx;

    too_high_speed_ind = find (abs_vel > 3);
    delta_x (too_high_speed_ind) = nan;

    dji_vars.winds_est_x = delta_x;
    dji_vars.winds_est_y = dji_vars.airspeed_y * est_corr.ky + est_corr.by;

    dji_vars.winds_est = sqrt (delta_x .^ 2 + dji_vars.airspeed_y .^2);

    dji_vars.rel_dir = cart2compass_my (dji_vars.winds_est_y, dji_vars.winds_est_x);
    rel_dir = cart2compass_my (-dji_vars.winds_est_y, -dji_vars.winds_est_x);

    dji_vars.windd_est = mod (dji_vars.rel_dir + dji_vars.yaw, 360);
        
        
%         figure; 
%         subplot (4, 1, 1);
%         plot (dji_vars.rel_height);
%         subplot (4, 1, 2);
%         plot (dji_vars.winds_est);
%         
%         subplot (4, 1, 3); hold on;
%         plot (dji_vars.airspeed_x, '-r');
%         plot (dji_vars.winds_est_x, '--r');
%         plot (dji_vars.airspeed_y, '-b');
%         ylabel ('airspeed');
% 
%         subplot (4, 1, 4);
%         plot (abs_vel, '-r');
%         ylabel ('abs vel');
        
%     else
%         windd_est0 = cart2compass_my (dji_vars.airspeed_y, -dji_vars.airspeed_x);
%         winds_est0 =  sqrt (dji_vars.airspeed_x .^ 2 + dji_vars.airspeed_y .^2);
%         rel_dir0 = mod (windd_est0 - dji_vars.yaw, 360);
%         [winds_est_y, winds_est_x] = compass2cart_my (rel_dir0, winds_est0);
%         
%         dji_vars.winds_est_x = winds_est_x * est_corr.kx + est_corr.bx;
%         dji_vars.winds_est_y = winds_est_y * est_corr.ky + est_corr.by;
%         
%         dji_vars.winds_est = sqrt (dji_vars.winds_est_x  .^ 2 + dji_vars.winds_est_y .^2);
% 
%         dji_vars.rel_dir = cart2compass_my (dji_vars.winds_est_y, dji_vars.winds_est_x);
%         
%         dji_vars.windd_est = mod (dji_vars.rel_dir + dji_vars.yaw, 360);
%     end
    
    if (ismember ('is_atti', dji_vars.Properties.VariableNames))
        dji_vars.windd_est (dji_vars.is_atti == 1) = nan;
        dji_vars.winds_est (dji_vars.is_atti == 1) = nan;
        dji_vars.winds_est_u (dji_vars.is_atti == 1) = nan;
        dji_vars.winds_est_v (dji_vars.is_atti == 1) = nan;
        dji_vars.windd_imu (dji_vars.is_atti == 1) = nan;
        dji_vars.winds_imu (dji_vars.is_atti == 1) = nan;
        dji_vars.winds_imu_u (dji_vars.is_atti == 1) = nan;
        dji_vars.winds_imu_v (dji_vars.is_atti == 1) = nan;
    end
    
    
    windd_notnan = dji_vars.windd_est;
    windd_notnan (isnan (windd_notnan)) = 0;
    
    [dji_vars.winds_est_u, dji_vars.winds_est_v] = compass2cart (windd_notnan, -dji_vars.winds_est);
    
    t = ones (size (dji_vars.yaw));
    
    dji_vars.yaw (isnan (dji_vars.yaw)) = 0;
    
    [dji_vars.yaw_u, dji_vars.yaw_v] = compass2cart (dji_vars.yaw, t);
    
    
     wind_angle_imu = dji_vars.windd_imu - dji_vars.yaw;
     [dji_vars.winds_imu_y, dji_vars.winds_imu_x] = compass2cart_my (mod (wind_angle_imu, 360), -dji_vars.winds_imu);

     dji_vars.winds_imu_y = -dji_vars.winds_imu_y * imu_corr.ky + imu_corr.by;
     dji_vars.winds_imu_x = -dji_vars.winds_imu_x * imu_corr.kx + imu_corr.bx;
     
     if (use_dji_prefix)
         prefix = 'DJI_';
     else
         prefix = '';
     end
     
     
     dji_vars_out.([prefix, 'winds_imu']) = dji_vars.winds_imu;
     dji_vars_out.([prefix, 'windd_imu']) = dji_vars.windd_imu;
     
     dji_vars_out.([prefix, 'winds_imu_x']) = dji_vars.winds_imu_x;
     dji_vars_out.([prefix, 'winds_imu_y']) = dji_vars.winds_imu_y;
     
     dji_vars_out.([prefix, 'winds_imu_u']) = dji_vars.winds_imu_u;
     dji_vars_out.([prefix, 'winds_imu_v']) = dji_vars.winds_imu_v;

     dji_vars_out.([prefix, 'winds_est']) = dji_vars.winds_est;
     dji_vars_out.([prefix, 'windd_est']) = dji_vars.windd_est;
     
     dji_vars_out.([prefix, 'winds_est_x']) = dji_vars.winds_est_x;
     dji_vars_out.([prefix, 'winds_est_y']) = dji_vars.winds_est_y;
     
     dji_vars_out.([prefix, 'winds_est_u']) = dji_vars.winds_est_u;
     dji_vars_out.([prefix, 'winds_est_v']) = dji_vars.winds_est_v;

end

