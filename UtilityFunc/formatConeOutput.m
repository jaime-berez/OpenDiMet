function [point,direction,angle,distance,apex] = formatConeOutput(ansMat,centroid)
    rawPoint = [ansMat(1),ansMat(2),ansMat(3)]+centroid;
    direction = -[ansMat(4),ansMat(5),ansMat(6)];
    angle = ansMat(7);
    rawDistance = ansMat(8);

    direction=direction/norm(direction); %convert vector to unit vector
    
    % Make sure the angle is positive
    if angle < 0 
        angle=-angle;
        direction = -direction;
    end
    
    % Normalization of the angle based on Shakraji, 1998
    if angle > pi
        angle=mod(angle,pi);
        direction=-direction;
    end
    if angle > pi/2
        angle=pi-angle;
    end
    
    % Compute the point on the axis closest to the centroid
    point = pp2l(rawPoint,centroid,direction);

    % Compute the distance to the surface, orthogonal to the surface, at the
    % Point closest to the centroid
    [distance,apex] = checkDistance(rawPoint,point,direction,rawDistance,angle);

    % Verify that the direction is positive facing the opening of the cone
    n = (apex-point)/direction;
    if n > 0
        direction = -direction;
    end
end