% This function is useful for calculating the residuals for flatness if the
% plane has been previously associated using SVD or a different analytical
% method rather than using an association algorithm

function [residuals] = calcFlatnessResiduals(data,point,direction)

Rz = getRz(direction);
data1 = data-point;
data2 = data1*Rz;

residuals = data2(:,3);