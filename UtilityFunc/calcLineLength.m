function len = calcLineLength(data, pnt, dir, scalingFactor)
    % CALCLINELENGTH Compute the axial span of data projected onto a fitted line.
    %
    %   Syntax
    %     len = calcLineLength(data, pnt, dir)
    %     len = calcLineLength(data, pnt, dir, scalingFactor)
    %
    %   Input Arguments
    %     data - Measured 3D point coordinates
    %       Nx3 double matrix
    %     pnt - Reference point on the fitted line (typically centroid)
    %       1x3 double vector
    %     dir - Unit direction vector of the fitted line
    %       1x3 double vector
    %     scalingFactor - Optional multiplier applied to the computed span
    %       positive scalar double
    %
    %   Output Arguments
    %     len - Length of the line segment derived from the projected data span
    %       scalar double
    %
    %   Example
    %     len = calcLineLength(data, pnt, dir);
    %     len = calcLineLength(data, pnt, dir, 1.2);

    arguments
        data (:,3) double
        pnt (1,3) double
        dir (1,3) double
        scalingFactor (1,1) double = 1
    end

    % Translate to origin
    data0 = data - pnt;

    % Rotate so line direction aligns with Z-axis
    R = rotMatA2Z(dir);
    data1 = data0 * R;

    % Span along axis (Z after rotation)
    zMin = min(data1(:,3));
    zMax = max(data1(:,3));

    height = zMax - zMin;

    len = height * scalingFactor;
end
