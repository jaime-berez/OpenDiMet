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
                name (1,1) string {mustBeTextScalar, mustBeNonempty}
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
            end

            obj@Feature(name, data, associationCriteria);
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
            direction1 = [1,0,0];
            direction2 = [0,1,0];
            direction3 = [0,0,1];
            distance1 = 2*std(yD);
            distance2 = 2*std(zD);
            distance3 = 2*std(xD);

            guess1 = [point,direction1,distance1];
            guess2 = [point,direction2,distance2];
            guess3 = [point,direction3,distance3];

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

            [~,ind] = min(resnorm);
            if ind==1
                params = answ1; points = point1(:)'; direction = direction1(:)'; radius = distance1; info = info1; residual = residual1;
            elseif ind==2
                params = answ2; points = point2(:)'; direction = direction2(:)'; radius = distance2; info = info2; residual = residual2;
            elseif ind==3
                params = answ3; points = point3(:)'; direction = direction3(:)'; radius = distance3; info = info3; residual = residual3;
            else
                error('The value of ind must be either 1, 2, or 3')
            end

            % Compute standard deviation
            numParams = numel(params);
            %obj.sigma = calcSigmaFromResiduals(residual, numParams);
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
            radius  = obj.diameter/2;       

            h = Plot.plotCylinder(data, point, direction, radius, dataColor, dataLabel, fitColor, fitLabel, ax);
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

            % Print formatted output
            fprintf('%s Object\n', class(obj));
            fprintf('  Name:            %s\n', name);
            fprintf('  AssociationCriteria: %s\n', char(associationCriteria));
            fprintf('  Point:           [%.4f  %.4f  %.4f]\n', point);
            fprintf('  Direction:       [%.4f  %.4f  %.4f]\n', direction);
            fprintf('  Diameter:        %.4f\n', diameter);
            fprintf('  Sigma:           %.4f\n', sigma)
        end
    end
end

