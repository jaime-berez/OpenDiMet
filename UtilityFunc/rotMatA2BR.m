function R = rotMatA2BR(A, B)
    % ROTMATA2BR Compute a rotation matrix that aligns one direction vector with another
    % using Rodrigues' rotation formula.
    %
    %   Syntax
    %     R = rotMatA2BR(A, B)
    %
    %   Description
    %     Computes a rotation matrix that maps direction A to direction B
    %     using axis-angle rotation. The returned matrix is expressed in
    %     column-vector convention. For row-vector point arrays V (Nx3),
    %     apply the rotation as:
    %
    %         Vrot = V * R.'
    %
    %   Input Arguments
    %     A - 1x3 double - Vector representing the initial direction.
    %     B - 1x3 double - Vector representing the desired direction.
    %
    %   Output Arguments
    %     R - 3x3 double - Rotation matrix that maps A to B.

    %   Example
    %     A = [0 0 1];
    %     B = [1 0 0];
    %     R = rotMatA2BR(A, B);

    arguments (Input)
        A (1,3) double {isreal isfinite} % Vector representing direction
        B (1,3) double {isreal isfinite} % Desired alignment direction
    end
    
    
    % Find the angle between A and B and the axis of rotation normal to
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
    
    axis = axis./norm(axis);      % unit rotation axis
    angRad = deg2rad(ang);          % Rodrigues needs radians
    
    % Rodrigues rotation matrix for rotation about 'axis' by 'ang'
    x = axis(1); y = axis(2); z = axis(3);
    K = [ 0  -z   y;
          z   0  -x;
         -y   x   0 ];
    R = eye(3) + sin(angRad)*K + (1-cos(angRad))*(K*K);
end