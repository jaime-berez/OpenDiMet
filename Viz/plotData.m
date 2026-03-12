function h = plotData(data, markerColor, icon, size, ax)
% PLOTDATA Plot 3D coordinate data using a scatter plot.
%
%   Syntax
%     h = plotData(data)
%     h = plotData(data, markerColor)
%     h = plotData(data, markerColor, icon)
%     h = plotData(data, markerColor, icon, size)
%     h = plotData(data, markerColor, icon, size, ax)
%
%   Description
%     Creates a 3D scatter plot of coordinate data. Marker color, marker
%     style, marker size, and axes handle can be optionally specified.
%     The axes are automatically set to equal scaling with padding and a
%     grid for improved visualization of geometric data.
%
%   Input Arguments
%     data - Nx3 double - Matrix of coordinate points to plot.
%     markerColor - Nx3 or 1x3 double  
%         RGB color values for the markers. If a single color is provided,
%         it is applied to all points. If Nx3 is provided, each point is
%         colored individually.
%
%     icon - 1x1 string - Marker symbol used in the scatter plot.
%     size - 1x1 double - Marker size used in the scatter plot.
%     ax - Axes handle - Target axes for plotting. If not provided, the
%     current axes (gca) are used.
%         
%   Output Arguments
%     h - Scatter object - Handle to the generated scatter plot.    
%
%   Example
%     plotData(data);
%
%     plotData(data, [1 0 0], ".", 40);
%
%     ax = axes;
%     plotData(data, [0 0 1], ".", 36, ax);

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
