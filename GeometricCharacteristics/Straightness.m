function [straightness, residuals] = Straightness(feature)
%STRAIGHTNESS Function to compute straightness for supported geometries.

    if isa(feature, "Line")
        data = feature.data;
        point = feature.point;
        direction = feature.direction;

        Rz = getRz(direction); %calculate the rotation matrix
        data1 = data-point; %subtract the point to move the data to the origin
        data2 = data1*Rz; %rotate the data to align with the Z direction
        
        %At this point, the data is at the origin along the Z-axis. There could be
        %straightness deviations in both the X & Y directions, so use the L2 norm
        %to find the distance from each point to the line.
        
        % %residuals = norm(data2(:,1)+data2(:,2)); % =||X_i + Y_i||   L2 Norm
        % for i =1:length(data2)
        %     residuals(i) = norm(data2(i, 1:2)); % Calculate the L2 norm for each point
        % end
        residuals = sqrt(data2(:,1).^2 + data2(:,2).^2);
        straightness = range(residuals);

    else
        error("Straightness:UnsupportedGeometry", ...
            "Straightness is only implemented for Line. Got feature of type '%s'", class(feature))
    end
end



