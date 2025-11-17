function[pStart, pEnd] = calcLinePoints(point, direction, length, bias, scalingFactor)
    % calcLinePoints
    % Function to calculate the start and end points of a line segment from
    % computed point, direction, and length of an associated line geometry.
    % point         : 1x3 centroid on the line.
    % direction     : 1x3 direction vector of the line.
    % length        : length of the line segment calculated from
    %                 calcLineLength.
    % bias          : bias to plot the point along the desired length along
    %                 the computed line segment.
    %                 If bias = 0: point lies at the start of the line
    %                 segment.
    %                 If bias = 1: point lies at the end of the line segment
    %                 If bias = 0.5: point lies centered along the line
    %                 segment.
    %                 If bias = 0.25: point lies one-quarter of the way
    %                 along the line segment.
    %                 If bias = 0.75: point lies three-quarters of the way
    %                 along the line segment.
    % scalingFactor : Optional multiplier for scaling the length of the
    %                 line segment.
    %
    % pStart        : The start point of the line segment.
    % pEnd          : The end point of the line segment.

    arguments
        point (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        direction (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        length (1,1) double {mustBeFinite, mustBeReal, mustBePositive, mustBeNonNan, mustBeNonempty}
        bias (1,1) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(bias,0), ...
                   mustBeLessThanOrEqual(bias,1), mustBeNonNan, mustBeNonempty} = 0.5
        scalingFactor (1,1) double {mustBeFinite, mustBeReal, mustBePositive} = 1
    end

    % Normalize the direction vector
    direction = direction/norm(direction);

    % Scale the length
    length = length * scalingFactor;

    % Compute the line end points
    pStart = point - direction*bias*length;
    pEnd = point + direction*(1-bias)*length;

end