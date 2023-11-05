function [ best_dt ] = mc_best_shift (tab1, tab2, var1, var2, range)
    tab1_new.time = tab1.time;
    tab1_new.(var1) = tab1.(var1);
    tab1_new = struct2table (tab1_new);
    tab1_new = table2timetable (tab1_new);
    
    tab2_new.time = tab2.time;
    tab2_new.(var2) = tab2.(var2);
    tab2_new = struct2table (tab2_new);
    tab2_new = table2timetable (tab2_new);
    
    tab2_dt = f_median_dt (tab2.time);
    
    all_shifts = -range:range;
    corrs = [];
    for shift = all_shifts
        
        cur_tab2 = tab2_new;
        
        cur_tab2.(var2) = circshift(cur_tab2.(var2), shift);
        if (shift > 0)
            cur_tab2.(var2) (1:shift) = nan;
        elseif (shift < 0)
            cur_tab2.(var2) (end-abs(shift):end) = nan;
        end
        
        sync_tab = synchronize (tab1_new, cur_tab2);
        
        ok_ind = find  (~isnan (sync_tab.(var1)) & ~isnan (sync_tab.(var2)));
        if (numel (ok_ind) > 0)
            c = corr (sync_tab.(var1) (ok_ind), sync_tab.(var2) (ok_ind));
        else
            c = nan;
        end
        
        corrs = [corrs; c];
    end
    
    [~, best_ind] = max (corrs);
    best_shift = all_shifts (best_ind);
    best_dt = tab2_dt * best_shift;
    
end

