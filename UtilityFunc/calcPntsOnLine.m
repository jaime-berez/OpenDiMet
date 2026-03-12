function pnts = calcPntsOnLine(pnt, dir, shift)
    % CALCPNTSONLINE Generate points along a line from a base point and direction.
    %
    %   Syntax
    %     pnts = calcPntsOnLine(pnt, dir, shift)
    %
    %   Input Arguments
    %     pnt - Base point on the line
    %       1x3 double vector
    %     dir - Direction vector of the line
    %       1x3 double vector (normalized internally)
    %     shift - Offsets along the line direction
    %       Nx1 double vector
    %
    %   Output Arguments
    %     pnts - Generated points along the line
    %       Nx3 double matrix
    %
    %   Example
    %     pnt   = [0 0 0];
    %     dir   = [1 0 0];
    %     shift = linspace(-5,5,11)';
    %     pnts  = calcPntsOnLine(pnt, dir, shift);

    arguments
        pnt (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dir (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        shift (:,1) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        % shift is enforced as column; 1xN will be reshaped automatically
    end

    % Normalize the direction vector
    nDir = norm(dir);
    if nDir == 0
        error('calcPntsOnLine:ZeroDirection', ...
            'Direction vector must be non-zero.');
    end
    dir = dir / nDir;  % 1x3 unit direction

    % Compute points: (N x 1)*(1 x 3) => (N x 3)
    pnts = shift * dir + pnt;  % implicit expansion for + pnt (1x3)
end