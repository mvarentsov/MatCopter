function [ ind ] = f_GetTimeInd (date_num, t1, t2, span)

    try
        span;
    catch
        span = 0;
    end
    
    [~, ind1] =  min (abs (date_num - t1));
    [~, ind2] =  min (abs (date_num - t2));
    ind = ind1-span:ind2+span;
    
    if (t1 > date_num (end) || t2 < date_num (1))
        ind = zeros (0);
    end
    
    

end

