function R = calcRotMat_A2B(A, B)
%CALCROTMAT_A2B calculates rotation matrix R to align vector A to direction B.
% Formulates rotation matrix that can be post-multiplied with row vector A
% to align its direction with row vector B
    arguments (Input)
        A (1,3) double {isreal isfinite} % Vector representing direction
        B (1,3) double {isreal isfinite} % Desired alignment direction
    end
    
    % Dev notes
    %   Works if A and B are not unit vectors, A magnitude is maintained
    %   Is my flip R right??
    
    % 1. Find the angle between A and B and the axis of rotation normal to
    % the plane that contains both vectors
    [ang, axis] = calcAngBetweenVect(A, B);
    
    % Prevent singular matrix by detecting if A and B point in same or opposite
    % directions
    tol = 1e-12;
    if abs(ang) < tol
        R = [1 0 0; 0 1 0; 0 0 1];
        return
    elseif abs(ang-180) < tol
        R = [-1 0 0; 0 -1 0; 0 0 -1];
        return
    end
    
    % 2. Rotate A and B s/t the axis of rotation normal to the plane that
    % contains them pionts to Z
    R1 = calcRotMat_A2Z(axis);
    A1 = A*R1;
    B1 = B*R1;
    
    % 3. Rotate A1 about Z by ang
    R2 = calcRotMat_XYZ(0, 0, ang);
    A2 = A1*R2; %  A2 s/b equal to B1
    
    % 4. Create rot mat to transform A to B directly
    R = R1*R2*inv(R1);
end