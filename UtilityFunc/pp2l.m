function [point] = pp2l(point,centroid,vector)
    % (P)roject a (P)oint (2) to a (L)ine
    % Projects a point in space onto a line in space. The projection is the
    % orthogonal distance of the point to the line.

    vCentPoi = centroid-point; %Vector from the centroid to the arbitary point on the line
    dotProd = dot(vCentPoi,vector); %Dot product of the vector between the centroid and point, and the axis vector
    point = point+dotProd*vector; %The point on the line where the centroid is projected.
end