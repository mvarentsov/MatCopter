function self = mc_separate_profiles (self, varname, find_lowest_point) %, profile_start_ind, profile_end_ind)
    
    try 
        find_lowest_point;
    catch
        find_lowest_point = false;
    end
    
    profile_start_ind = self.flight_start_ind;
    profile_end_ind = self.flight_end_ind;
    
    profile_ind = profile_start_ind:profile_end_ind;

    [min_p, peak_ind] = min (self.vars.(varname) (profile_ind));
    peak_ind = profile_ind (peak_ind);
    
    self.flight_ind_asc = profile_start_ind:peak_ind;    
    self.flight_ind_dsc = peak_ind:profile_end_ind;      
    
    if (find_lowest_point)
        [~, lowest_ind_asc] = max (self.vars.(varname) (self.flight_ind_asc));
         self.flight_ind_asc = self.flight_ind_asc (lowest_ind_asc:end);

        [~, lowest_ind_dsc] = max (self.vars.(varname) (self.flight_ind_dsc));
         self.flight_ind_dsc = self.flight_ind_dsc (1:lowest_ind_dsc);
    end

    

end