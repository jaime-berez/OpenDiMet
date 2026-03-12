function plotFlatness(feature)
    % PLOTFLATNESS Plot the flatness error of a Plane feature.
    %
    %   Syntax
    %     plotFlatness(feature)
    %
    %   Description
    %     Visualizes the flatness deviation of a fitted Plane feature.
    %     The function generates flatness plots using the associated plane
    %     and amplified residual data. The current implementation includes
    %     work-in-progress visualizations for both minimax and least-squares
    %     based flatness evaluation.
    %
    %   Input Arguments
    %     feature
    %         Plane object
    %         Plane feature containing the coordinate data and fitted plane
    %         parameters.
    %
    %   Output
    %     This function produces graphical plots of the flatness error.
    %
    %   Example
    %     feat = fitFeature(data,"Plane","LeastSquares");
    %     plotFlatness(feat);
    if isa(feature, "Plane")
        data = feature.data;
        point = feature.point;
        direction = feature.direction;

        % Flatness Evaluation - Minimax <<WORK IN PROGRESS>>
        figure(); %create a new figure
        [fDir,residual] = Flatness(feature); %associate a median plan to evaluate flatness
        [X1,Y1,Z1] = calcPlaneCorners(data,point,fDir(:)'); %calculate the corners of the plane
        Plot.plotPlane(X1,Y1,Z1,[.1 .1 .1],.1); %plot the median plane
        ampFac = cafpla(X1,Y1,Z1); %amplication factor for visualizing the flatness error
        %fprintf('Amplification Factor:\t%4d\n',ampFac);
        [fData,colors] = ampFlatness(data,residual,fDir,ampFac); %amplifies the flatness error
        Plot.plotData(fData,colors); %plot the data with amplified flatness error
        formatColorBar(gca,residual,'northoutside'); %format the colorbar for the figure
        
        % Flatness Evaluation - LSQ <<WORK IN PROGRESS>>
        figure();
        [X,Y,Z] = calcPlaneCorners(data,point,direction);
        Plot.plotPlane(X,Y,Z); %plot the associated plane
        hold on;
        res = calcFlatnessResiduals(data,point,direction);
        ampFac2 = cafpla(X,Y,Z);
        [fData2,colors2] = ampFlatness(data,res,direction,ampFac2);
        Plot.plotData(fData2,colors2);
        formatColorBar(gca,res,'northoutside'); %format the colorbar for the figure
    else
        error("Flatness:UnsupportedGeometry", ...
            "Flatness is only implemented for Plane. Got feature of type '%s'", class(feature))
    end
end