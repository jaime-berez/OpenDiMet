function [smallR, bigR, height] = calcConeRadii(data, pnt, apex, dir, ang, dist)
    % CALCCONERADII Compute end radii and axial extent of a fitted cone from 3D coordinate data.
    %
    %   Syntax
    %     [smallR, bigR, height] = calcConeRadii(data, pnt, apex, dir, ang, dist)
    %
    %   Input Arguments
    %     data - Measured 3D point coordinates
    %       Nx3 double matrix
    %     pnt - Point on the cone axis closest to the data centroid
    %       1x3 double vector
    %     apex - Cone apex location
    %       1x3 double vector
    %     dir - Unit direction vector of the cone axis
    %       1x3 double vector
    %     ang - Cone semi-angle
    %       1x1 double (radians)
    %     dist - Orthogonal distance from the axis point to the cone surface
    %       1x1 double
    %
    %   Output Arguments
    %     smallR - Cone radius at the end closest to the apex
    %       1x1 double
    %     bigR - Cone radius at the end farthest from the apex
    %       1x1 double
    %     height - Axial extent of the cone based on the data distribution
    %       1x1 double
    %
    %   Example
    %     [smallR, bigR, height] = calcConeRadii(data, pnt, apex, dir, ang, dist);

    arguments
        data (:,3)
        pnt (1,3)
        apex (1,3)
        dir (1,3)
        ang (1,1)
        dist (1,1)
    end

    % Translate to origin then rotate to align with Z axis
    data0 = data - pnt;
    R = rotMatA2Z(dir);
    data1 = data0 * R;

    % Z extents and height
    zMin = min(data1(:,3), [], 1);
    zMax = max(data1(:,3), [], 1);
    height = max(data1(:,3)) - min(data1(:,3));

    % Geometry helper quantities
    O = [0, 0, 0];
    m = dist * cos(ang);
    n = dist * sin(ang);
    Q = O - n * [0, 0, 1];

    apex0 = apex - pnt;
    apex1 = apex0 * R;

    h1 = norm(apex1(3) - zMin);
    smallR = h1 * tan(ang);

    bigR = m + (zMax + n) * tan(ang);

    if smallR < 0
        warning("Small radius is negative. Expected positive value");
    end
    if bigR < 0
        warning("Big radius is negative. Expected positive value");
    end
end
