function [data_row_corr] = mc_apply_inertion_corr (data_row, intertion)


    data_row_corr = nan (size (data_row));
    
    for it = 1:numel (data_row) - intertion
         data_row_corr (it) = data_row (it + intertion);
    end

end

