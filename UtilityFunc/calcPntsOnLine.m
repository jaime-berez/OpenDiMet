function pnts = calcPntsOnLine(pnt, dir, shift)
% CALCPNTSONLINE
% Function to generate points along a line defined by a base point and direction.
%
%   pnt   : 1x3 point on the line (Base point)
%   dir   : 1x3 direction vector of the line (Does not need to be unit. Normalized inside.)
%   shift : 1xN or Nx1 offsets along the line
%
%   pnts  : Nx3 matrix of points, where
%           pnts(i,:) = pnt + shift(i) * dir_hat
%
% Example usage:
%   pnt   = [0 0 0];
%   dir   = [1 0 0];
%   shift = linspace(-5, 5, 11);
%   pnts  = calcPntsOnLine(pnt, dir, shift);

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