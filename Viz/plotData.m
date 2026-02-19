function h = plotData(data, markerColor, icon, size, ax)

    arguments
        data (:,3) double
        markerColor (:,3) double = [0 0.4470 0.7410]
        icon (1,1) string = "."
        size (1,1) double {mustBePositive} = 36
        ax = []
    end

    if isempty(ax) || ~isvalid(ax)
        ax = gca;
    end

    h = scatter3(ax, data(:,1), data(:,2), data(:,3), ...
                 size, markerColor, icon, 'filled');

    axis(ax, 'equal');
    axis(ax, 'padded');
    grid(ax, 'on');
end
