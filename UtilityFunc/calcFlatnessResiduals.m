% This function is useful for calculating the residuals for flatness if the
% plane has been previously associated using SVD or a different analytical
% method rather than using an association algorithm

function residual = calcFlatnessResiduals(data, pnt, dir)

Rz = getRz(dir);
data0 = data - pnt;
data1 = data0 * Rz;

residual = data1(:,3);
