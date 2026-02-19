function [ukDist, apex] = checkDistance(kPnt, ukPnt, dir, kDist, semiAng)
%CHECKDISTANCE Compute unknown cone distance + apex from a known point on cone.
%   kPnt    : known point on/near cone axis with known orthogonal distance
%   ukPnt   : point with unknown orthogonal distance to cone surface
%   dir     : unit vector of cone axis
%   kDist   : orthogonal distance from kPnt to cone surface
%   semiAng : cone semi-angle (radians)

    m = kDist*cos(semiAng);        % distance from kPnt to surface, orthogonal to axis
    n = kDist*sin(semiAng);        % third side of right triangle

    v = n + (m/tan(semiAng));      % distance from kPnt to apex along axis
    apex = kPnt - v*dir;           % apex coordinates
    uk2a = norm(ukPnt - apex);     % distance from ukPnt to apex

    ukDist = uk2a*sin(semiAng);    % orthogonal distance from ukPnt to cone surface
end
