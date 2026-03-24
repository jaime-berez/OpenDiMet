function varargout = plotData(data, opts)
% PLOTDATA Plot 3D coordinate data using a scatter plot.
%
%   Syntax
%     plotData(data)
%     plotData(data, Name = Value)
%     h = plotData(data)
%     h = plotData(data, Name = Value)
%
%   Description
%     Creates a 3D scatter plot of 3D coordinate data. Plot appearance can
%     be controlled using name-value arguments. If an output is requested,
%     the scatter object handle is returned.
%
%   Input Arguments
%     data - Coordinate points to plot
%       Nx3 double matrix
%
%   Name-Value Arguments
%     markerColor - Marker color
%       1x3 double | Nx3 double
%     icon - Marker symbol
%       string scalar
%     size - Marker size
%       positive scalar double
%     label - Legend label
%       string scalar
%     ax - Target axes
%       axes object
%     handleVisibility - Handle visibility behavior
%       string scalar
%
%   Output Arguments
%     h - Scatter object handle
%       Returned only if requested
%
%   Example
%     plotData(data, label="Measured Data", markerColor=[1 0 0])
%     h = plotData(data, icon="o", size=24)

    arguments
        data (:,3) double
        opts.markerColor (:,3) double = [0 0.4470 0.7410]
        opts.markerStyle (1,1) string = "o"
        opts.markerSize (1,1) double {mustBePositive} = 300
        opts.dataLabel (1,1) string = ""
        opts.ax = []
        opts.handleVisibility (1,1) string = "on"
    end

    ax = opts.ax;
    if isempty(ax) || ~isvalid(ax)
        ax = gca;
    end

    scatterArgs = {ax, data(:,1), data(:,2), data(:,3), ...
        opts.markerSize, opts.markerColor, char(opts.markerStyle)};

    if opts.markerStyle ~= "."
        scatterArgs = [scatterArgs, {'filled'}];
    end

    h = scatter3(scatterArgs{:}, ...
        'DisplayName', opts.dataLabel, ...
        'HandleVisibility', char(opts.handleVisibility));

    axis(ax, 'equal');
    axis(ax, 'padded');
    grid(ax, 'on');

    if nargout > 0
        varargout{1} = h;
    end
end