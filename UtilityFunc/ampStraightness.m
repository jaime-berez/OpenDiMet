%% Function to amplify the straightness deviation of data from a line
% Amplify the flatness error of points by spreading the points away from
% the idea line

function [fData,colors] = ampStraightness(data,residual,dir,ampFac,colorMap)
    arguments
        data (:,3) {mustBeMatrix}
        residual (:,1) {mustBeColumn}
        dir (1,3) {mustBeRow}
        ampFac (1,1) {mustBePositive}
        colorMap (256,3) {mustBeMatrix} = colormap(turbo)
    end

%% Calculate statistical parameters of the residuals
    maxR=max(residual);
    minR=min(residual);
    meanR=mean(residual);
    rangeR=range(residual);

%% Compute values between 0 and 1 for each residual. This will be used to map the residuals to specific colors
    if abs(minR) > abs(maxR)
        fRange = 2*abs(minR); %the full range is from -abs(min) to abs(min)
        values = (residual-minR)./(fRange);
        %disp('min based range');
    else
        fRange = 2*abs(maxR); %the full range is from -abs(max) to abs(max)
        values = (residual-minR)./(fRange);
        %disp('max based range');
    end

    colors = colorMap(round(values*255)+1,:);
    %fData = data+(values-.5)*ampFac*dir;
    
    %Use pp2l to project the points onto the ideal line
    %projPois = pp2l(data,mean(data),dir);
    cent = mean(data);
    projPois = NaN(size(data));
    for i =1: length(data)
        projPois(i,1:3) = pp2l(data(i,1:3),cent,dir);
    end

    %Calculate the vectors from each point to the corresponding projected
    %point
    vectors = data - projPois; % Calculate the vectors from each point to the projected point
    fData = data + (values)*ampFac.*vectors; % Amplify the deviation based on the calculated values
