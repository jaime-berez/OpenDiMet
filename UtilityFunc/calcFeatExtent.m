function [pnt1, pnt2] = calcFeatExtent(pnt, dir, len, bias, scalingFactor)
    % calcLinePoints
    % Compute start/end points of a line segment from:
    %   pnt  : 1x3 point on the line (typically centroid)
    %   dir  : 1x3 direction vector of the line
    %   len  : segment length (e.g., from calcLineLength)
    %   bias : where pnt lies along the segment (0=start, 1=end, 0.5=center)
    %   scalingFactor : optional multiplier for len

    arguments
        pnt (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dir (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        len (1,1) double {mustBeFinite, mustBeReal, mustBePositive, mustBeNonNan, mustBeNonempty}
        bias (1,1) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(bias,0), ...
                   mustBeLessThanOrEqual(bias,1), mustBeNonNan, mustBeNonempty} = 0.5
        scalingFactor (1,1) double {mustBeFinite, mustBeReal, mustBePositive} = 1
    end

    % Normalize the direction vector
    dir = dir / norm(dir);

    % Scale the length
    len = len * scalingFactor;

    % Compute the line end points
    pnt1 = pnt - dir * bias * len;
    pnt2   = pnt + dir * (1 - bias) * len;
end
