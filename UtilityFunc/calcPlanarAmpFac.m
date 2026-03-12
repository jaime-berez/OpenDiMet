function ampFac = calcPlanarAmpFac(X, Y, Z, scaleFac)
    % CALCPLANARAMPFAC Compute amplification factor for planar form deviations.
    %
    %   Syntax
    %     ampFac = calcPlanarAmpFac(X, Y, Z)
    %     ampFac = calcPlanarAmpFac(X, Y, Z, scaleFac)
    %
    %   Input Arguments
    %     X - X-coordinates of plane corner points
    %       Nx1 double vector
    %     Y - Y-coordinates of plane corner points
    %       Nx1 double vector
    %     Z - Z-coordinates of plane corner points
    %       Nx1 double vector
    %     scaleFac - User-defined scaling factor controlling amplification
    %       scalar double
    %
    %   Output Arguments
    %     ampFac - Amplification factor used to exaggerate planar deviations
    %       scalar double
    %
    %   Example
    %     ampFac = calcPlanarAmpFac(X, Y, Z);
    %     ampFac = calcPlanarAmpFac(X, Y, Z, 10);
        arguments
        X {mustBeColumn}
        Y {mustBeColumn}
        Z {mustBeColumn}
        scaleFac {mustBeScalarOrEmpty} = 5
    end

    pts = [X Y Z];

    % Find the distances of point 1 to points 2,3,4
    % To find the length and width of a plane, calculate the distances from
    % any one point to the 3 other points. The max distance represents the
    % diagonal, the median represents the length, and the min represents
    % the width.

    dist(1) = norm(pts(1) - pts(2));
    dist(2) = norm(pts(1) - pts(3));
    dist(3) = norm(pts(1) - pts(4));

    % Choose the amplification factor by uncommenting the lines below.
    %ampFac = dist(2)/dist(3);
    %ampFac = scaleFac * max(dist);
    ampFac = scaleFac * median(dist) / 8;
    %ampFac = scaleFac * min(dist);
end
