function mc_draw_arrows (x, y, dir, varargin)
    for i = 1:numel (dir)
        if (~isnan (dir (i)))
            text (x (i), y (i), char(8595), 'Rotation',  -dir (i), 'Horizontal', 'center', 'Vertical', 'middle', varargin {1:end});
        end
    end
end

