function [xData, yData, zData] = separateData(data)
    % This function breaks an Nx3 matrix into separate column arrays for X, Y & Z data
    xData = data(:,1);
    yData = data(:,2);
    zData = data(:,3);
end
