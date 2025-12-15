% Function to amplify the roundness deviation of data from a circle.
% Requires a direction; do not use for spheres.

function [cData,colors] = ampCircularity(data,poi,dir,rad,ampFac,colorMap)
    arguments
        data (:,3) {mustBeMatrix} %matrix of data points
        poi (1,3) {mustBeRow} %center point
        dir (1,3) {mustBeRow} %direction unit vector
        rad (1,1) {mustBePositive} %associated radius
        ampFac (1,1) {mustBePositive} %Amplification factor
        colorMap (256,3) {mustBeMatrix} = colormap(turbo) %colormap matrix
    end

% Transform the circle by translating to the origin and rotating to the XY
% plane
    %data1 = data-mean(data);
    data1 = data-poi; %translate to the origin
    Rz = getRz(dir);
    data2= data1*Rz; %rotate to the XY plane

% Calculate the radial distance of each point to the center
    %radDis = sqrt(data2(:,1).^2+data2(:,2).^2+data(:,3).^2);
    radDis = sqrt(data2(:,1).^2+data2(:,2).^2);

% Calculate the radial distance of each point from the associated circle.
% Positive values are closer to MCC, and negative values are closer to MIC.
    asscRadDis = radDis-rad;

% Calculate the vector from the center to each point
    % theta = zeros(length(data),1);
    vectors = zeros(size(data));
    % for i=1:length(data)
    %     theta(i) = acos(dot(data2(i,:),[1,0,0])/(norm(data2(i,:)*norm([1,0,0]))));
    %     R = [cos(theta(i)) -sin(theta(i)) 0; sin(theta(i)) cos(theta(i)) 0; 0 0 1];
    %     vectors(i,:) = [1,0,0]*R;
    % end
    for i=1:length(data)
        vectors(i,:) = data2(i,:)/norm(data2(i,:));
    end
    
% Calculate the minimum and maximum values
    minR = min(asscRadDis);
    maxR = max(asscRadDis);

% Compute values between 0 and 1 for each point to map colors to each point
    if abs(minR) > abs(maxR) %if the MIC is further from the associated radius than the MMC
        cRange = 2*abs(minR);
        values = (asscRadDis-minR)./(cRange);
        %disp('min based range');
    else %else the MCC is further from the associated radius than the MIC
        cRange = 2*abs(maxR);
        values = (maxR-asscRadDis)./(cRange);
        %disp('max based range');
    end

    colors = colorMap(round(values*255)+1,:); %matrix of color values corresponding to the amount of error at each point

% Amplify the data
    data3 = ((values-0.5).*vectors.*ampFac)+data2;
    %The range of values is from 0 to 1. Subtracting 0.5 moves the range from
    %-0.5 to +0.5. This allows the data to be scaled both inwards and
    %outwards from the center, and ensures the points without error are not
    %scaled.

% Revert the transformations
    %cData = data3/Rz+mean(data);
    cData = data3/Rz+poi;
end
