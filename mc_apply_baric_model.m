function [height, p_corr] = mc_apply_baric_model (p, model, start_ind, end_ind) %start_height)


    try
        height = interp1 (model.mean_p, model.mean_rel_height, p, 'linear', 'extrap');
    catch
        disp ('aaa');
    end

    before_start_ind = max (1, start_ind - 10):start_ind;
    after_end_ind    = end_ind:min (end_ind+10, numel (p));

    before_start_height = mean (height (before_start_ind));
    after_end_height    = mean (height (after_end_ind));
    
    if (isnan (after_end_height) && isnan (before_start_height))
        warning ('after_end_height and before_start_height are not availible');
        before_start_height = min (height (start_ind:end_ind));
        after_end_height = before_start_height;
    elseif (isnan (after_end_height))
        warning ('after_end_height is not availible');
        after_end_height = before_start_height;
    elseif (isnan (before_start_height))
        warning ('before_start_height is not availible');
        before_start_height =  after_end_height;
    end
    
    if (after_end_height - before_start_height > 100)
        warning ('after_end_height - before_start_height > 100 m. before_start_height is used.');
        after_end_height = before_start_height;
        
        %TO DO: this happens when XQ data log ends earlier than DJI flight
        %log
    end
    
    flight_ind = start_ind:end_ind;
    
    z0 = linspace (before_start_height, after_end_height, numel (flight_ind))'; 
    
    height (1:start_ind-1) = nan;
    height (end_ind+1:end) = nan;
    height (flight_ind) =  height (flight_ind) - z0;
    
end

