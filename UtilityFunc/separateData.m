function [xD,yD,zD] = separateData(data)
    % This function breaks a matrix of row vectors into separate arrays for X Y & Z data
    xD = data(:,1);
    yD = data(:,2);
    zD = data(:,3);
end