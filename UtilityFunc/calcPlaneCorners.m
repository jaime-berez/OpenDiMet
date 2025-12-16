function [X,Y,Z] = calcPlaneCorners(data, point, direction, scalingFactor)
     % Calculate 4 corners for rotated rectangular data
    arguments
        data (:,3) {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        point (1,3) {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        direction (1,3) {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        scalingFactor (1,1) {mustBePositive} = 1.10
    end
    %Translate the data to the origin by subtracting the centroid
    data0 = data - point; %data centered about the origin

    %Rotate the data to the xy plane
    Rz = getRz(direction);
    data1 = data0*Rz; %Data rotated to the xy plane

    %Perform Principal Components Analysis on the Data. Then Rotate to align with X
    [~, ~, pc] = svd(data1, 'econ'); %toolbox free
    %pc = pca(data1); %matrix of principal components from PCA.
        %Each column is a unit vector. The first column corresponds to the
        %direction of data with the most variation (biggest width). The
        %second axis points in the direction of most variance ORTHOGONAL to
        %the first direction. The third direction is orthogonal to the
        %first two directions.
    phi = (dot(pc(:,1)',[1,1,0]) / norm(pc(:,1)')*norm([1,1,0])); %compute the angle between the axis of most variation and the x axis
    Rz2D = [cos(phi) sin(phi) 0; -sin(phi) cos(phi) 0; 0 0 1]; %create the rotation matrix to rotate about Z
    data2 = data1*Rz2D; %rotate the data

    %Find the Corners of the Data
    [mx, i] = max(data2,[],1); %find the maximum x,y,& z values and indicies of the rotated data
    [mi, j] = min(data2,[],1); %find the minimum x,y,& z values and indicies of the rotated data 
    
    c1 = data2(i(1),:,:); %1st corner is the point with the maximum x value
    c2 = data2(i(2),:,:); %2nd corner is the point with the maximum y value
    c3 = data2(j(1),:,:); %3rd corner is the point with the minimum x value
    c4 = data2(j(2),:,:); %4th corner is the point with the minimum y value
    corners = [c1;c2;c3;c4]; %matrix of the corners with columns 1,2,3 corresponding to x,y,z respectively

    corners=corners*scalingFactor;
    
    %Rotate the Corners by inversing the previous rotations Rpc and Rxyz
    corners3 = corners*inv(Rz2D)*inv(Rz)+point; %single equation to rotate the corners into the coordinate system of the raw data

    %The following IF statements check to see which direction number is dominant. This is used to compute the perfect plane
    % The scalar equation of a plane is: a(X-x)+b(Y-y)+c(Z-z)
    % where <a,b,c> is the direction vector, (x,y,z) is the centroid, and
    % (X,Y,Z) are the corner points
    [domDir,dirInd] = max(abs(direction));
    bcDiff = direction(2)-direction(3);
    baDiff = direction(2)-direction(1);
    
    if dirInd==1; %if the X diretion is dominant, use the YZ corners and solve for X values
        X = (-direction(2)/direction(1))*(corners3(:,2)-point(2))+(-direction(3)/direction(1))*(corners3(:,3)-point(3))+point(1);
        Y = corners3(:,2);
        Z = corners3(:,3);
        %disp("X dominant");
    elseif dirInd==2 && abs(bcDiff)>.5; %if the Y direction is dominant, use the XZ corners and solve for Y values 
        X = corners3(:,1);
        Y = (-direction(1)/direction(2))*(corners3(:,1)-point(1))+(-direction(3)/direction(2))*(corners3(:,2)-point(2))+point(2);
        Z = corners3(:,3);
        %disp("Y dominant");
    else dirInd==3; %if the Z direction is dominant, use the XY corners and solve for Z values
        X = corners3(:,1);
        Y = corners3(:,2);
        Z = ((-direction(1)/direction(3))*(corners3(:,1)-point(1))+(-direction(2)/direction(3))*(corners3(:,2)-point(2)))+point(3);
        %disp("Z dominant");
    end
end