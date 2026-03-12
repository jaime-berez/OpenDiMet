function rad = guess3dCircRad(data)
    % GUESS3DCIRCRAD Estimate the radius of a circle or sphere from 3D coordinate data.
    %
    %   Syntax
    %     rad = guess3dCircRad(data)
    %
    %   Input Arguments
    %     data - Measured 3D point coordinates
    %       Nx3 double matrix
    %
    %   Output Arguments
    %     rad - Estimated radius used as an initial guess for circle or sphere fitting
    %       scalar double
    %
    %   Example
    %     rad = guess3dCircRad(data);

    xData = data(:,1);
    yData = data(:,2);
    zData = data(:,3);

    rngVals = [max(xData) - min(xData), ...
               max(yData) - min(yData), ...
               max(zData) - min(zData)];

    hChord = min(rngVals, [], 2);   % smallest chord
    wChord = max(rngVals, [], 2);   % largest chord

    rad = 0.5 * (hChord + wChord^2 / (4*hChord));
end
