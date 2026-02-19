% Calculates the amplification factor by finding the length of a plane
function ampFac = cafpla(X, Y, Z, scaleFac)
    arguments
        X {mustBeColumn}
        Y {mustBeColumn}
        Z {mustBeColumn}
        scaleFac {mustBeScalarOrEmpty} = 5
    end

    pts = combineData(X, Y, Z);

    %% Find the distances of point 1 to points 2,3,4
    % To find the length and width of a plane, calculate the distances from
    % any one point to the 3 other points. The max distance represents the
    % diagonal, the median represents the length, and the min represents
    % the width.

    dist(1) = norm(pts(1) - pts(2));
    dist(2) = norm(pts(1) - pts(3));
    dist(3) = norm(pts(1) - pts(4));

    %% Choose the amplification factor by uncommenting the lines below.
    %ampFac = dist(2)/dist(3);
    %ampFac = scaleFac * max(dist);
    ampFac = scaleFac * median(dist) / 8;
    %ampFac = scaleFac * min(dist);
end
