classdef Circle < Feature
% CIRCLE Class for fitting and representing a 2D or 3D circle feature from
% point cloud data. 
% The circle class represents a circular feature reconstructed from 2D or
% 3D coordinate data. The object is constructed directly via a fit-based
% constructor using the specified AssociationCriteria. It inherits from
% Feature and stores both geometric description and the fitting parameters
% used to obtain it.
%
% Properties:
% point - 1 x 3 double, center of the fitted circle.
% direction - 1 x 3 double, unit normal vector of the circle's plane.
% diameter - 1 x 1 double, fitted circle diameter.
%
% Methods:
% Circle(name, data, AssociationCriteria) - constructor performing the fit.
% plot() - visualizes the circle and point data.
% fit2dCircle() - static method for performing 2D Circle fit.
% disp() - formatted textual description.

    properties (GetAccess = public, SetAccess = private)
        point (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        direction (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        diameter (1,1) double {mustBeFinite, mustBeReal}
        %sigma double
        fitInfo struct = struct()
    end

    methods
        function obj = Circle(name, data, associationCriteria, opts)
            % Constructor method for the Circle class
            arguments
                name (1,1) string {mustBeTextScalar, mustBeNonempty}
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                associationCriteria (1,1) AssociationCriteria

                % Name-value options for LM
                opts.MaxIter (1,1) double {mustBeFinite, mustBePositive} = 5000
                opts.StepTol (1,1) double {mustBeFinite, mustBePositive} = 1e-12
                opts.GradTol (1,1) double {mustBeFinite, mustBePositive} = 1e-12
                opts.SSETol (1,1) double {mustBeFinite, mustBePositive} = 1e-17
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
            % First fit a plane to get a point and direction
            % [centroid,dir] = fitPlane(data); %associated plane

            P = Plane("Plane", data, AssociationCriteria.LeastSquares);
            centroid = P.point;
            direction = P.direction;

            % Second, fit a 2d circle using the plane point and direction
            data1 = data-centroid; % translate the data to the orgin
            Rz=getRz(direction); % compute the rotation matrix to rotate dir to align with [0 0 1]
            data2 = data1*Rz; % rotate the data to the XY plane

            rad = guess2dRad(data2); % guess for the radius of the circle
            [point2d,diameter2d] = Circle.fit2dCircle(data,centroid,direction,rad); % associated 2d circle

            data3 = data-mean(data); % move the data to the origin
            [xD,yD,zD]=separateData(data3);
        
            u=@(q) direction(3)*(q(2)-yD)-direction(2)*(q(3)-zD);
            v=@(q) direction(1)*(q(3)-zD)-direction(3)*(q(1)-xD);
            w=@(q) direction(2)*(q(1)-xD)-direction(1)*(q(2)-yD);
            g=@(q) direction(1)*(q(1)-xD)+direction(2)*(q(2)-yD)+direction(3)*(q(3)-zD);
            aNorm = sqrt(direction(1)^2+direction(2)^2+direction(3)^2);
            f=@(q) sqrt( (u(q).^2+v(q).^2+w(q).^2)/aNorm );
            fcn3D = @(q) sqrt( g(q).^2 + (f(q)-q(4)).^2 ); % objective function for 3D circle
            radius = diameter2d/2;
            guess3d = [point2d,direction,radius];
         
            [ans3d, ~, sigma, info] = LM.solve(fcn3D,guess3d, MaxIter, StepTol, GradTol, ...
                SSETol, Lambda, DampingCoeff, SuppressOutput);
            point = [ans3d(1),ans3d(2),ans3d(3)];
            diameter = ans3d(4)*2; % ans3d(4) is the radius, so multiply by 2 to get the diameter
            point = point+centroid;

            obj.point = point;
            obj.direction = direction;
            obj.diameter = diameter;
            %obj.sigma = sigma;

            if exist('info', 'var')
                obj.fitInfo = info;
            end
        end
    end

    methods
        function h = plot(obj, dataColor, dataLabel, fitColor, fitLabel, ax)
            % Function to plot fitted circle
            arguments
                obj
                dataColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(dataColor,0),...
                    mustBeLessThanOrEqual(dataColor,1)} = [0 0.4470 0.7410]
                dataLabel (1,:) char = 'Data Points'
                fitColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(fitColor,0),...
                    mustBeLessThanOrEqual(fitColor,1)} = [0 1 0]
                fitLabel (1,:) char = 'Fitted Circle'     
                ax = []
            end
            
            data = obj.data;
            point = obj.point;
            direction = obj.direction;
            diameter = obj.diameter;

            h = Plot.plotCircle(data, point, direction, diameter, dataColor, dataLabel, fitColor, fitLabel, ax);
        end

        function disp(obj)
            % Custom display for Circle objects
            % Extract base info
            name = string(obj.name);
            associationCriteria = obj.AssociationCriteria;
            data = obj.data;
            point = obj.point(:).';
            direction = obj.direction(:).';
            diameter = obj.diameter;

            % Print formatted output
            fprintf('%s Object\n', class(obj));
            fprintf('  Name:            %s\n', name);
            fprintf('  AssociationCriteria: %s\n', char(associationCriteria));
            fprintf('  Point:           [%.5f  %.5f  %.5f]\n', point);
            fprintf('  Direction:       [%.5f  %.5f  %.5f]\n', direction);
            fprintf('  Diameter:        %.5f\n', diameter);
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
    end

    methods (Static)
        % Associate a 2D circle to coordinate data
        function [point, diameter] = fit2dCircle(data,point,direction,radius)      
            data1 = data-point; % move the data to the origin
            Rz=getRz(direction); % get a rotation matrix to align the data to the XY plane
            data2 = data1*Rz; % rotate the data
        
            guess2d=[[0 0 0],radius]; % guess the point at the origin
            [xD,yD,~]=separateData(data2);
        
            x = @(q) q(1)-xD;
            y = @(q) q(2)-yD;
            fcn2D = @(q) sqrt(x(q).^2+y(q).^2)-q(4); % format the objective function
            
            ans2d = LM.solve(fcn2D,guess2d,5000,1e-20);
            point = [ans2d(1),ans2d(2),ans2d(3)];
            rad2d=ans2d(4);
            diameter=2*rad2d;
        end
    end
end
