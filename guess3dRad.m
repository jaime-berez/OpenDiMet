function [radius] = guess3dRad(data)
    % Estimate the radius of a circle or sphere from 3D coordinate data
    [xD,yD,zD]=separateData(data);
    %ranges = [range(xD),range(yD),range(zD)]; %compute the range of data in each direction
    ranges = [max(xD) - min(xD), max(yD) - min(yD), max(zD) - min(zD)];
    height=min(ranges,[],2); %the height chord is the smallest range
    width=max(ranges,[],2);  %the width chord is the largest range
    radius = 0.5*(height+width^2/(4*height)); %equation that relates the radius to the height and width chords
end