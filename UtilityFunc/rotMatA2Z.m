function R = rotMatA2Z(A)
    % ROTMATA2Z Compute a rotation matrix that aligns a direction vector with the Z-axis.
    %
    %   Syntax
    %     R = rotMatA2Z(A)
    %
    %   Description
    %     Computes a rotation matrix that aligns vector A with the positive
    %     Z direction. The returned matrix is intended for post-multiplication
    %     with row vectors.
    %
    %   Input Arguments
    %     A
    %         1x3 double
    %         Vector representing the initial direction.
    %
    %   Output Arguments
    %     R
    %         3x3 double
    %         Rotation matrix that aligns A with the Z-axis.
    %
    %   Example
    %     A = [1 1 1];
    %     R = rotMatA2Z(A);
    arguments (Input)
        A (1,3) double {mustBeReal mustBeFinite}
    end
    
    % Dev notes
    %   Is my flip R right??
    
    % Formatted for post multiply of row vect
    dir = A./norm(A); % Find unit direction vector
    a = dir(1); b = dir(2); c = dir(3); % MUST be components of unit vector
    
    tol = 1e-12;
    if (abs(a) < tol) && (abs(b) < tol) % if A already points in Z
        if c < 0
            R = [-1 0 0; 0 -1 0; 0 0 -1]; % Flip
        elseif c > 0;
            R = [1 0 0; 0 1 0; 0 0 1]; % Return identiy matrix
            % Below matrix would have NaN vals if
        end
    else
        R = [(1-(a^2/(1+c))) ((-a*b)/(1+c))  (a);...
             ((-a*b)/(1+c))  (1-(b^2/(1+c))) (b);...
             (-a)            (-b)            (c)];
    end

end