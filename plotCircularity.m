function plotCircularity(feature)
%PLOTCIRCULARITY Function to plot circularity of a circle feature.
    if isa(feature, "Circle")
        data = feature.data;
        point = feature.point;
        direction = feature.direction;
        diameter = feature.diameter;
        [circError,rmax,rmin] = Circularity(feature);
        ampFac = cafrou(circError,rmax,rmin);       
        %fprintf('\nMIC Diameter: %-10.8f\nMCC Diameter: %-10.8f\nRoundess Error: %-10.4f\n',rmin*2,rmax*2,circError);
        cirPoiMCC = calcCirclePoints(point,direction,2*rmax,50);
        cirPoiMIC = calcCirclePoints(point,direction,2*rmin,50);    
        % plotCircle(cirPoiMCC,'r:');
        % plotCircle(cirPoiMIC,'m:');    
        [cData,colors]=ampCircularity(data,point,direction,diameter/2,ampFac);
        %figure();
        Plot.plotData(cData,colors); hold on;
        %Plot.plotCircle(data, point, direction, diameter);
        circlePoints = calcCirclePoints(point,direction,diameter,50);
        [X,Y,Z] = separateData(circlePoints);
        plot3(X,Y,Z,'g-','LineWidth',1.5); %plot the circumference of the circle
        plot3(point(1),point(2),point(3),'k*');
        xlabel('x');ylabel('y');zlabel('z');
        formatColorBar(gca,[rmin,rmax]/diameter/10,'eastoutside');
    else
        error("Circularity:UnsupportedGeometry", ...
            "Circularity is only implemented for Circle. Got feature of type '%s'", class(feature))
    end
end
