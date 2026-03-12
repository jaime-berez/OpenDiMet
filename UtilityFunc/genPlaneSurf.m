function [V, F] = genPlaneSurf(data, pnt, dir, scalingFactor)
    % GENPLANESURF Generate a triangulated plane patch mesh.
    %
    %   Syntax
    %     [V, F] = genPlaneSurf(data, pnt, dir)
    %     [V, F] = genPlaneSurf(data, pnt, dir, scalingFactor)
    %
    %   Input Arguments
    %     data - Measured 3D point coordinates
    %       Nx3 double matrix
    %     pnt - Reference point on the plane
    %       1x3 double vector
    %     dir - Unit normal vector of the plane
    %       1x3 double vector
    %     scalingFactor - Optional multiplier used to expand the plane patch
    %       positive scalar double
    %
    %   Output Arguments
    %     V - Vertex coordinates of the plane patch
    %       4x3 double matrix
    %     F - Triangle face connectivity of the plane patch
    %       2x3 double matrix
    %
    %   Example
    %     [V, F] = genPlaneSurf(data, pnt, dir);
    %     [V, F] = genPlaneSurf(data, pnt, dir, 1.1);

    arguments
        data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        pnt  (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dir  (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        scalingFactor (1,1) double {mustBeFinite, mustBeReal, mustBePositive} = 1.10
    end

    [X, Y, Z] = calcPlaneBoundingPnts(data, pnt, dir, scalingFactor);
    Vraw = [X(:), Y(:), Z(:)];     % 4x3

    % Reorder corners around perimeter
    n = dir(:).';
    n = n / norm(n);

    % Choose a stable in-plane basis u, v
    % Pick a vector not parallel to n
    if abs(n(1)) < 0.9
        tmp = [1 0 0];
    else
        tmp = [0 1 0];
    end
    u = cross(n, tmp); u = u / norm(u);
    v = cross(n, u);   
    
    % Project corners to 2D plane coordinates
    c = mean(Vraw, 1);
    d = Vraw - c;                      % 4x3
    x2 = d*u.';                        % 4x1
    y2 = d*v.';                        % 4x1

    ang = atan2(y2, x2);               % 4x1
    [~, order] = sort(ang, 'ascend');  % cyclic order
    V = Vraw(order, :);                % 4x3 ordered

    % Two triangles covering the quad
    F = [1 2 3;
         1 3 4];
end