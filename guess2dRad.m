function [radius] = guess2dRad(data)
    % Estimate the radius of a circle from 2D coordinate data
    xD=data(:,1);   
    yD=data(:,2);

    rangeX = max(xD) - min(xD);
    rangeY = max(yD) - min(yD);

    ranges = [max([rangeX, 1e-50]), max([rangeY, 1e-50])];
    %ranges=[max([range(xD) 1e-50]),max([range(yD) 1e-50])]; %compute the range of data in each direction
    height=min(ranges,[],2); %the height chord is the smallest range
    width=max(ranges,[],2);  %the width chord is the largest range
    radius=.5*(height+width^2/(4*height));  %equation that relates the radius to the height and width chords
end