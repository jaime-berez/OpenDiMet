function len = calcLineLength(data, pnt, dir, scalingFactor)
    % Calculate the length of the line segment represented by the data.
    % Since a mathematical line is infinite, we compute the span of the
    % measured data projected onto the line axis and scale it.

    arguments
        data (:,3) double
        pnt (1,3) double
        dir (1,3) double
        scalingFactor (1,1) double = 1
    end

    % Translate to origin
    data0 = data - pnt;

    % Rotate so line direction aligns with Z-axis
    Rz = getRz(dir);
    data1 = data0 * Rz;

    % Span along axis (Z after rotation)
    zMin = min(data1(:,3));
    zMax = max(data1(:,3));

    height = zMax - zMin;

    len = height * scalingFactor;
end
