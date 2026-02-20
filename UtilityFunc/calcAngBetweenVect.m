function [angDeg, ax] = calcAngBetweenVect(v1, v2)
% CALCANGBETWEENVECT Calculates the angle (in degrees) between two vectors

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
