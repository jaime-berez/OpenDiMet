%% Note on vectors and rotation matricies in MATLAB
close all; clear all; clc; format compact;
% A 'row' vector is [x, y, z] or [x1, y1, z1; z2, y2, z2; ... xn, yn, zn].
VRow = [1 2 3]
MRow = [1 2 3; 4 5 6]
% A 'col' vector  is [x; y; z] or [x1, x2, ...xn; y1, y2, ...yn; z1, z2, ...zn].
VCol = [1; 2; 3]
MRow = [1, 4; 2, 5; 3, 6]
% To rotate a row vector, post-multiply it by a 3x3 rotation matrix, Rrow.
% To rotate a col vector, pre-multiply it by a 3x3 rotation matrix, Rcol.
% Rcol = Rrow' and visa versa.
% Note that most available formulations and functions for R are for column
% vector data. OpenDiMet uses row vector data by convention and all rot
% matricies are formatted accordingly within the toolbox.

%% Demo: Rotate an arbitrary vector to point in the Z direction
clear all; close all; clc;

% 0. User input
A = [3 2 1]; % Arbitrary vector
foot = [2 2 2]; % Arbitrary point, foot of vector
Apnts = [foot; foot(1)+A(1) foot(2)+A(2) foot(3)+A(3)]; % Start and end points of vector

% 1. Calculate rotaiton matrix
R = calcRotMat_A2Z(A);

% 2. Calculate new vector points and dir
ApntsR = Apnts*R; % Post-multiply by transposed rotMat since P is a row vect
dirNew = ApntsR(2,:)-ApntsR(1,:);
dirNew = dirNew./norm(dirNew) % Normalize

% Plot P and PNew
figure()
plotAxs(Apnts, [0 0 1], "-", "o", "x"); grid on; box on; axis equal; hold on;
plotAxs(ApntsR, [0 0 1], "--", "o", "x"); hold on;

%% Demo: Rotate an abritrary vector to point in an arbitraty direction
clear all;

% 0. User input
A = [1 2 3]; % Vector to be aligned
foot = [2 2 2]; % Arbitrary point, foot of vector
Apnts = [foot; foot(1)+A(1) foot(2)+A(2) foot(3)+A(3)]; % Start and end points of vector
B = [1 1 0]; % Desired alignment direction

% 1. Calculate rotation matrix 
R = calcRotMat_A2B(A, B);

% 2. Calculate aligned vector
ApntsR = Apnts*R;
dirNew = ApntsR(2,:)-ApntsR(1,:);
dirNew = dirNew./norm(dirNew) % Normalize

% Plot P and PNew
figure()
plotAxs(Apnts, [0 0 1], "-", "o", "x"); grid on; box on; axis equal; hold on;
plotAxs([0 0 0; B], [1 0 0], "-", "o", "x"); hold on;
plotAxs(ApntsR, [0 0 1], "--", "o", "x"); hold on;

%% Successive rotations
clear all;

% 0. User input
A = [3 3 3; 4 5 6]; % Points to be rotated

% 1. Calculate rotation matrices
Rx = calcRotMat_XYZ(30, 0, 0);
Ry = calcRotMat_XYZ(0, 45, 0);
Rz = calcRotMat_XYZ(0, 0, 180);
Rxyz = calcRotMat_XYZ(30, 45, 180);

% 2. Calculate rotated points
Ax = A*Rx;
Axy = A*Rx*Ry;
Axyz = A*Rx*Ry*Rz;
Axyz2 = A*Rxyz;

% Plot P and PNew
figure()
plot3(0, 0, 0, 'kx'); hold on; grid on; box on; axis equal; 
plotAxs(A, [0 0 0], "-", "o", "x"); hold on;
plotAxs(Ax, [1 0 0], "-", "o", "x"); hold on;
plotAxs(Axy, [0 1 0], "-", "o", "x"); hold on;
plotAxs(Axyz2, [0 0 1], "-", "o", "x"); hold on;
box on; grid on; axis equal;
xlabel("x"); ylabel("y"); zlabel("z")

function plotAxs(pnts, color, lineStyle, mkrStart, mkrEnd)

    plot3(pnts(:,1), pnts(:,2), pnts(:,3), Color=color, LineStyle=lineStyle); hold on;
    plot3(pnts(1,1), pnts(1,2), pnts(1,3), Color=color, Marker=mkrStart);
    plot3(pnts(2,1), pnts(2,2), pnts(2,3), Color=color, Marker=mkrEnd);

end

