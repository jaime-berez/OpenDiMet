function plotStraightness(feature)    
    % PLOTSTRAIGHTNESS Plot the straightness error of a Line feature.
    %
    %   Syntax
    %     plotStraightness(feature)
    %
    %   Description
    %     Visualizes the straightness deviation of a fitted Line feature.
    %     The function generates plots of the measured coordinate data, the
    %     associated fitted line, a containing cylinder used for straightness
    %     evaluation, and an amplified view of the straightness residuals.
    %
    %   Input Arguments
    %     feature
    %         Line object
    %         Line feature containing the coordinate data and fitted line
    %         parameters.
    %
    %   Output
    %     This function produces graphical plots of the straightness error.
    %
    %   Example
    %     feat = fitFeature(data,"Line","LeastSquares");
    %     plotStraightness(feat);
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
        [distance,~,~] = fitStraightness(data,point,direction);
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