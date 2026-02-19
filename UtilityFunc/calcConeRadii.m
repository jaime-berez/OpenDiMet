function [rSmall, rBig, h] = calcConeRadii(data, pnt, apex, dir, ang, dist)
    % data: nx3 matrix of row-vector coordinate points
    % pnt: 1x3 point in space along the axis of the cone, closest to centroid
    % apex: 1x3 point in space describing the tip of the cone
    % dir: 1x3 direction cosines of the axis
    % ang: scalar value for the semi-angle of the cone in radians
    % dist: scalar orthogonal distance from pnt to the cone surface
    %
    % rSmall: radius closest to the apex
    % rBig:   radius furthest from the apex
    % h:      cone height based on point distribution

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
    Rz = getRz(dir);
    data1 = data0 * Rz;

    % Z extents and height
    zMin = min(data1(:,3), [], 1);
    zMax = max(data1(:,3), [], 1);
    h = max(data1(:,3)) - min(data1(:,3));

    % Geometry helper quantities
    O = [0, 0, 0];
    m = dist * cos(ang);
    n = dist * sin(ang);
    Q = O - n * [0, 0, 1];

    apex0 = apex - pnt;
    apex1 = apex0 * Rz;

    h1 = norm(apex1(3) - zMin);
    rSmall = h1 * tan(ang);

    rBig = m + (zMax + n) * tan(ang);

    if rSmall < 0
        warning("Small radius is negative. Expected positive value");
    end
    if rBig < 0
        warning("Big radius is negative. Expected positive value");
    end
end
