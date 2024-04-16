function [p_corr] = mc_correct_pressure (p, start_ind, end_ind)

    before_start_ind = max (1, start_ind - 10):start_ind;
    after_end_ind    = end_ind:min (end_ind+10, numel (p));

    before_start_p = mean (p (before_start_ind));
    after_end_p    = mean (p (after_end_ind));
    
    if (isnan (after_end_p) && isnan (before_start_p))
        warning ('after_end_height and before_start_height are not availible');
        before_start_p = max (p (start_ind:end_ind));
        after_end_p = before_start_p;
    elseif (isnan (after_end_p))
        warning ('after_end_height is not availible');
        after_end_p = before_start_p;
    elseif (isnan (before_start_p))
        warning ('before_start_height is not availible');
        before_start_p =  after_end_p;
    end
    
    if (abs (after_end_p - before_start_p) > 10)
        warning ('abs (after_end_p - before_start_p) > 100 m. before_start_p is used.');
        after_end_p = before_start_p;
        
        %TO DO: this happens when XQ data log ends earlier than DJI flight
        %log
    end
    
    flight_ind = start_ind:end_ind;
    
    delta_p = linspace (0, after_end_p - before_start_p, numel (flight_ind))'; 
    
    p_corr = p;
    p_corr (flight_ind) =  p (flight_ind) - delta_p;
    p_corr (end_ind:1:end) = p (end_ind:1:end) - delta_p (end);
end

