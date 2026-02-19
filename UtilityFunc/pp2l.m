function projPoint = pp2l(linePoint, queryPoint, lineDir)
% (P)roject a (P)oint (2) to a (L)ine
% Projects a query point onto a 3D line defined by:
%   linePoint : a point on the line
%   lineDir   : unit direction vector of the line

    % Ensure direction is unit length
    lineDir = lineDir / norm(lineDir);

    % Vector from line point to query point
    vecLineToQuery = queryPoint - linePoint;

    % Scalar projection onto the line direction
    scalarProj = dot(vecLineToQuery, lineDir);

    % Compute projected point
    projPoint = linePoint + scalarProj * lineDir;
end
