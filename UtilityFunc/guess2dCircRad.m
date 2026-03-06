function rad = guess2dCircRad(data)
%guess2dCircRad Estimate the radius of a circle from 2D coordinate data

    xData = data(:,1);
    yData = data(:,2);

    rngX = max(xData) - min(xData);
    rngY = max(yData) - min(yData);

    rngVals = [max([rngX, 1e-50]), max([rngY, 1e-50])];

    hChord = min(rngVals, [], 2);   % smaller chord
    wChord = max(rngVals, [], 2);   % larger chord

    rad = 0.5 * (hChord + wChord^2 / (4*hChord));
end
