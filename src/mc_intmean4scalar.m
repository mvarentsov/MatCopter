function [mean_val, mean_p] = mc_intmean4scalar (p_intervals, p_val, val)
    
    mean_val = zeros (0);
    mean_p   = zeros (0);
    
    for i_p = 1:numel (p_intervals) - 1
        p1 = p_intervals (i_p);
        p2 = p_intervals (i_p + 1);
    
        p_ind = find (p_val >= p1 & p_val < p2);

        if (~isempty (p_ind))
            cur_mean_val = mean (val (p_ind));
        else
            cur_mean_val = nan;
        end
        
        cur_mean_p = (p1 + p2)/2;
        
        mean_val = [mean_val; cur_mean_val];
        mean_p   = [mean_p;   cur_mean_p];
        
        %if (numel (mean_val) ~= numel (mean_p))
        %    disp ('aaa');
        %end
    end
end

