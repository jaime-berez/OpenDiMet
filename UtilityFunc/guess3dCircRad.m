function rad = guess3dCircRad(data)
%guess3dCircRad Estimate the radius of a circle or sphere from 3D coordinate data

    % [xData, yData, zData] = separateData(data);
    xData = data(:,1);
    yData = data(:,2);
    zData = data(:,3);

    rngVals = [max(xData) - min(xData), ...
               max(yData) - min(yData), ...
               max(zData) - min(zData)];

    hChord = min(rngVals, [], 2);   % smallest chord
    wChord = max(rngVals, [], 2);   % largest chord

    rad = 0.5 * (hChord + wChord^2 / (4*hChord));
end
