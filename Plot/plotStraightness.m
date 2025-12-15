function plotStraightness(feature)    
%PLOTSTRAIGHTNESS Function to plot straightness of a line feature.
    if isa(feature, "Line")
        data = feature.data;
        point = feature.point;
        direction = feature.direction;

        [straightness, residuals] = Straightness(feature);

        %Plot the coordinate data and associated line
        figure(1)
        Plot.plotData(data); %plot the data points 
        hold on; grid on; axis equal; axis padded; %configure the figure
        Plot.plotPoint(point); %plot the centroid
        length = calcLineLength(data,point,direction,1); %calculate the length of the line represented by the data
        Plot.plotLine(data, point,direction); %plot the line
        title("Coordinate data with associated line");
        xlabel('x');    ylabel('y');    zlabel('z');
        %legend({"Data points","Centroid","Fitted Line"},'FontSize',12);
    
        % Straightness Evaluation <<WORK IN PROGRESS>>
        distance = fitStraightness(data,point,direction);
        Plot.plotCylinder(data,point,direction,distance);
    
        %res = calcStraightnessResiduals(data,point,direction);
        ampFac = cafStr(straightness,length);
        [fData,colors] = ampStraightness(data,residuals,direction,ampFac);
        
        figure(2)
        Plot.plotData(fData,colors);
        formatColorBar(gca,residuals,'northoutside')
    else
        error("Straightness:UnsupportedGeometry", ...
            "Straightness is only implemented for Line. Got feature of type '%s'", class(feature))
    end
end