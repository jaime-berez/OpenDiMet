function [ang axs] = calcAngBetweenVect(A, B)
%CALCANGBETWEENVECT Calculates the angle (in degrees) between two vectors
%   Description
arguments (Input)
    A
    B
end

% 0. Normalize vectors
A = A./norm(A);
B = B./norm(B);

axs = cross(A,B);
ang = 2*atan2d(norm(norm(A)*B - norm(B)*A), norm((norm(A)*B + norm(B)*A)));

% Note on computing angle: There are multiple possible methods. Performance
% diverges for small angles. The chosen method is reported to have the best
% performance on small angles.
% ang2 = atan2d(norm(cross(A, B)), dot(A, B)); % Also performs ok
% ang3 = acosd(dot(A, B)/(norm(A)*norm(B))); % Poor performance on small ang

end