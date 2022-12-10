function med_dt = f_median_dt (time)
    
%     dt = nan (size (time));
% 
%     if (isdatetime (time))
%         time = datenum (time);
%         is_datetime = true;
%     else
%         is_datetime = false;
%     end
% 
%     for i = 2:numel (time)
%         dt (i) = time (i) - time (i - 1);
%     end
% 
%     med_dt = mode (dt);
%     
%     if (is_datetime)
%         med_dt = minutes (datenum (datevec (med_dt * 24 * 60))); %datetime (datevec (med_dt));
%     end

    dt = nan (size (time));
    
    time1 = time (1:2:end);
    time2 = time (2:2:end);
    
    if (numel (time2) > numel (time1))
        time2 (end) = [];
    end
    
    if (numel (time2) < numel (time1))
        time1 (end) = [];
    end
    
    dt = time2 - time1;
    
    dt_min = minutes (dt);
    
    %for i = 2:numel (time)
    %     tic
    %     cur_dt = time (i) - time (i - 1);
    %     dt(i) = minutes (cur_dt);
    %     toc
    %     pause;
    %end
    
    med_dt_min = mode (dt_min);
    med_dt = minutes (med_dt_min);
    
end

