function R = rotMatA2BR(A, B)
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
    [ang, axis] = AngBtwnVect(A, B);
    
    % Prevent singular matrix by detecting if A and B point in same or opposite
    % directions
    tol = 1e-12;
    if abs(ang) < tol
        R = [1 0 0; 0 1 0; 0 0 1];
        return
    elseif abs(ang-180) < tol
        % Robust 180° rotation: rotate about ANY axis perpendicular to A
        a = A./norm(A);
        
        % Choose a helper vector not parallel to a (pick smallest component)
        [~, idx] = min(abs(a));
        tmp = zeros(1,3);
        tmp(idx) = 1;
        
        axisPerp = cross(a, tmp);
        axisPerp = axisPerp ./ norm(axisPerp);  % unit axis
        
        % Rodrigues rotation for 180 degrees about axisPerp
        angRad = deg2rad(180);
        x = axisPerp(1); y = axisPerp(2); z = axisPerp(3);
        K = [ 0  -z   y;
              z   0  -x;
             -y   x   0 ];
        R = eye(3) + sin(angRad)*K + (1-cos(angRad))*(K*K);
        return
    end
    
    % General case
    % axis from AngBtwnVect is perpendicular to plane(A,B) and scaled by sin(ang)
    % Normalize it to get a proper rotation axis.
    if norm(axis) < tol
        R = eye(3);
        return
    end
    
    axis = axis ./ norm(axis);      % unit rotation axis
    angRad = deg2rad(ang);          % Rodrigues needs radians
    
    % Rodrigues rotation matrix for rotation about 'axis' by 'ang'
    x = axis(1); y = axis(2); z = axis(3);
    K = [ 0  -z   y;
          z   0  -x;
         -y   x   0 ];
    R = eye(3) + sin(angRad)*K + (1-cos(angRad))*(K*K);
end