function [angDeg, ax] = AngBtwnVect(v1, v2)
    % ANGBTWNVECT Compute the angle between two vectors and the corresponding rotation axis.
    %
    %   Syntax
    %     angDeg = AngBtwnVect(v1, v2)
    %     [angDeg, ax] = AngBtwnVect(v1, v2)
    %
    %   Input Arguments
    %     v1 - First vector
    %       1x3 double vector
    %     v2 - Second vector
    %       1x3 double vector
    %
    %   Output Arguments
    %     angDeg - Angle between the two vectors
    %       scalar double (degrees)
    %     ax - Axis perpendicular to both vectors (cross-product direction)
    %       1x3 double vector
    %
    %   Example
    %     v1 = [1 0 0];
    %     v2 = [0 1 0];
    %     [ang, ax] = AngBtwnVect(v1, v2);

    arguments (Input)
        v1
        v2
    end
    
    v1 = v1 ./ norm(v1);
    v2 = v2 ./ norm(v2);
    
    ax = cross(v1, v2);
    
    angDeg = 2 * atan2d( ...
        norm(norm(v1) * v2 - norm(v2) * v1), ...
        norm(norm(v1) * v2 + norm(v2) * v1) );
    
    % Note on computing angle: There are multiple possible methods.
    % Performance diverges for small angles. The chosen method is reported
    % to have the best performance on small angles.
    % ang2 = atan2d(norm(cross(v1, v2)), dot(v1, v2));
    % ang3 = acosd(dot(v1, v2)/(norm(v1)*norm(v2)));

end
