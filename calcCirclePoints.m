function [points] = calcCirclePoints(point, direction, diameter,faces)
    arguments
        point (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        direction (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        diameter (1,1) double {mustBeFinite, mustBeReal}
        faces (1,1) double {mustBeFinite, mustBeReal, mustBePositive} = 27
    end
    t=linspace(0,2*pi,faces);
    X=(diameter/2)*sin(t);
    Y=(diameter/2)*cos(t);
    Z=zeros(1,faces); %z should be zero at this point since the circle is flat at the origin

    % Compute the rotation matrix and rotate the circle points
    Rz=getRz(direction);
    points = [X',Y',Z'];
    points1 = points/(Rz);

    %break the circle points into individual X,Y,Z matrices
    X=((points1(:,1))+point(1));
    Y=((points1(:,2))+point(2));
    Z=((points1(:,3))+point(3));
    points = combineData(X,Y,Z);
end