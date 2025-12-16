function [circError,Rmax,Rmin] = Circularity(feature)
%CIRCULARITY Calculate the circularity error of a circle, given the ideal center.
% This is method #1 for calculating circularity error.
% 
% data and poi are used to calculate the error based on Pathak & Singh, 2021
% dir is used to rotate the data to the XY plane for easier analysis
%
% circError is the difference in radius of the MIC and MCC concentric
% circles
% Rmax and Rmin are the maximum and minimum radi of the points
% mxI and miI are the indices Rmax and Rmin points
    
    if isa(feature, "Circle")
        data = feature.data;
        point = feature.point;
        direction = feature.direction;
        data1 = data-point;
        Rz = getRz(direction);
        data2 = data1*Rz;        
        radii = ((data2(:,1)-0).^2+(data2(:,2)-0).^2).^0.5;     
        [Rmax,mxI] = max(radii);
        [Rmin,miI] = min(radii);
        circError = Rmax - Rmin;
        % cirPoiMCC = calcCirclePoints(point,direction,2*Rmax,50);
        % cirPoiMIC = calcCirclePoints(point,direction,2*Rmin,50);
    else
        error("Circularity:UnsupportedGeometry", ...
    "Circularity is only implemented for Circle. Got feature of type '%s'", class(feature))
    end
end