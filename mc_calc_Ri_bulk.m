function [Ri, Qv] = mc_calc_Ri_bulk (t_pr, pt_pr, rh_pr, vel_pr, p_pr, z_pr)
  
    E_pr = 6.1*10 .^ (7.45*t_pr ./ (235+t_pr));
    e_pr = E_pr .* rh_pr / 100;
    
    qv_pr = 0.623 .* e_pr ./ (p_pr - 0.377.*e_pr); %в г/г

    M = qv_pr./(1-qv_pr);

    if (isnan (M (1)))
        notnan_M_ind = find (~isnan (M));
        first_notnan_M_ind = notnan_M_ind (1);
        first_notnan_M = M (first_notnan_M_ind);
        M(1:first_notnan_M_ind-1)  = first_notnan_M;
    end

    if (max (pt_pr) < 100)
        pt_pr = pt_pr + 273.15;
    end

    pt_v_pr = pt_pr .* (1 + 0.61 * M);

    Ri = nan (size (pt_v_pr));

    G = 9.81;


    for iz = 1:numel (z_pr)
        Ri (iz) = (G / pt_v_pr (1)) * (pt_v_pr(iz) - pt_v_pr(1)) * z_pr(iz) / (vel_pr(iz) ^ 2);
    end
    
end