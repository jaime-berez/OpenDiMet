classdef Cone < Feature
% CONE Class for fitting and representing a cone from 3D data.
% The Cone class constructs a conical feature from measured 3D points
% using a fit-based constructor using the specified AssociationCriteria. It inherits 
% from Feature and stores both geometric description and the fitting parameters 
% used to obtain it.
%
% Properties:
% point - 1 x 3 double, point on the cone axis
% direction - 1 x 3 double, unit vector of the cone axis
% angle - 1 x 1 double, cone angle
% distance - 1 x 1 double, orthogonal distance from point on the axis to
% the surface
% apex - 1 x 3 double, cone apex
% smallR - 1 x 1 double, radius near the apex
% bigR - 1 x 1 double, radius at the far end 
% height - 1 x 1 double, cone height
%
% Methods:
% Cone(name, data, AssociationCriteria) - construct and fit the cone.
% plot() - visualize data and fitted cone.
% disp() - formatted textual description.

    properties (GetAccess = public, SetAccess = private)
        point (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        direction (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        angle (1,1) double {mustBeFinite, mustBeReal, mustBeNonNan}
        distance (1,1) double {mustBeFinite, mustBeReal, mustBeNonnegative, mustBeNonNan}
        apex (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan}
        smallR (1,1) double {mustBeFinite, mustBeReal, mustBeNonNan}
        bigR (1,1) double {mustBeFinite, mustBeReal, mustBeNonNan}
        height (1,1) {mustBeFinite, mustBeReal, mustBeNonNan}
        fitInfo struct = struct()
    end 

    methods
        function obj = Cone(name, data, associationCriteria, opts)
            % Constructor method for the Cone class
            arguments
                name (1,1) string {mustBeTextScalar, mustBeNonempty}
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                associationCriteria (1,1) AssociationCriteria

                % Name-value options for LM
                opts.MaxIter (1,1) double {mustBeFinite, mustBePositive} = 5000
                opts.StepTol (1,1) double {mustBeFinite, mustBePositive} = 1e-9
                opts.GradTol (1,1) double {mustBeFinite, mustBePositive} = 1e-11
                opts.SSETol (1,1) double {mustBeFinite, mustBePositive} = 1e-19
                opts.Lambda (1,1) double {mustBeFinite, mustBePositive} = 1e-4
                opts.DampingCoeff (1,1) double {mustBeFinite, mustBePositive} = 2
                opts.SuppressOutput (1,1) logical = true
            end

            obj@Feature(name, data, associationCriteria);
            obj.validateAssociation();
            % Useful document: https://www.mathworks.com/company/technical-articles/tips-and-tricks-combining-functions-using-anonymous-functions.html
            
            MaxIter = opts.MaxIter;
            StepTol = opts.StepTol;
            GradTol = opts.GradTol;
            SSETol = opts.SSETol;
            Lambda = opts.Lambda;
            DampingCoeff = opts.DampingCoeff;
            SuppressOutput = opts.SuppressOutput;
            centroid = mean(data);
            data1 = data-centroid; % translate data to the origin
        
            % Break the data up into separate x,y,z matrices
            xD = data1(:,1);
            yD = data1(:,2);
            zD = data1(:,3);
            
            C = Cylinder("Cylinder", data1, AssociationCriteria.LeastSquares);
            cylPoint = C.point;
            cylDirection = C.direction;
            cylDiameter = C.diameter;
            point=cylPoint; %[x,y,z]
            direction=cylDirection; %[A,B,C]
            angle5 = deg2rad(1); 
            angle45 = deg2rad(45);
            angle85 = deg2rad(89);
            distance = cylDiameter/2;

            % Combine the initial guess data into a single variable, guess
            guess1 = [point(1),point(2),point(3),direction(1),direction(2),direction(3),angle5,distance];
            guess2 = [point(1),point(2),point(3),direction(1),direction(2),direction(3),angle45,distance];
            guess3 = [point(1),point(2),point(3),direction(1),direction(2),direction(3),angle85,distance];
            
            fcn = @(q) Cone.opFun(q, xD, yD, zD);
        
            [ans1,res(1), residual1, info1] = LM.solve(fcn,guess1, MaxIter, StepTol, GradTol, ...
                SSETol, Lambda, DampingCoeff, SuppressOutput);
            [ans2,res(2), residual2, info2] = LM.solve(fcn,guess2, MaxIter, StepTol, GradTol, ...
                SSETol, Lambda, DampingCoeff, SuppressOutput);
            [ans3,res(3), residual3, info3] = LM.solve(fcn,guess3, MaxIter, StepTol, GradTol, ...
                SSETol, Lambda, DampingCoeff, SuppressOutput);

            [~,ind] = min(res);
            answers = {ans1, ans2, ans3};
            infos = {info1, info2, info3};
            residuals = {residual1, residual2, residual3};
            qbest = answers{ind};
            bestInfo = infos{ind};
            resBest = residuals{ind};
            obj.sigma = std(resBest);
            [point, direction, angle, distance, apex] = formatConeOutput(qbest, centroid);

            % Derive smallR / bigR from data span
            [smallR, bigR, height] = calcConeRadii(data, point, apex, direction, angle, distance);

            obj.point = point;
            obj.direction = direction;
            obj.angle = angle;
            obj.distance = distance;
            obj.apex = apex;
            obj.smallR = smallR;
            obj.bigR = bigR;
            obj.height = height;

            if exist('bestInfo', 'var')
                obj.fitInfo = bestInfo;
            end
        end
    end

    methods
        function h = plot(obj, dataColor, dataLabel, fitColor, fitLabel, faces, ax)
            % Function to plot the fitted cone
            arguments
                obj
                dataColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(dataColor,0),...
                    mustBeLessThanOrEqual(dataColor,1)} = [0 0.4470 0.7410]
                dataLabel (1,:) char = obj.name + ' Data'
                fitColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(fitColor,0),...
                    mustBeLessThanOrEqual(fitColor,1)} = [0 1 0]
                fitLabel (1,:) char = obj.name + ' Fit'  
                faces (1,1) double = 27
                ax = []
            end
            data = obj.data;
            point = obj.point;
            direction = obj.direction;
            smallR = obj.smallR;
            bigR = obj.bigR;
            height = obj.height;
            %Plot.plotData(data);
            % axis equal; axis padded; grid on; hold on;
            % xlabel("x"); ylabel('y'); zlabel('z');
            % hold on;
            % h = Plot.plotCone(data, point, direction, smallR, bigR, height, ...
            %     dataColor, dataLabel, fitColor, fitLabel, faces, ax);
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
            % Custom display for Cone objects
            % Extract base info
            name = string(obj.name);
            associationCriteria = obj.AssociationCriteria;
            data = obj.data;
            point = obj.point(:).';
            direction = obj.direction(:).';
            angle = obj.angle;
            distance = obj.distance;
            apex = obj.apex;
            smallR = obj.smallR;
            bigR = obj.bigR;
            height = obj.height;
            sigma = obj.sigma;
            dataClass = class(data);
            dataSize = size(data);

            % Print formatted output
            fprintf('%s Object\n', class(obj));
            fprintf('  Name:                %s\n', name);
            fprintf('  AssociationCriteria: %s\n', char(associationCriteria));
            fprintf('  Point:               [%.4f  %.4f  %.4f]\n', point);
            fprintf('  Direction:           [%.4f  %.4f  %.4f]\n', direction);
            fprintf('  Included Angle:      %.4f\n', rad2deg(angle*2));
            fprintf('  Distance:            %.4f\n', distance);
            fprintf('  Apex:                [%.4f %.4f %.4f]\n', apex);
            fprintf('  Small R:             %.4f\n', smallR);
            fprintf('  Big R:               %.4f\n', bigR);
            fprintf('  Height:              %.4f\n', height);
            fprintf('  Sigma:               %.4f\n', sigma);
            fprintf('  Data Class:          %s\n', dataClass);
            fprintf('  Data Size:           [%s]\n', num2str(dataSize));
        end
    end

    methods (Static, Access = private)
        function r = opFun(q, xD, yD, zD)
            % q = [x, y, z, A, B, C, angle, s]
            % local copies for normalization logic
            qq = q; 
            % Angle normalization
            if qq(7) > pi
                qq(7) = mod(qq(7), pi);
                qq(4:6) = -qq(4:6);
            elseif qq(7) > (pi/2)
                qq(7) = pi - qq(7);
            end        

            % Distance normalization
            if qq(8) < 0
                qq(8) = -qq(8);
                qq(4:6) = -qq(4:6);
            end        

            u     = @(p) p(6).*(yD - p(2)) - p(5).*(zD - p(3));
            v     = @(p) p(4).*(zD - p(3)) - p(6).*(xD - p(1));
            w     = @(p) p(5).*(xD - p(1)) - p(4).*(yD - p(2));
            aNorm = @(p) sqrt(p(4).^2 + p(5).^2 + p(6).^2);
            f     = @(p) sqrt((u(p).^2 + v(p).^2 + w(p).^2) ./ (aNorm(p).^2));
            g     = @(p) ( p(4).*(xD - p(1)) + p(5).*(yD - p(2)) + p(6).*(zD - p(3)) ) ./ aNorm(p);
        
            ang = mod(qq(7), 2*pi);
            r   = f(qq).*cos(ang) + g(qq).*sin(ang) - qq(8);
        end
    end
end
