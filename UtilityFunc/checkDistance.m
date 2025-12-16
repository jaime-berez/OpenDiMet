function [ukDistance, apex] = checkDistance(kPoint,ukPoint, direction, kDistance, semiangle)
    %   kPoint:   a point in space (x,y,z) with a known distance (from association)
    %   ukPoint:  a point in space with an unknown distance (solves for this
    %   distance)
    %   direction:    unit vector of the cone axis
    %   kDistance:    the distance from kPoi to the surface of the cone, orthogonal to
    %   the surface
    %   semiangle:    semiangle of the cone
    %   
    %   distance:   distance from ukPoi to the cone surface, orthogonal to the
    %   surface
    %   apex: apex point of the cone
    
    m = kDistance*cos(semiangle);   % distance from kPoi to the surface of the cone, orthogonal to the axis
    n = kDistance*sin(semiangle);   % n is the third side of the right triangle formed by dis and m
    
    v = n + (m/tan(semiangle));   % this is the distance from kPoi to the apex of the cone
    apex = kPoint-v*direction;      % coordinates for the apex of the cone
    uk2a = norm(ukPoint-apex);  % magnitude of the distance from ukPoi to the apex
    
    ukDistance = uk2a*sin(semiangle);   % distance from the ukPoi to the cone surface, orthogonal to the surface

end