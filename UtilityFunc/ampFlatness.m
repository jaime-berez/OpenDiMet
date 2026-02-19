%% Function to amplify the flatness deviation of data from a plane
% Amplify the flatness error of points by spreading the points away
% from the ideal plane.

function [fData, clr] = ampFlatness(data, res, dir, ampFac, cmap)
    arguments
        data (:,3) {mustBeMatrix}
        res (:,1)  {mustBeColumn}
        dir (1,3)  {mustBeRow}
        ampFac (1,1) {mustBePositive}
        cmap (256,3) {mustBeMatrix} = colormap(turbo)
    end

    %% Calculate statistical parameters of the residuals
    rMax  = max(res);
    rMin  = min(res);
    rMean = mean(res);
    rRng  = range(res);

    %% Compute values between 0 and 1 for each residual (for colormap)
    if abs(rMin) > abs(rMax)
        rSpan = 2*abs(rMin);           % full range: [-abs(min), +abs(min)]
        t = (res - rMin) ./ rSpan;
        disp('min based range');
    else
        rSpan = 2*abs(rMax);           % full range: [-abs(max), +abs(max)]
        t = (res - rMin) ./ rSpan;     % (kept exactly as your code)
        disp('max based range');
    end

    clr   = cmap(round(t*255) + 1, :);
    fData = data + (t - 0.5) * ampFac * dir;

    %% Calculate a percentage value for each residual
    % (left as-is / unfinished in original)
end
