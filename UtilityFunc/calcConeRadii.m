function [smallR,bigR,height] = calcConeRadii(data,point,apex,direction,angle,distance)
    % data: nx3 matrix of row-vector coordinate points
    % poi: 1x3 point in space along the axis of the cone, closest to the centroid
    % of the data
    % apex: 1x3 point in space describing the tip of the cone
    % dir: 1x3 direction cosines of the axis
    % ang: scalar value for the semi-angle of the cone in radians
    % dis: scalar distance from the poi to the cone's surface, orthogonal to the
    % cone's surface
    %
    % smallR: scalar radius of the cone closest to the apex
    % bigR: scalar radius of the cone furthest from the apex
    % height: height of the cone based on the distribution of coordinate points
    arguments
        data (:,3) 
        point (1,3)
        apex (1,3)
        direction (1,3)
        angle (1,1)
        distance (1,1)
    end
    
    %Translate the data to the origin then rotate the data to align with the Z axis
        data0 = data-point; %translates the data to the origin
        Rz=getRz(direction); %rotation matrix
        data1 = data0*Rz; %rotates the data about the origin to align with the z axis
    
    % Find the Z coordinates of the top and bottom of the cone
        zMin=min(data1(:,3),[],1); %minimum z value (should be negative)
        zMax=max(data1(:,3),[],1); %maximum z value (should be positive)
        height = max(data1(:,3)) - min(data1(:,3)); %absolute value of  zMax minus zMin
    
    % Calculate the radius of the cone at both ends
        % Triangle formed by the point on the axis and point on the surface that
        % are distance dis apart, orthogonal to the surface of the cone.
        %
        %    O           O is the origin [0,0,0]
        %    |\
        %    | \
        %    n  \
        %    |  &\       & is angle theta
        %    Q--m--
        %       
        
        O = [0,0,0];
        m = distance*cos(angle); 
        n = distance*sin(angle);
        Q = O-n*[0,0,1];
    
        apex0 = apex-point;
        apex1 = apex0*Rz;
        
        h1 = norm(apex1(3)-zMin);
        smallR = h1*tan(angle);
    
        %r2 = height*tan(ang);
        %r2 = n*height/m;
        bigR = m+(zMax+n)*tan(angle);
    
        if smallR < 0
            warning("Small radius is negative. Expected positive value");
        end
        if bigR < 0
            warning("Big radius is negative. Expected positive value");
        end
    end