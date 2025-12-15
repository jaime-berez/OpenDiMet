%% Function to amplify the flatness deviation of data from a plane
% Amplify the flatness error of points by spreading the points away
% from the ideal plane.

function [fData,colors] = ampFlatness(data,residual,dir,ampFac,colorMap)
    arguments
        data (:,3) {mustBeMatrix}
        residual(:,1) {mustBeColumn}
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
        disp('min based range');
    else
        fRange = 2*abs(maxR); %the full range is from -abs(max) to abs(max)
        values = (residual-minR)./(fRange);
        disp('max based range');
    end

    colors = colorMap(round(values*255)+1,:);
    fData = data+(values-.5)*ampFac*dir;

%% Calculate a percentage value for each residual
% The percentage corresponds to redisual(i)'s "ranking" from the minimum
% value of rangeR. Residuals at the lower end of the range should be close
% to 0% and residuals at the higher end of the range should be close to
% 100%.

    
    
end