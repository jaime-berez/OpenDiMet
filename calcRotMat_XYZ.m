function R = calcRotMat_XYZ(angX, angY, angZ)
%CALCROTMAT_XYZ Calculations rotation matrix about primary axes X, Y, Z.
%   angX, angY, angZ are angles about the respective axes (in degrees). To
%   rotate about a single axis, set the other angles to zero. The rotation
%   matrix will be formated to be post-multplied with a row vector, V, such
%   that A*R is equivalent to A*Rx*Ry*Rz.
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