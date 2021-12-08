function pt = mc_calc_pt (p, t, p0)
    
    try 
        p0;
    catch
        p0 = 1000;
    end

    pt = nan (size (p)); % potential h
    
    for i = 1:numel (pt)
        pt (i) = (t(i)+273.15)*(p0/p(i)).^0.2857; %from Pa to Hpa
    end
    
end