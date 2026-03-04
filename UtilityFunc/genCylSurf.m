function [V, F] = genCylSurf(pnt, dir, radius, height, nTheta)
%GENCYLSURF Generate a triangulated cylinder surface mesh.
%   [V,F] = genCylSurf(pnt, dir, radius, height, nTheta, capped)
%   returns vertices V (N×3) and triangle faces F (M×3).
%
%   pnt    : 1×3 point at cylinder center (mid-height) on the axis
%   dir    : 1×3 axis direction (need not be unit; will be normalized)
%   radius : scalar cylinder radius (>=0)
%   height : scalar cylinder height (>=0)
%   nTheta : number of circumferential samples

    arguments
        pnt    (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dir    (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        radius (1,1) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonnegative}
        height (1,1) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonnegative}
        nTheta (1,1) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBePositive} = 50
    end

    % Normalize direction
    dirNorm = norm(dir);
    if dirNorm < eps
        error('genCylSurf:badDir', 'Axis direction must be non-zero.');
    end
    dir = dir / dirNorm;
    nTheta = max(3, round(nTheta));

    % Canonical cylinder along +Z, centered at origin
    theta = linspace(0, 2*pi, nTheta+1);
    theta(end) = [];  % remove duplicate seam point

    x = radius * cos(theta);
    y = radius * sin(theta);
    zTop = +height/2;
    zBot = -height/2;

    Vbot = [x(:), y(:), zBot*ones(nTheta,1)];
    Vtop = [x(:), y(:), zTop*ones(nTheta,1)];

    % Vertices: bottom ring then top ring
    Vlocal = [Vbot; Vtop];                 % (2*nTheta)×3

    % Side triangulation
    F = zeros(2*nTheta, 3);

    for i = 1:nTheta
        i2 = i + 1;
        if i == nTheta, i2 = 1; end

        b1 = i;
        b2 = i2;
        t1 = i + nTheta;
        t2 = i2 + nTheta;

        % Two triangles per quad strip
        F(2*i-1, :) = [b1, b2, t2];
        F(2*i,   :) = [b1, t2, t1];
    end

    % Rotate +Z to dir and translate to pnt
    R = rotMatA2BR([0 0 1], dir);
    V = (Vlocal * R.') + pnt;

    %Nested helper functions
    % function R = rotFromTo(a, b)
    %     % Rotation matrix that maps unit vector a -> unit vector b.
    %     % Robust for parallel and antiparallel cases.
    % 
    %     a = a(:); a = a / norm(a);
    %     b = b(:); b = b / norm(b);
    % 
    %     v = cross(a, b);
    %     c = dot(a, b);
    %     s = norm(v);
    % 
    %     if s < 1e-12
    %         % Parallel or antiparallel
    %         if c > 0
    %             R = eye(3);
    %         else
    %             % 180° rotation about any axis orthogonal to a.
    %             [~, idx] = min(abs(a));
    %             tmp = zeros(3,1); tmp(idx) = 1;
    %             axis = cross(a, tmp);
    %             axis = axis / norm(axis);
    % 
    %             R = axang2rotm(axis, pi);
    %         end
    %         return;
    %     end
    % 
    %     axis  = v / s;
    %     angle = atan2(s, c);
    %     R = axang2rotm(axis, angle);
    % end
    % 
    % function R = axang2rotm(axis, angle)
    %     % Rodrigues rotation formula from axis-angle.
    %     x = axis(1); y = axis(2); z = axis(3);
    % 
    %     K = [ 0 -z  y;
    %           z  0 -x;
    %          -y  x  0 ];
    % 
    %     R = eye(3) + sin(angle)*K + (1-cos(angle))*(K*K);
    % end
end