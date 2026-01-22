classdef Cylinder < Feature
% CYLINDER Class for fitting and representing a Cylinder from 3D data.
% The Cylinder class constructs a cylindrical feature from measured 3D points
% using a fit-based constructor using the specified AssociationCriteria. It inherits 
% from Feature and stores both geometric description and the fitting parameters 
% used to obtain it.
%
% Properties:
% point - 1 x 3 double, point on the cylinder axis
% direction - 1 x 3 double, unit vector of the cylinder axis
% diameter - 1 x 1 double, cylinder diameter
%
% Methods:
% Cylinder(name, data, AssociationCriteria) - construct and fit the cylinder.
% plot() - visualize the data and the fitted cylinder.
% disp() - formatted textual description.

    properties (GetAccess = public, SetAccess = private)
        point     (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        direction (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        diameter  (1,1) double {mustBeFinite, mustBeReal}
        fitInfo struct = struct()
    end

    methods
        function obj = Cylinder(name, data, associationCriteria, opts)
            % Constructor method for the Cylinder class
            arguments
                name (1,1) string {mustBeTextScalar}
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                associationCriteria (1,1) AssociationCriteria

                % Name-value options for LM
                opts.MaxIter (1,1) double {mustBeFinite, mustBePositive} = 5000
                opts.StepTol (1,1) double {mustBeFinite, mustBePositive} = 1e-10
                opts.GradTol (1,1) double {mustBeFinite, mustBePositive} = 1e-11
                opts.SSETol (1,1) double {mustBeFinite, mustBePositive} = 1e-19
                opts.Lambda (1,1) double {mustBeFinite, mustBePositive} = 1e-4
                opts.DampingCoeff (1,1) double {mustBeFinite, mustBePositive} = 2
                opts.SuppressOutput (1,1) logical = true
                opts.sourceFile (1,1) string = ""
                opts.materialSide (1,1) MaterialSide = MaterialSide.Unspecified
            end

            obj@Feature(name, data, associationCriteria, opts.sourceFile, opts.materialSide);
            obj.validateAssociation();

            MaxIter = opts.MaxIter;
            StepTol = opts.StepTol;
            GradTol = opts.GradTol;
            SSETol = opts.SSETol;
            Lambda = opts.Lambda;
            DampingCoeff = opts.DampingCoeff;
            SuppressOutput = opts.SuppressOutput;

            X = data;          % Nx3
            centroid = mean(X);
            xD = X(:,1); yD = X(:,2); zD = X(:,3);

            % Initial guesses (point = centroid; directions = axes)
            point = centroid; 
            L = Line("Line", data, AssociationCriteria.LeastSquares);
            lpoint = L.point;
            direction1 = [1,0,0];
            direction2 = [0,1,0];
            direction3 = [0,0,1];
            direction4 = L.direction;
            distance1 = 2*std(yD);
            distance2 = 2*std(zD);
            distance3 = 2*std(xD);
            distance4 = (1/6)*( (max(data(:,1))-min(data(:,1)))+(max(data(:,2))-min(data(:,2)))+(max(data(:,3))-min(data(:,3))) );

            guess1 = [point,direction1,distance1];
            guess2 = [point,direction2,distance2];
            guess3 = [point,direction3,distance3];
            guess4 = [lpoint,direction4,distance4];

            % Residuals
            u = @(q) q(6)*(yD-q(2))-q(5)*(zD-q(3));
            v = @(q) q(4)*(zD-q(3))-q(6)*(xD-q(1));
            w = @(q) q(5)*(xD-q(1))-q(4)*(yD-q(2));
            aNorm = @(q) sqrt(q(4)^2+q(5)^2+q(6)^2);
            f = @(q) sqrt((u(q).^2+v(q).^2+w(q).^2)/(aNorm(q)^2));
            fcn = @(q) f(q)-q(7);

            % LM Optimization
            [answ1,resnorm(1), residual1, info1] = LM.solve(fcn, guess1, MaxIter, StepTol, GradTol, ...
                SSETol, Lambda, DampingCoeff, SuppressOutput);
                point1 = [answ1(1:3)];
                direction1 = [answ1(4:6)]; direction1 = direction1/norm(direction1);
                distance1 = answ1(7);
            [answ2,resnorm(2), residual2, info2] = LM.solve(fcn,guess2, MaxIter, StepTol, GradTol, ...
                SSETol, Lambda, DampingCoeff, SuppressOutput);
                point2 = [answ2(1:3)];
                direction2 = [answ2(4:6)]; direction2 = direction2/norm(direction2);
                distance2 = answ2(7);
            [answ3,resnorm(3), residual3, info3] = LM.solve(fcn,guess3, MaxIter, StepTol, GradTol, ...
                SSETol, Lambda, DampingCoeff, SuppressOutput);
                point3 = [answ3(1:3)];
                direction3 = [answ3(4:6)]; direction3 = direction3/norm(direction3);
                distance3 = answ3(7);
            [answ4,resnorm(4), residual4, info4] = LM.solve(fcn,guess4, MaxIter, StepTol, GradTol, ...
                SSETol, Lambda, DampingCoeff, SuppressOutput);
                point4=[answ4(1:3)]; %comment if the data is at the origin
                direction4=[answ4(4:6)]; direction4=direction4/norm(direction4);
                distance4=answ4(7);

            [~,ind] = min(resnorm);
            if ind==1
                params = answ1; points = point1(:)'; direction = direction1(:)'; radius = distance1; info = info1; residual = residual1;
            elseif ind==2
                params = answ2; points = point2(:)'; direction = direction2(:)'; radius = distance2; info = info2; residual = residual2;
            elseif ind==3
                params = answ3; points = point3(:)'; direction = direction3(:)'; radius = distance3; info = info3; residual = residual3;
            elseif ind==4
                params = answ4; points = point4(:)'; direction = direction4(:)'; radius = distance4; info = info4; residual = residual4;
            else
                error('The value of ind must be either 1, 2, 3 or 4')
            end

            % Compute standard deviation
            obj.sigma = std(residual);
            % Assign the values to properties
            obj.point = points;
            obj.direction = direction;
            obj.diameter = radius * 2; % Diameter is twice the radius

            if exist('info', 'var')
                obj.fitInfo = info;
            end
        end
    
        function h = plot(obj, dataColor, dataLabel, fitColor, fitLabel, ax)
            % Function to plot the fitted cylinder
            arguments
                obj
                dataColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(dataColor,0),...
                    mustBeLessThanOrEqual(dataColor,1)} = [0 0.4470 0.7410]
                dataLabel (1,:) char = obj.name + ' Data'
                fitColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(fitColor,0),...
                    mustBeLessThanOrEqual(fitColor,1)} = [0 1 0]
                fitLabel (1,:) char = obj.name + ' Fit'     
                ax = []
            end

            data = obj.data;                 % Nx3
            point  = obj.point(:).';            % 1x3
            direction  = obj.direction(:).';    % 1x3 (unit)
            distance  = obj.diameter/2;       

            %h = Plot.plotCylinder(data, point, direction, radius, dataColor, dataLabel, fitColor, fitLabel, ax);
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
            plotEndCircle(topPoint,  direction, distance*2, faces);
            plotEndCircle(bottomPoint,direction, distance*2, faces);

            % Legend
            legend(ax, dataLabel, fitLabel, 'FontSize', 12);
            hold(ax, "off");
        end

        function showFitInfo(obj)
            if isempty(obj.fitInfo)
                disp('No optimization information available for this object.');
                return;
            end
            T = array2table(obj.fitInfo.history, 'VariableNames', obj.fitInfo.labels);
            fprintf('--- Levenberg-Marquardt Optmization Summary ---\n');
            fprintf('Iterations: %d\nFinal SSE: %.4e\n\n', obj.fitInfo.iter, obj.fitInfo.final_cost);
            disp(T);
        end
        
        function disp(obj)
            % Custom display for Cylinder objects
            % Extract base info
            name  = string(obj.name);
            associationCriteria = obj.AssociationCriteria;
            data  = obj.data;
            point     = obj.point(:).';
            direction     = obj.direction(:).';
            diameter    = obj.diameter;
            sigma = obj.sigma;
            dataClass = class(data);
            dataSize = size(data);
            materialSide = obj.materialSide;

            % Print formatted output
            fprintf('%s Object\n', class(obj));
            fprintf('  Name:      %s\n', name);
            if materialSide ~= MaterialSide.Unspecified
                fprintf('  MatSide:   %s\n', char(materialSide));
            end
            fprintf('  AssocCrit: %s\n', char(associationCriteria));
            fprintf('  Point:     [%.4f  %.4f  %.4f]\n', point);
            fprintf('  Direction: [%.4f  %.4f  %.4f]\n', direction);
            fprintf('  Diameter:  %.4f\n', diameter);
            fprintf('  Sigma:     %.4f\n', sigma);
            fprintf('  Data Size: [%s]\n', [num2str(dataSize(1)), ' x ', num2str(dataSize(2))]);
        end

        function reverseDir(obj)
            % REVERSEDIR Function to reverse the direction vector of the
            % object.

            obj.direction = -obj.direction;
        end
    end
end

