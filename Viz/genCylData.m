function data = genCylData(baseCenter, dir, dia, height, nTheta, nZ)
% GENCYLDATA Generate synthetic cylinder surface point cloud.
%
%   data = genCylData(baseCenter, dir, dia, height)
%   data = genCylData(baseCenter, dir, dia, height, nTheta, nZ)
%
%   baseCenter : 1x3 point at center of bottom circular rim
%   dir        : 1x3 cylinder axis direction
%   dia        : cylinder diameter
%   height     : cylinder height along +dir
%   nTheta     : number of points around each ring
%   nZ         : number of axial layers

    arguments
        baseCenter (1,3) double {mustBeFinite, mustBeReal}
        dir        (1,3) double {mustBeFinite, mustBeReal}
        dia        (1,1) double {mustBeFinite, mustBePositive}
        height     (1,1) double {mustBeFinite, mustBePositive}
        nTheta     (1,1) double {mustBeFinite, mustBePositive} = 16
        nZ         (1,1) double {mustBeFinite, mustBePositive} = 8
    end

    dir = dir/norm(dir);
    radius = dia/2;

    % Build orthonormal basis (u, v, dir)

    % We need two vectors perpendicular to dir, because a cylinder cross-section is a 
    % circle in the plane normal to the axis.
    % To construct those perpendicular directions, we start with some vector ref that is not parallel to dir. 
    % Why the dot check?
    % If dir is close to [1 0 0], then using [1 0 0] as ref is bad because the cross product would be tiny or zero
    % So if dir is too aligned with x, we switch to [0 1 0]
    % This avoids numerical instability.

    if abs(dot(dir, [1 0 0])) < 0.9
        ref = [1 0 0];
    else
        ref = [0 1 0];
    end

    u = cross(dir, ref); % vector perpendicular to dir
    u = u/norm(u);       % unit vector perpendicular to cylinder axis

    v = cross(dir, u); % vector perpendicular to dir and u
    v = v/norm(v);

    theta = linspace(0, 2*pi, round(nTheta)+1);
    theta(end) = [];

    zVals = linspace(0, height, round(nZ));

    data = zeros(numel(theta) * numel(zVals), 3);
    k = 1;

    for i = 1:numel(zVals)
        z = zVals(i);
        for j = 1:numel(theta)
            th = theta(j);

            ringOffset = radius*cos(th)*u + radius*sin(th)*v;
            axialOffset = z * dir;

            data(k, :) = baseCenter + ringOffset + axialOffset;
            k = k + 1;
        end
    end
end