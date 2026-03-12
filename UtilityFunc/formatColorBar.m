function formatColorBar(ax, res, location)
    % FORMATCOLORBAR Format the colorbar for form-error visualization.
    %
    %   Syntax
    %     formatColorBar(ax, res, location)
    %
    %   Input Arguments
    %     ax - Target axes containing the plotted data
    %       matlab.graphics.axis.Axes object
    %     res - Residual values used to determine color scale limits
    %       Nx1 double vector
    %     location - Colorbar placement relative to the axes
    %       string scalar | character vector
    %
    %   Example
    %     formatColorBar(gca, residuals, "eastoutside");
    minRes = min(res);     % minimum residual
    maxRes = max(res);     % maximum residual
    N = 9;                 % number of ticks on the colorbar
    t = linspace(0,1,N);   % row of N values between 0 and 1

    if abs(maxRes) > abs(minRes)
        tl = linspace(-abs(maxRes), abs(maxRes), N);
    else
        tl = linspace(-abs(minRes), abs(minRes), N);
    end

    c = colorbar(ax, 'Ticks', t, 'TickLabels', tl, 'Location', location);
end
