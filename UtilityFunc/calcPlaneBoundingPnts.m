function [X, Y, Z] = calcPlaneBoundingPnts(data, pnt, dir, scalingFactor)
     % Calculate 4 corners for rotated rectangular data
    arguments
        data (:,3) {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        pnt (1,3) {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dir (1,3) {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        scalingFactor (1,1) {mustBePositive} = 1.10
    end

    % Translate the data to the origin by subtracting the centroid
    data0 = data - pnt; % data centered about the origin

    % Rotate the data to the xy plane
    Rz = getRz(dir);
    data1 = data0 * Rz; % Data rotated to the xy plane

    % Perform Principal Components Analysis on the Data. Then Rotate to align with X
    [~, ~, pc] = svd(data1, 'econ'); % toolbox free

    phi = (dot(pc(:,1)', [1,1,0]) / norm(pc(:,1)') * norm([1,1,0])); % compute the angle between the axis of most variation and the x axis
    Rz2D = [cos(phi) sin(phi) 0; -sin(phi) cos(phi) 0; 0 0 1]; % create the rotation matrix to rotate about Z
    data2 = data1 * Rz2D; % rotate the data

    % Find the Corners of the Data
    [mx, i] = max(data2, [], 1); % find the maximum x,y,& z values and indices of the rotated data
    [mi, j] = min(data2, [], 1); % find the minimum x,y,& z values and indices of the rotated data

    c1 = data2(i(1), :, :); % 1st corner is the point with the maximum x value
    c2 = data2(i(2), :, :); % 2nd corner is the point with the maximum y value
    c3 = data2(j(1), :, :); % 3rd corner is the point with the minimum x value
    c4 = data2(j(2), :, :); % 4th corner is the point with the minimum y value
    corners = [c1; c2; c3; c4]; % matrix of corners

    corners = corners * scalingFactor;

    % Rotate the corners by inversing the previous rotations and translate back
    corners3 = corners * inv(Rz2D) * inv(Rz) + pnt;

    % Dominant direction logic (used to compute the perfect plane corners)
    [domDir, dirInd] = max(abs(dir));
    bcDiff = dir(2) - dir(3);
    baDiff = dir(2) - dir(1);

    if dirInd == 1 % X dominant: solve for X using YZ corners
        X = (-dir(2)/dir(1))*(corners3(:,2) - pnt(2)) + (-dir(3)/dir(1))*(corners3(:,3) - pnt(3)) + pnt(1);
        Y = corners3(:,2);
        Z = corners3(:,3);
    elseif dirInd == 2 && abs(bcDiff) > .5 % Y dominant: solve for Y using XZ corners
        X = corners3(:,1);
        Y = (-dir(1)/dir(2))*(corners3(:,1) - pnt(1)) + (-dir(3)/dir(2))*(corners3(:,3) - pnt(3)) + pnt(2);
        Z = corners3(:,3);
    else % dirInd == 3: Z dominant: solve for Z using XY corners
        X = corners3(:,1);
        Y = corners3(:,2);
        Z = ((-dir(1)/dir(3))*(corners3(:,1) - pnt(1)) + (-dir(2)/dir(3))*(corners3(:,2) - pnt(2))) + pnt(3);
    end
end
