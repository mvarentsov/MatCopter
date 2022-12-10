%% Import MatCopter and other requied libs
addpath ('MatCopter\');
addpath ('libs\tight_subplot\');


%% Load flight data 
clear;
XQ_PATH = 'G:\! Data\IFA\! campaigns\Muhrino 2022\Profiles\20220616-203724-00044491_XQ2_fl13_FLY675.csv';

fl_data = mc_load_flight (XQ_PATH, ...                    % path to data from the sensor (should contain flight number '_FLY*' in filename)
                          @mc_read_xq, ...                % function to read data from the sensor
                          @mc_read_flightlog_phantom, ... % function to read drone's flighlog
                          false);                         % reload file 

%% ************* Settings ************************************************

opts.VARS2PROFILES  = {'XQ_t', 'XQ_pt', 'XQ_rh', 'DJI_winds_est', 'DJI_windd_est'};
opts.VARS2DRAW      = {'XQ_pt', 'XQ_rh', 'DJI_winds_est'}; 


opts.CORR_MODE4T    = 'best_rmse';
opts.Z_VAR          = 'XQ_baric_z'; 
opts.Z_GRID         = 0:5:500;
opts.PICS_DIR       = 'pics\';    
opts.EXPORT_DIR     = 'processed_profiles\';
opts.WEST_WIND_CORR = 180;

fig_opts.Z_LIM = [0, 500];   
fig_opts.LANG = 'ENG';
fig_opts.SEPARATE_ASC_DSC = 2;                

fig_opts.VAL_LIM.Ri    = [-0.2, 0.4];
fig_opts.VAL_LIM.winds = [0, 10];

% ************* Process vertical profiles *********************************

fl_data.vars = mc_calc_wind (fl_data.vars);
fl_data = mc_separate_profiles (fl_data, 'XQ_p', true);

fl_data.corr_info = mc_estimate_inertion (fl_data, {'XQ_t', 'XQ_rh', 'DJI_winds_imu', 'DJI_winds_est'}, 60);
fl_data.corr_info.DJI_windd_imu = fl_data.corr_info.DJI_winds_imu;
fl_data.corr_info.DJI_windd_est = fl_data.corr_info.DJI_winds_est;

fl_data = mc_init_baric_z (fl_data, 'XQ_t', fl_data.corr_info.XQ_t.(opts.CORR_MODE4T));

pr = [];

for i_var = 1:numel (opts.VARS2PROFILES)
    cur_var = opts.VARS2PROFILES {i_var};
    
    if (contains (cur_var, 'wind') && contains (cur_var, '_est'))
        corr_mode = 'no_corr';  
    else
        corr_mode = 'best_rmse';  
    end
    
    if (contains(cur_var, '_pt'))
        pr = mc_prepare_vprofiles ...
              (fl_data, pr, opts.Z_GRID, opts.Z_VAR, ...
                {'XQ_t', 'XQ_p'}, fl_data.corr_info, corr_mode);
        pr = mc_calc_pt4vprofiles (pr, 'XQ_t');
    else
        pr = mc_prepare_vprofiles ...
              (fl_data, pr, opts.Z_GRID, opts.Z_VAR, ...
               cur_var, fl_data.corr_info, corr_mode);
    end
end

% ************* Export profiles *******************************************

mc_export_vprofiles (pr);

% ************* Draw figures **********************************************

close all;
mkdir (opts.PICS_DIR);

figure ('Color', 'white', 'Position', [100, 100, 350 * numel(opts.VARS2DRAW), 400]);
ax = tight_subplot (1, numel (opts.VARS2DRAW), 0.02, [0.13, 0.05], [0.05, 0.05]);

for i_var = 1:numel (opts.VARS2DRAW)

    cur_vars2draw = opts.VARS2DRAW {i_var};

    if (iscell (cur_vars2draw))
        var2draw = cur_vars2draw {1};
    else
        var2draw = cur_vars2draw;
        cur_vars2draw = {cur_vars2draw};
    end
    subplot (ax (i_var));

    [leg_str, leg_h, data_val_lim] = mc_draw_vprofiles (pr, cur_vars2draw, fig_opts);
    
    set (gca, 'XTickLabel', get (gca, 'XTick'));
    if (i_var > 1)
        ylabel ('');
    else
        set (gca, 'YTickLabel', get (gca, 'YTick'));
    end
    
    title ([pr.info.t1_str, ' - ', datestr(pr.flight_end_time, 'HH:MM'), ' UTC (', pr.info.fly_str, ')'], 'FontSize', 10);

    if (contains (var2draw, 'wind'))
        mc_draw_vprofiles_arrows (pr, 'DJI_windd_est', 0:50:500, fig_opts, 'XStep', 0, 'XMargin', 0.04, 'Location', 'Out', 'FontSize', 25); 
    end

    %print ([opts.PICS_DIR, var2draw, '_', pr.info.mean_time_str4file, ' ', pr.info.fly_str, ' ', opts.Z_VAR, '_noleg.jpg'], '-djpeg', '-r200');
    legend (leg_h, strrep (leg_str, '_', '\_'), 'Location', 'Best');
end
set (gcf, 'PaperPositionMode', 'auto');
print ([opts.PICS_DIR, var2draw, '_', pr.info.mean_time_str4file, ' ', pr.info.fly_str, ' ', opts.Z_VAR, '_leg.jpg'], '-djpeg', '-r200');


