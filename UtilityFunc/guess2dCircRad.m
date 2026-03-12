function rad = guess2dCircRad(data)
    % GUESS2DCIRCRAD Estimate the radius of a circle from 2D coordinate data.
    %
    %   Syntax
    %     rad = guess2dCircRad(data)
    %
    %   Input Arguments
    %     data - Measured 2D coordinate data (typically projected into a plane)
    %       Nx2 or Nx3 double matrix
    %
    %   Output Arguments
    %     rad - Estimated circle radius used as an initial guess for fitting
    %       scalar double
    %
    %   Example
    %     rad = guess2dCircRad(data);

    xData = data(:,1);
    yData = data(:,2);

    rngX = max(xData) - min(xData);
    rngY = max(yData) - min(yData);

    rngVals = [max([rngX, 1e-50]), max([rngY, 1e-50])];

    hChord = min(rngVals, [], 2);   % smaller chord
    wChord = max(rngVals, [], 2);   % larger chord

    rad = 0.5 * (hChord + wChord^2 / (4*hChord));
end
