function val = f_Interp4DJI (dji_date_num, dji_data, imet_date_num)

    imet_time_step = imet_date_num (2) - imet_date_num (1);
    val = nan (size (imet_date_num));
    for i = 1:numel (imet_date_num)
        t1 = imet_date_num (i) - imet_time_step / 2;
        t2 = imet_date_num (i) + imet_time_step / 2;
        
        dji_ind = find (dji_date_num >= t1 & dji_date_num < t2);
        val (i) = nanmean (dji_data (dji_ind));
    end


end

