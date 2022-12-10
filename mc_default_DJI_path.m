%d:\! Work\! IFA\! campaigns\Barentsburg2022\Flights\DJI\'
%d:\! Work\! IFA\! campaigns\Barentsburg 2022\Flights\DJI\

function [ dji_path, fly_str] = mc_default_DJI_path (xf_path, dji_dir_name, pattern)

    try
        pattern;
    catch 
        pattern = 'FLY';
    end
    
    try
        dji_dir_name;
    catch 
        dji_dir_name = 'DJI';
    end

    [path, name, ext] = fileparts (xf_path);
    
    dji_dir_name = [path, '\', dji_dir_name, '\'];
    if (~exist (dji_dir_name))
        prev_path = fileparts (path);
        dji_dir_name = [prev_path, '\', dji_dir_name, '\'];
    end
    
    if (~exist (dji_dir_name))
        error ('DJI flight logs are not found in default locations');
    end
    
    fly_ind = strfind (name, pattern);
    if (isempty (fly_ind))
        dji_path = ''; %error ('No flight information in iMet log');
    else
        words = strsplit (name (fly_ind:end), {'_', ' '});
        fly_str = words {1}; %name (fly_ind:end);
        dji_path = [dji_dir_name, fly_str, '.csv'];
    end
    disp ('aaa');
    

end

