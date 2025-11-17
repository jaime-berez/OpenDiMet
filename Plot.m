classdef Plot
    %PLOT Static helper class for visualization of fitted geometric
    %features.
    % The Plot class centralizes all plotting and visualization functions.  
    % It provides static methods for
    % rendering raw point-cloud data and fitted geometries. This keeps
    % the features classes focused on fitting and data representaiton,
    % while Plot handles the visualization.
    %
    % Capabilities:
    % - plotCylinder(...): plot point-cloud data and a cylinder fitted to
    % those data, inlcuding centerline and circles
    % - plotCone(...): plot a cone from axis, radii, and height
    % - plotCircle(...): plot a 3D circle
    % - plotCircle2(...): plot a 2D circle
    % - plotSphere(...): plot a sphere with a given center and diameter
    % - plotLine(...): plot a line with data and centroid
    % - plotData(...): scatter3 wrapper for raw XYZ data
    % - plotPoint(...): plot centroid with a distinctive marker
    %
    % Utility functions are also provided to:
    % - generate circle points in 3D (calcCirclePoints).
    % - estimate plane corners for plotting from point-cloud data.
    % - convert between N x 3 matrix and inidividual X, Y, and Z vectors.
    %
    % All methods are static and can be called without initiating the class

    methods (Static)
        function h = plotCylinder(data, point, direction, distance,...
                dataColor, dataLabel, fitColor, fitLabel, ax)         
            arguments
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                point (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                direction (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                distance (1,1) double {mustBeFinite, mustBeReal}
                dataColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(dataColor,0),...
                    mustBeLessThanOrEqual(dataColor,1)} = [0 0.4470 0.7410]
                dataLabel (1,:) char = 'Data Points'
                fitColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(fitColor,0),...
                    mustBeLessThanOrEqual(fitColor,1)} = [0 1 0]
                fitLabel (1,:) char = 'Fitted Cylinder'
                ax = []
            end
            
            if isempty(ax) || ~isvalid(ax)
                ax = gca;
            end

            cla(ax); hold (ax, 'on'); axis(ax, 'equal'); grid(ax, 'on'); view(ax,3);
            % Plot raw data
            plot3(ax, data(:,1),data(:,2),data(:,3),'.', 'Color',dataColor, 'DisplayName',dataLabel); 
            hold(ax,'on'); axis(ax,'equal'); axis(ax,'padded'); grid(ax,'on');
            plot3(ax, point(1),point(2),point(3),'xk', 'HandleVisibility', 'off'); 
            xlabel(ax,'x'); ylabel(ax,'y'); zlabel(ax,'z');
            title(ax, sprintf('%s',fitLabel));

            % Create a Cylinder (radius = dis)
            faces = 50;
            [X,Y,Z] = cylinder(distance,faces);
            cylData = xyz2Mat(X,Y,Z);

            % Height of the point cloud
            data1 = data - point; 
            a = direction(1); b = direction(2); c = direction(3);
            Rz = [1-a^2/(1+c) -a*b/(1+c) a; -a*b/(1+c) 1-b^2/(1+c) b; -a -b c];
            data2 = data1*Rz;
            scale = 0.25; 
            height = (max(data2(:,3)) - min(data2(:,3))) * (1+scale);
            %height = range(data2(:,3))*(1+scale);

            % Apply height, rotate back, translate
            cylData1 = cylData; 
            cylData1(:,3) = cylData(:,3)*height-(height/2);
            cylData2 = cylData1/Rz;
            cylData3 = cylData2 + point;

            [X2,Y2,Z2] = mat2xyz(cylData3);
            h = surf(ax, X2,Y2,Z2,'EdgeColor','none','FaceColor',fitColor,'FaceAlpha',0.4, 'DisplayName',fitLabel);

            % Centerline
            k = 1; 
            points = [0,0,(height/2)*(1+k)-(height/2); 0,0,(height/2)*(1-k)-(height/2)];
            points1 = points/Rz;
            points2 = points1 + point;
            plot3(ax, points2(:,1),points2(:,2),points2(:,3),'k-.','LineWidth',1, 'HandleVisibility', 'off');

            % End circles
            topPoint    = [0,0,height*0.5];     topPoint    = topPoint/Rz    + point;
            bottomPoint = [0,0,-height*0.5];    bottomPoint = bottomPoint/Rz + point;
            Plot.plotEndCircle(topPoint,  direction, distance*2, faces);
            Plot.plotEndCircle(bottomPoint,direction, distance*2, faces);

            % Legend
            legend(ax, dataLabel, fitLabel, 'FontSize', 12);
            hold(ax, "off");

        end

        function plotEndCircle(point,direction,diameter,faces)
            arguments
                point (1,3) double
                direction (1,3) double
                diameter (1,1) double
                faces (1,1) double = 27
            end

            hold on;

            t=linspace(0,2*pi,faces);
            X=(diameter/2)*sin(t);
            Y=(diameter/2)*cos(t);
            Z=zeros(1,faces); % flat circle at origin

            % rotation & transform using helper.getRz
            Rz = getRz(direction);
            points=[X',Y',Z'];
            points1=points/(Rz);

            X=((points1(:,1))+point(1))';
            Y=((points1(:,2))+point(2))';
            Z=((points1(:,3))+point(3))';

            plot3(X,Y,Z,'k-','LineWidth',1, 'HandleVisibility','off');
        end

        function h = plotCircle(data, point, direction, diameter, dataColor, dataLabel, ...
                fitColor, fitLabel, ax)
            arguments
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                point (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                direction (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                diameter (1,1) double {mustBeFinite, mustBeReal}
                dataColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(dataColor,0),...
                    mustBeLessThanOrEqual(dataColor,1)} = [0 0.4470 0.7410]
                dataLabel (1,:) char = 'Data Points'
                fitColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(fitColor,0),...
                    mustBeLessThanOrEqual(fitColor,1)} = [0 1 0]
                fitLabel (1,:) char = 'Fitted Cylinder'
                ax = []
            end

            if isempty(ax) || ~isvalid(ax)
                ax = gca;
            end

            cla(ax); hold(ax,'on'); grid(ax,'on'); axis(ax,'equal'); axis(ax,'padded');
            view(ax,3);
            xlabel(ax,'x'); ylabel(ax,'y'); zlabel(ax,'z');
            title(ax, fitLabel);

            % Plot raw data
            plot3(ax, data(:,1), data(:,2), data(:,3), '.', ...
                    'Color', dataColor, 'DisplayName', dataLabel);

            % Plot the centroid
            plot3(ax, point(1), point(2), point(3), 'xk', 'HandleVisibility', 'off');
            
            pts = calcCirclePoints(point, direction, diameter, 100);
            [X, Y, Z] = separateData(pts);

            % Fitted circle
            h = plot3(ax, X, Y, Z, '-', 'Color', fitColor, 'LineWidth', 2, ...
                'DisplayName', fitLabel);

            legend(ax, "show", 'FontSize', 12);
            hold(ax, "off");
        end

        function plotData(data,markerColor,icon,size)
            arguments
                data (:,3) double %this is an nx3 matrix of columns representing x,y,z values
                markerColor (:,3) double = [0 0.4470 0.7410] %this is a 3xn matrix representing colors of each point
                icon (1,:) string = "." %string for the marker for each point
                size (1,:) {mustBeNumeric} = 36 %size (points squared) for each marker. Can be a matrix
            end

            % Plot the data points using a scatterplot
            s = scatter3(data(:,1),data(:,2),data(:,3),size,markerColor);
            s.Marker=icon; %set the marker shapes
            axis equal; axis padded; grid on;
        end

        function plotPoint(point)
            plot3(point(1),point(2),point(3),'kx');
        end
    
        function h = plotLine(data, point, direction, dataColor, dataLabel, fitColor, fitLabel, ax, lineStyle)
            % plotLine
            % Function to plot the associated line from coordiate data.

            arguments
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan}
                point (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                direction (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                dataColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(dataColor,0),...
                    mustBeLessThanOrEqual(dataColor,1)} = [0 0.4470 0.7410]
                dataLabel (1,:) char = 'Data Points'
                fitColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(fitColor,0),...
                    mustBeLessThanOrEqual(fitColor,1)} = [0 1 0]
                fitLabel (1,:) char = 'Fitted Cylinder'
                ax = []
                lineStyle (1,1) string {mustBeTextScalar, mustBeNonempty} = 'g-.'
            end

            if isempty(ax) || ~isvalid(ax)
                ax = gca;
            end

            cla(ax); hold (ax, 'on'); axis(ax, 'equal'); grid(ax, 'on'); view(ax,3);

            % Plot the raw data
            plot3(ax, data(:,1), data(:,2), data(:,3), '.', 'Color', dataColor, 'DisplayName', dataLabel);

            % Plot the centroid point
            plot3(ax, point(1), point(2), point(3), 'xk', 'HandleVisibility', 'off')
            
            % Calculate the length of the line segment
            length = calcLineLength(data, point, direction, 1);

            % Compute the end points of the line
            [pStart, pEnd] = calcLinePoints(point, direction, length, 0.5, 1);
            
            % Plot the line
            h = plot3([pStart(1) pEnd(1)], [pStart(2) pEnd(2)], [pStart(3) pEnd(3)], lineStyle, ...
                'Color', fitColor, 'LineWidth', 2, 'DisplayName', fitLabel);
            title(ax, fitLabel);
            xlabel(ax, 'x');    ylabel(ax, 'y');    zlabel(ax, 'z');
            legend(ax, "show", 'FontSize', 12);
            hold(ax, "off");
        end

        function h = plotSphere(data, point, diameter, dataColor, dataLabel, fitColor, fitLabel, faces, ax)
            % Function to plot raw data and a sphere in space.         
            arguments
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan}
                point   (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                diameter   (1,1) double {mustBeFinite, mustBeReal}
                dataColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(dataColor,0),...
                mustBeLessThanOrEqual(dataColor,1)} = [0 0.4470 0.7410]
                dataLabel (1,:) char = 'Data Points'
                fitColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(fitColor,0),...
                    mustBeLessThanOrEqual(fitColor,1)} = [0 1 0]
                fitLabel (1,:) char = 'Fitted Sphere'
                faces (1,1) double = 27
                ax = []
            end

            if isempty(ax) || ~isvalid(ax)
                ax = gca;
            end
            
            cla(ax); hold(ax, 'on'); axis(ax,'equal'); grid(ax,'on'); view(ax,3);
            xlabel(ax,'x'); ylabel(ax,'y'); zlabel(ax,'z');
            title(ax, sprintf('%s', fitLabel));

            plot3(ax, data(:,1),data(:,2),data(:,3),'.', ...
                 'Color',dataColor, 'DisplayName',dataLabel);

            plot3(ax, point(1), point(2), point(3), 'xk', 'HandleVisibility', 'off');
        
            % Plot a sphere
            [X,Y,Z] = sphere(faces);
            X=X*diameter/2+point(1);
            Y=Y*diameter/2+point(2);
            Z=Z*diameter/2+point(3);
            h = surf(ax, X,Y,Z,'FaceColor',fitColor,'FaceAlpha',0.35,'EdgeColor',...
                'none','EdgeAlpha',0.35, 'DisplayName',fitLabel); %plot the fitted sphere  
            legend(ax, "show", 'FontSize',12);
            hold(ax, "off");
        end

        function h = plotCone(data, point, direction, smallR, bigR, height, ...
                dataColor, dataLabel, fitColor, fitLabel, faces, ax)
            % Function to plot raw data and sphere in space
            arguments
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan}
                point (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                direction (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                smallR (1,1) double {mustBeFinite, mustBeReal, mustBeNonNan}
                bigR (1,1) double {mustBeFinite, mustBeReal, mustBeNonNan}
                height (1,1) double {mustBeFinite, mustBeReal, mustBeNonNan}
                dataColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(dataColor,0),...
                mustBeLessThanOrEqual(dataColor,1)} = [0 0.4470 0.7410]
                dataLabel (1,:) char = 'Data Points'
                fitColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(fitColor,0),...
                    mustBeLessThanOrEqual(fitColor,1)} = [0 1 0]
                fitLabel (1,:) char = 'Fitted Cone'
                faces (1,1) double = 25
                ax = []
            end

            if isempty(ax) || ~isvalid(ax)
                ax = gca;
            end

            cla(ax); hold(ax,'on'); axis(ax,'equal'); grid(ax,'on'); view(ax,3);
            xlabel(ax,'x'); ylabel(ax,'y'); zlabel(ax,'z');
            title(ax, fitLabel);

            % Plot raw data
            plot3(ax, data(:,1), data(:,2), data(:,3), '.', ...
                    'Color', dataColor, 'DisplayName', dataLabel);

            % Plot centroid
            plot3(ax, point(1), point(2), point(3), 'xk', 'HandleVisibility','off');
        
            % Create a cone based on the parameters calculated above
            [X,Y,Z] = cylinder([smallR bigR],faces);
            Z=Z*height-height/2;
            cone = xyz2Mat(X,Y,Z);
            Rz = getRz(direction); %rotation matrix
            % Rotate the cone to match the direction of the data, then translate to match the position
            cone1 = cone/Rz;
            cone2 = cone1+point;
            % Plot the cone
            [Xc,Yc,Zc]= mat2xyz(cone2);
        
            h = surf(ax, Xc, Yc, Zc,'LineStyle','none','FaceAlpha',0.5,'FaceColor',fitColor, ...
                'DisplayName', fitLabel);     

            p1 = point - (height/2)*direction;
            p2 = point + (height/2)*direction;
            plot3(ax, [p1(1) p2(1)], [p1(2) p2(2)], [p1(3) p2(3)], ...
                    'k-.', 'LineWidth',1, 'HandleVisibility','off');
            legend(ax, 'show', 'FontSize', 12);
            hold(ax,'off');
        end

        function h = plotPlane(X,Y,Z,faceColor,faceAlpha,showEdge,edgeColor, fitLabel)
            arguments
                X (:,:) {mustBeNumeric}
                Y (:,:) {mustBeNumeric}
                Z (:,:) {mustBeNumeric}
                faceColor (:,3) {mustBeNumeric} = [0 1 0]
                faceAlpha (1,1) {mustBeNumeric} = 0.5
                showEdge (1,1) string = "N"
                edgeColor (:,3) {mustBeNumeric} = [0 1 0]
                fitLabel (1,:) char = 'Fitted Plane'
            end        

            hold on;
        
            % Plot a plane using fill3()
            if showEdge == "N"||"n"
                h = fill3(X,Y,Z,faceColor,'EdgeColor','k', 'FaceAlpha', faceAlpha,'DisplayName',fitLabel);
            elseif showEdge == "Y"||"y"
                h = fill3(X,Y,Z,faceColor,'EdgeColor',edgeColor, 'FaceAlpha',faceAlpha, ...
                    'DisplayName', fitLabel);
            else
                error("showEdge must be Y or N.");
            end    
        end
    end
end