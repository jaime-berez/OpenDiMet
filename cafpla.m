% Calculates the amplification factor by finding the length of a plane
function [ampFac] = cafpla(X,Y,Z,scalingFactor)
    arguments
        X {mustBeColumn}
        Y {mustBeColumn}
        Z {mustBeColumn}
        scalingFactor {mustBeScalarOrEmpty} = 5 
    end
    points=combineData(X,Y,Z);
    

    %% Find the distances of point 1 to points 2,3,4
    % To find the length and width of a plane, calculate the distances from
    % any one point to the 3 other points. The max distance represents the
    % diagonal, the median represents the length, and the min represents
    % the width.
    distance(1)=norm(points(1)-points(2));
    distance(2)=norm(points(1)-points(3));
    distance(3)=norm(points(1)-points(4));
    
    %% Choose the amplification factor by uncommenting the lines below.
    %ampFac = distance(2)/distance(3);              %amplification based on the ratio of the length of width. Theoretically will always be > 1 and can be very large.
    %ampFac = scalingFactor * max(distance);        %amplification based on the diagonal of the rectangle
    ampFac = scalingFactor * median(distance)/8;   %amplification based on the length of the rectangle
    %ampFac = scalingFactor * min(distance);        %amplification based on the width of the rectangle
end