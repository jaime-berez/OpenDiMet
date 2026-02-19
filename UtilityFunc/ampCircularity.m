% Function to amplify the roundness deviation of data from a circle.
% Requires a direction; do not use for spheres.

function [cData, clr] = ampCircularity(data, pnt, dir, rad, ampFac, cmap)
    arguments
        data (:,3) {mustBeMatrix}               % matrix of data points
        pnt (1,3)  {mustBeRow}                  % center point
        dir (1,3)  {mustBeRow}                  % direction unit vector
        rad (1,1)  {mustBePositive}             % associated radius
        ampFac (1,1) {mustBePositive}           % amplification factor
        cmap (256,3) {mustBeMatrix} = colormap(turbo) % colormap matrix
    end

    % Transform the circle by translating to the origin and rotating to the XY plane
    dataT = data - pnt;         % translate to origin
    Rz = getRz(dir);
    dataTR = dataT * Rz;        % rotate to XY plane

    % Calculate the radial distance of each point to the center (in XY)
    rData = sqrt(dataTR(:,1).^2 + dataTR(:,2).^2);

    % Radial distance from the associated circle (+ toward MCC, - toward MIC)
    rErr = rData - rad;

    % Unit vectors from center to each point (in rotated frame)
    uHat = zeros(size(data));
    for i = 1:length(data)
        uHat(i,:) = dataTR(i,:) / norm(dataTR(i,:));
    end

    % Min/max error
    rMin = min(rErr);
    rMax = max(rErr);

    % Map to [0,1] for colormap indexing
    if abs(rMin) > abs(rMax)
        rSpan = 2 * abs(rMin);
        t = (rErr - rMin) ./ rSpan;
    else
        rSpan = 2 * abs(rMax);
        t = (rMax - rErr) ./ rSpan;
    end

    clr = cmap(round(t*255) + 1, :);

    % Amplify (t is [0,1], shift to [-0.5, +0.5] so "no error" stays put)
    dataAmp = ((t - 0.5) .* uHat .* ampFac) + dataTR;

    % Revert the transformations
    cData = dataAmp / Rz + pnt;
end
