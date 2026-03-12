function pts = calcPntsOnCirc(pnt, dir, dia, nFaces)
    % CALCPNTSONCIRC Compute points on a circle in 3D space from center, normal, and diameter.
    %
    %   Syntax
    %     pts = calcPntsOnCirc(pnt, dir, dia)
    %     pts = calcPntsOnCirc(pnt, dir, dia, nFaces)
    %
    %   Input Arguments
    %     pnt - Center point of the circle
    %       1x3 double vector
    %     dir - Unit normal vector of the circle plane
    %       1x3 double vector
    %     dia - Circle diameter
    %       scalar double
    %     nFaces - Number of points used to discretize the circle
    %       positive scalar double
    %
    %   Output Arguments
    %     pts - Points sampled on the circle
    %       Nx3 double matrix
    %
    %   Example
    %     pts = calcPntsOnCirc(pnt, dir, dia);
    %     pts = calcPntsOnCirc(pnt, dir, dia, 50);
    arguments
        pnt (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dir (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dia (1,1) double {mustBeFinite, mustBeReal}
        nFaces (1,1) double {mustBeFinite, mustBeReal, mustBePositive} = 27
    end

    t = linspace(0, 2*pi, nFaces);

    xC = (dia/2) * sin(t);
    yC = (dia/2) * cos(t);
    zC = zeros(1, nFaces); % circle is flat at origin in local frame

    % Compute the rotation matrix and rotate the circle points
    Rz = rotMatA2Z(dir);

    pts = [xC', yC', zC'];
    ptsR = pts / (Rz);

    % Break the circle points into individual X,Y,Z vectors and translate
    xW = (ptsR(:,1)) + pnt(1);
    yW = (ptsR(:,2)) + pnt(2);
    zW = (ptsR(:,3)) + pnt(3);

    pts = [xW yW zW];
end
