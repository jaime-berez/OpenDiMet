function [pnt, dir, ang, dist, apex] = formatConeOutput(ansVec, cent)

    rawPnt = [ansVec(1), ansVec(2), ansVec(3)] + cent;
    dir = -[ansVec(4), ansVec(5), ansVec(6)];
    ang = ansVec(7);
    rawDist = ansVec(8);

    dir = dir / norm(dir);   % convert to unit vector

    % Ensure angle is positive
    if ang < 0
        ang = -ang;
        dir = -dir;
    end

    % Normalization of angle (Shakarji, 1998 convention)
    if ang > pi
        ang = mod(ang, pi);
        dir = -dir;
    end
    if ang > pi/2
        ang = pi - ang;
    end

    % Compute axis point closest to centroid
    pnt = projPnts2Line(rawPnt, cent, dir);

    % Compute orthogonal distance to surface at pnt and apex location
    m = rawDist * cos(ang);
    n = rawDist * sin(ang);

    v = n + (m / tan(ang));
    apex = rawPnt - v * dir;

    pnt2a = norm(pnt - apex);
    dist = pnt2a * sin(ang);

    % Ensure direction faces toward cone opening
    n = dot(apex - pnt, dir);
    if n > 0
        dir = -dir;
    end
end