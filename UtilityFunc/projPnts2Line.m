function projPnt = projPnts2Line(linePnt, queryPnt, lineDir)
    % PROJPNTS2PLN Project points onto a plane.
    %
    %   Syntax
    %     projPnt = projPnts2Pln(planePnt, queryPnt, planeNormal)
    %
    %   Description
    %     Projects one or more query points onto a plane defined by a point
    %     and a normal vector.
    %
    %     For each query point Q, the projection onto the plane is computed
    %     by removing the component of (Q - planePnt) along the unit plane
    %     normal.
    %
    %         Qproj = Q - ((Q - planePnt) · n̂) n̂
    %
    %   Input Arguments
    %     planePnt
    %         1x3 double - Point lying on the plane.
    %     queryPnt
    %         1x3 or Nx3 double - Point or set of points to be projected onto the plane.
    %     planeNormal
    %         1x3 double - Normal vector defining the plane orientation.
    %         
    %   Output Arguments
    %     projPnt
    %         Same size as queryPnt
    %         Projection of the query point(s) onto the plane.
    %
    %   Example
    %     P0 = [0 0 0];
    %     n  = [0 0 1];
    %     Q  = [1 2 3];
    %
    %     Qproj = projPnts2Pln(P0, Q, n)
    %     % Returns [1 2 0]

    % Ensure direction is unit length
    lineDir = lineDir / norm(lineDir);

    % Vector from line point to query point
    vecLineToQuery = queryPnt - linePnt;

    % Scalar projection onto the line direction
    scalarProj = dot(vecLineToQuery, lineDir);

    % Compute projected point
    projPnt = linePnt + scalarProj * lineDir;
end
