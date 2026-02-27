function projPnt = projPnts2Pln(planePnt, queryPnt, planeNormal)
% PROJPNTS2PLN
% Project one or more query points onto a plane.
%
%   Plane is defined by:
%       planePnt    : 1x3 point on the plane
%       planeNormal : 1x3 normal vector to the plane
%
%   queryPoint can be:
%       1x3  : single point
%       Nx3  : multiple points
%
%   projPoint has the same size as queryPoint:
%       projPnt(i,:) = projection of queryPnt(i,:) onto the plane
%
% Geometric formula:
%   Let n_hat be the unit plane normal.
%   For each query point Q,
%       d        = (Q - planePoint) · n_hat   (signed distance)
%       Q_proj   = Q - d * n_hat
%
% Example:
%   P0 = [0 0 0];              % plane point
%   n  = [0 0 1];              % plane normal (xy-plane)
%   Q  = [1 2 3];              % point above plane
%   Qp = projPnts2Pln(P0, Q, n);   % -> [1 2 0]

    arguments
        planePnt  (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        queryPnt  (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        planeNormal (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
    end

    % Normalize the plane normal
    nNorm = norm(planeNormal);
    if nNorm == 0
        error('projPnts2Plane:ZeroNormal', ...
              'Plane normal vector must be non-zero.');
    end
    nHat = planeNormal / nNorm;  % 1x3 unit normal

    % Vector from plane point to query point
    vecPlaneToQuery = queryPnt - planePnt;  % Nx3 

    % Signed distance along the normal: Nx1
    dist = vecPlaneToQuery * nHat.';   % dot for each row

    % Subtract the normal component to get the projection: Nx3
    projPnt = queryPnt - dist .* nHat;  
end