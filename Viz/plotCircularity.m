function plotCircularity(feature)
    % PLOTCIRCULARITY Plot the circularity error of a Circle feature.
    %
    %   Syntax
    %     plotCircularity(feature)
    %
    %   Description
    %     Visualizes the circularity deviation of a fitted Circle feature.
    %     The function amplifies the radial deviations of the measured data
    %     relative to the associated circle and colors the points according
    %     to their error magnitude.
    %
    %     The nominal circle and feature center are also plotted for reference.
    %     A colorbar indicates the relative magnitude of the circularity error.
    %
    %   Input Arguments
    %     feature
    %         Circle object
    %         Circle feature containing the coordinate data, fitted center,
    %         axis direction, and diameter.
    %
    %   Output
    %     This function produces a graphical plot of the circularity error.
    %
    %   Example
    %     feat = fitFeature(data,"Circle","LeastSquares");
    %     plotCircularity(feat);

    if isa(feature, "Circle")

        data      = feature.data;
        center    = feature.pnt;
        axisDir   = feature.dir;
        diameter  = feature.dia;

        [circError, rMax, rMin] = Circularity(feature);

        ampFac = cafrou(circError, rMax, rMin);

        % MIC / MCC reference circles
        circMCC = calcCirclePoints(center, axisDir, 2*rMax, 50);
        circMIC = calcCirclePoints(center, axisDir, 2*rMin, 50);

        % Amplified data
        [cData, colors] = ampCircularity(data, center, axisDir, diameter/2, ampFac);

        Plot.plotData(cData, colors);
        hold on;

        % Nominal circle
        nominalCircle = calcCirclePoints(center, axisDir, diameter, 50);
        % [X,Y,Z] = separateData(nominalCircle);
        X = nominalCircle(:,1);
        Y = nominalCircle(:,2);
        Z = nominalCircle(:,3);

        plot3(X, Y, Z, 'g-', 'LineWidth', 1.5);
        plot3(center(1), center(2), center(3), 'k*');

        xlabel('x'); ylabel('y'); zlabel('z');

        formatColorBar(gca, [rMin, rMax]/diameter/10, 'eastoutside');

    else
        error("Circularity:UnsupportedGeometry", ...
              "Circularity is only implemented for Circle. Got feature of type '%s'", class(feature))
    end
end
