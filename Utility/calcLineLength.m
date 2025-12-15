function [len]=calcLineLength(data, point, direction, scalingFactor)
    % This function calculates the length a line segment.
    % Lines exist from -INF to INF. However, it is only necessary to find the
    % length of the line segment represented by the data. This function returns
    % that length multiplied by a scaling factor.

    data1=data-point; %translate the data to the origin
    Rz=getRz(direction); %rotation matrix;
    data2=data1*Rz; %rotate the data to align with the z axis

    mi=min(data2); %smallest Z value of the data. (Lowest data point)
    mx=max(data2); %largest Z values of the data. (Highest data point)

    %height=range(data2(:,3)); %height of the data from lowest to highest point
    height = max(data2(:,3)) - min(data2(:,3));
    len = height*scalingFactor; %the length of the line is the height of the data multiplied by the scaling factor
    
end