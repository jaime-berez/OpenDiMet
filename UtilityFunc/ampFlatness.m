function [fData, clr] = ampFlatness(data, res, dir, ampFac, cmap)
    % AMPFLATNESS Amplify flatness deviation of planar data relative to an associated plane.
    %
    %   Syntax
    %     [fData, clr] = ampFlatness(data, res, dir, ampFac)
    %     [fData, clr] = ampFlatness(data, res, dir, ampFac, cmap)
    %
    %   Input Arguments
    %     data - Measured 3D point coordinates
    %       Nx3 double matrix
    %     res - Signed residuals from the associated plane
    %       Nx1 double vector
    %     dir - Unit normal vector of the associated plane
    %       1x3 double vector
    %     ampFac - Amplification factor for flatness deviation
    %       positive scalar double
    %     cmap - Colormap used to color amplified deviations
    %       256x3 double matrix
    %
    %   Output Arguments
    %     fData - Amplified coordinate data
    %       Nx3 double matrix
    %     clr - RGB colors associated with amplified deviation values
    %       Nx3 double matrix
    %
    %   Example
    %     [fData, clr] = ampFlatness(data, res, dir, 50);
    %     [fData, clr] = ampFlatness(data, res, dir, 50, turbo(256));

    arguments
        data (:,3) {mustBeMatrix}
        res (:,1)  {mustBeColumn}
        dir (1,3)  {mustBeRow}
        ampFac (1,1) {mustBePositive}
        cmap (256,3) {mustBeMatrix} = colormap(turbo)
    end

    % Calculate statistical parameters of the residuals
    rMax  = max(res);
    rMin  = min(res);
    rMean = mean(res);
    rRng  = range(res);

    % Compute values between 0 and 1 for each residual (for colormap)
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

end
