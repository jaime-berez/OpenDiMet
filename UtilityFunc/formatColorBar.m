% Format the colorbar for form error figures
function formatColorBar(ax, res, location)

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
