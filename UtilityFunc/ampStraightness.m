function [fData, clr] = ampStraightness(data, res, dir, ampFac, cmap)
    % AMPSTRAIGHTNESS Amplify straightness deviation of linear data relative to an associated line.
    %
    %   Syntax
    %     [fData, clr] = ampStraightness(data, res, dir, ampFac)
    %     [fData, clr] = ampStraightness(data, res, dir, ampFac, cmap)
    %
    %   Input Arguments
    %     data - Measured 3D point coordinates
    %       Nx3 double matrix
    %     res - Residuals from the associated line
    %       Nx1 double vector
    %     dir - Unit direction vector of the associated line
    %       1x3 double vector
    %     ampFac - Amplification factor for straightness deviation
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
    %     [fData, clr] = ampStraightness(data, res, dir, 50);
    %     [fData, clr] = ampStraightness(data, res, dir, 50, turbo(256));
    
    arguments
        data (:,3) {mustBeMatrix}
        res  (:,1) {mustBeColumn}
        dir  (1,3) {mustBeRow}
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
        rSpan = 2*abs(rMin);              % full range: [-abs(min), +abs(min)]
        t = (res - rMin) ./ rSpan;
        %disp('min based range');
    else
        rSpan = 2*abs(rMax);              % full range: [-abs(max), +abs(max)]
        t = (res - rMin) ./ rSpan;
        %disp('max based range');
    end

    clr = cmap(round(t*255) + 1, :);
    %fData = data + (t - .5) * ampFac * dir;

    % Use pp2l to project the points onto the ideal line
    ctr = mean(data);
    projPnt = NaN(size(data));
    for i = 1:length(data)
        projPnt(i,1:3) = pp2l(data(i,1:3), ctr, dir);
    end

    % Vectors from each point to its projection
    uVec = data - projPnt;

    % Amplify the deviation based on the calculated values
    fData = data + (t) * ampFac .* uVec;
end
