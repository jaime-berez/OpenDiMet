function [pnt1, pnt2] = calcFeatExtent(pnt, dir, len, bias, scalingFactor)
    % CALCFEATEXTENT Compute the start and end points of a feature axis segment.
    %
    %   Syntax
    %     [pnt1, pnt2] = calcFeatExtent(pnt, dir, len)
    %     [pnt1, pnt2] = calcFeatExtent(pnt, dir, len, bias)
    %     [pnt1, pnt2] = calcFeatExtent(pnt, dir, len, bias, scalingFactor)
    %
    %   Input Arguments
    %     pnt - Reference point on the feature axis
    %       1x3 double vector
    %     dir - Direction vector of the feature axis
    %       1x3 double vector
    %     len - Length of the axis segment
    %       positive scalar double
    %     bias - Position of pnt along the segment
    %       scalar double in the range [0, 1]
    %       0   → pnt at start of segment
    %       0.5 → pnt at center of segment
    %       1   → pnt at end of segment
    %     scalingFactor - Optional multiplier applied to the segment length
    %       positive scalar double
    %
    %   Output Arguments
    %     pnt1 - Start point of the axis segment
    %       1x3 double vector
    %     pnt2 - End point of the axis segment
    %       1x3 double vector
    %
    %   Example
    %     [p1, p2] = calcFeatExtent(pnt, dir, 50);
    %     [p1, p2] = calcFeatExtent(pnt, dir, 50, 0.5, 1.2);

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
