% This function is useful for calculating the residuals for straightness if the
% plane has been previously associated using SVD or a different analytical
% method rather than using an association algorithm

function [residuals] = calcStraightnessResiduals(data,point,direction)

    Rz = rotMatA2Z(direction); %calculate the rotation matrix
    data1 = data-point; %subtract the point to move the data to the origin
    data2 = data1*Rz; %rotate the data to align with the Z direction
    
    %At this point, the data is at the origin along the Z-axis. There could be
    %straightness deviations in both the X & Y directions, so use the L2 norm
    %to find the distance from each point to the line.
    
    
    % Radial distance in XY-plane = perpendicular distance to line
    residuals = vecnorm(data2(:,1:2), 2, 2);  % N×1
end