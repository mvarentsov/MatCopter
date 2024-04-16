function [model] = mc_create_baric_model (data, flight_ind, t_varname, p_varname)

    try
        p_varname; 
    catch
        p_varname = data.info.pressure_var;
    end

    min_p = min (data.vars.(p_varname) (flight_ind));
    max_p = max (data.vars.(p_varname) (flight_ind));
     
    model.p_intervals = floor (min_p):0.5:ceil(max_p); %1 hPa step

    [model.mean_t, ...
     model.mean_p]  = mc_intmean4scalar (model.p_intervals, data.vars.(p_varname) (flight_ind),  data.vars.(t_varname) (flight_ind));
    %mean_dji_height = mc_intmean4scalar (model.p_intervals, data.vars.(p_varname) (flight_ind),  data.vars.DJI_rel_height (flight_ind));
    
    model.mean_t    = flipud (model.mean_t);
    model.mean_p    = flipud (model.mean_p);
    %mean_dji_height = flipud (mean_dji_height);
    
    ok_ind = find (~isnan (model.mean_t .* model.mean_p));
    model.mean_t = model.mean_t (ok_ind);
    model.mean_p = model.mean_p (ok_ind);
    %mean_dji_height = mean_dji_height (ok_ind);
   
    
    model.mean_rel_height = nan (size (model.mean_p));
    
    R = 287.058; %газова€ посто€нна€ дл€ сухого воздуха
    
    model.mean_rel_height (1) = 0;
    
    for i_z = 2:numel (model.mean_rel_height)
        rho = 100 * 0.5 * (model.mean_p (i_z)+model.mean_p (i_z-1)) / ...
              (R * (0.5 * (model.mean_t (i_z)+model.mean_t (i_z-1)) + 273.15));
        
        %dz_dp = 1.0 / (-9.81 *rho);
        delta_p = 100 * (model.mean_p (i_z) - model.mean_p (i_z - 1)); %из гѕа в ѕа
        delta_z  = - delta_p / (9.81 * rho);
        
        
        model.mean_rel_height (i_z) =  model.mean_rel_height (i_z - 1) + delta_z;
    end
    
   %figure; hold on; 
   %plot (mean_dji_height, '-k');
   %plot (model.mean_rel_height, '-r');
   
   %dp = -g * rho * dz
   
   %dz = -dp / (-g * rho)
    
end

