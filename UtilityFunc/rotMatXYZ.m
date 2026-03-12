function R = rotMatXYZ(angX, angY, angZ)
    % ROTMATXYZ Compute a rotation matrix about the primary X, Y, and Z axes.
    %
    %   Syntax
    %     R = rotMatXYZ(angX, angY, angZ)
    %
    %   Description
    %     Computes a rotation matrix from successive rotations about the
    %     primary X, Y, and Z axes. The input angles are specified in degrees.
    %     The returned matrix is intended for post-multiplication with row
    %     vectors, such that:
    %         Vrot = V * R
    %     and
    %         V * R = V * Rx * Ry * Rz
    %
    %   Input Arguments
    %     angX - 1x1 double - Rotation angle about the X-axis, in degrees.
    %     angY - 1x1 double - Rotation angle about the Y-axis, in degrees.
    %     angZ - 1x1 double - Rotation angle about the Z-axis, in degrees.
    %
    %   Output Arguments
    %     R - 3x3 double - Rotation matrix formed from the X-, Y-, and Z-axis rotations.
    %         
    %   Example
    %     R = rotMatXYZ(90, 0, 0);
    %     R = rotMatXYZ(0, 45, 30);
    arguments (Input)
        angX (1,1) double {mustBeReal mustBeFinite}
        angY (1,1) double {mustBeReal mustBeFinite}
        angZ (1,1) double {mustBeReal mustBeFinite}
    end
    
    arguments (Output)
        R
    end
    
    Rx = rotX(angX);
    Ry = rotY(angY);
    Rz = rotZ(angZ);
    R = Rx*Ry*Rz;
        function Rx = rotX(angX)
            % Formatted for post multiply of row vect
            Rx = [1           0           0          ;...
                0           cosd(angX)  sind(angX);...
                0           -sind(angX) cosd(angX) ];
        end
    
        function Ry = rotY(angY)
            % Formatted for post multiply of row vect
            Ry = [cosd(angY)  0           -sind(angY );...
                0           1           0          ;...
                sind(angY)  0           cosd(angY) ];
        end
    
        function Rz = rotZ(angZ)
            % Formatted for post multiply of row vect
            Rz = [cosd(angZ)  sind(angZ)  0          ;...
                -sind(angZ) cosd(angZ)  0          ;...
                0           0           1          ];
        end
end