function [dia, residual, resnorm] = fitStraightness(data, pnt, dir)
    % FITSTRAIGHTNESS Fit a minimum containing cylinder radius for straightness evaluation.
    %
    %   Syntax
    %     [dia, residual, resnorm] = fitStraightness(data)
    %     [dia, residual, resnorm] = fitStraightness(data, pnt)
    %     [dia, residual, resnorm] = fitStraightness(data, pnt, dir)
    %
    %   Input Arguments
    %     data - Measured 3D point coordinates
    %       Nx3 numeric matrix
    %     pnt - Reference point on the associated line
    %       1x3 numeric vector
    %     dir - Direction vector of the associated line
    %       1x3 numeric vector
    %
    %   Output Arguments
    %     dia - Evaluated straightness diameter
    %       scalar double
    %     residual - Residual vector from the straightness fit
    %       Nx1 double vector
    %     resnorm - Sum of squared residuals
    %       scalar double
    %
    %   Example
    %     [dia, residual, resnorm] = fitStraightness(data);
    %     [dia, residual, resnorm] = fitStraightness(data, pnt, dir);
    arguments
        data (:,3) {mustBeNumeric}
        pnt (1,3) {mustBeNumeric} = mean(data)
        dir (1,3) {mustBeNumeric} = [1 1 1]/norm([1 1 1])
    end

    % [xData, yData, zData] = separateData(data);
    xData = data(:,1);
    yData = data(:,2);
    zData = data(:,3);

    % Format the objective function
    u = dir(3)*(yData - pnt(2)) - dir(2)*(zData - pnt(3));
    v = dir(1)*(zData - pnt(3)) - dir(3)*(xData - pnt(1));
    w = dir(2)*(xData - pnt(1)) - dir(1)*(yData - pnt(2));
    aNorm = sqrt(dir(1)^2 + dir(2)^2 + dir(3)^2);
    f = sqrt(u.^2 + v.^2 + w.^2);
    fcn = @(q) f - q;

    % Guess the "radius" of the cylinder containing all the points of the line
    Rz = getRz(dir);
    data0 = data - pnt;
    data1 = data0 * Rz;
    rad = guess2dCircRad(data1);

    % Perform association
    [answ, residual, resnorm, info] = LM.solve(fcn, rad, MaxIter = 5000, StepTol = 1e-20);
    dia = 2 * answ;
end
