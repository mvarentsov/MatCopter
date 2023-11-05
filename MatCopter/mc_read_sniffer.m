function [data, pressure_var] = f_read_sniffer (path)

    if (~exist(path))
        error (['file ', path, ' not exists'])
    end

    data = readtable (path, "NumHeaderLines",2);
    data.time = NaT (size (data.TimeStamp));
    for i = 1:numel(data.TimeStamp)
        str = data.TimeStamp{i}(2:end);
        data.time (i) = datetime (str, 'InputFormat', 'y-MM-dd HH:mm:ss');
    end
    data.time = data.time - hours (3);
    data = table2timetable(data);

    data.TimeStamp = [];
    data.Var15 = [];
   
    for i = 1:numel (data.Properties.VariableNames)
        varname = data.Properties.VariableNames{i};
        if (varname(end) == '_')
            varname = varname(1:end-1);
        end
        varname = strrep (varname, 'Temperature', 't');
        varname = strrep (varname, 'Humidity', 'rh');
        data.Properties.VariableNames{i} = ['Snif_', varname];
    end

%     raw_data = readtable (path);
%     
%     for i = 1:numel (raw_data.Var1)
%         str = raw_data.Var1 (i, 1);
%         words = strsplit (str{1}, '.');
%         raw_data.Var1 (i, 1) = words (1);
%     end
%     
%     data.time = datetime (raw_data.Var1) - hours (7); %, 'InputFormat', 'yyyy-MM-DD hh:mm:ss');
%     data.sens_t = str2double (raw_data.Var2);
%     data.sens_rh = str2double (raw_data.Var3);
%     data = table2timetable (struct2table (data));
    
    pressure_var = 'Snif_PressurePa';

    
    
end