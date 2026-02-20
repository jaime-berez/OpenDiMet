classdef Circle < Feature
% CIRCLE Class for fitting and representing a 2D or 3D circle feature from
% point cloud data. 
% The circle class represents a circular feature reconstructed from 2D or
% 3D coordinate data. The object is constructed directly via a fit-based
% constructor using the specified fitType. It inherits from
% Feature and stores both geometric description and the fitting parameters
% used to obtain it.
%
% Properties:
% pnt - 1 x 3 double, center of the fitted circle.
% dir - 1 x 3 double, unit normal vector of the circle's plane.
% dia - 1 x 1 double, fitted circle diameter.

    properties (GetAccess = public, SetAccess = private)
        pnt (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dir (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dia (1,1) double {mustBeFinite, mustBeReal}
        fitInfo struct = struct()
    end

    methods
        function obj = Circle(name, data, ft, opts)
            % Constructor method for the Circle class
            arguments
                name (1,1) string {mustBeTextScalar}
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                ft (1,1) fitType

                % Name-value options for LM
                opts.MaxIter (1,1) double {mustBeFinite, mustBePositive} = 5000
                opts.StepTol (1,1) double {mustBeFinite, mustBePositive} = 1e-12
                opts.GradTol (1,1) double {mustBeFinite, mustBePositive} = 1e-12
                opts.SSETol (1,1) double {mustBeFinite, mustBePositive} = 1e-17
                opts.Lambda (1,1) double {mustBeFinite, mustBePositive} = 1e-4
                opts.DampingCoeff (1,1) double {mustBeFinite, mustBePositive} = 2
                opts.SuppressOutput (1,1) logical = true
                opts.sourceFile (1,1) string = ""
            end

            obj@Feature(name, data, ft, opts.sourceFile);
            obj.validateAssociation();

            % LM options
            MaxIter = opts.MaxIter;
            StepTol = opts.StepTol;
            GradTol = opts.GradTol;
            SSETol  = opts.SSETol;
            Lambda  = opts.Lambda;
            DampingCoeff   = opts.DampingCoeff;
            SuppressOutput = opts.SuppressOutput;

            % First fit a plane to get a point and direction
            P = Plane("Plane", data, fitType.LeastSquares);
            cent = P.pnt;      % centroid
            dir  = P.dir;      % plane normal (unit)

            % Second, fit a 2d circle using the plane point and direction
            dataT = data - cent;     % translated data
            R = getRz(dir);         % rotation matrix to align dir with [0 0 1]
            dataTR = dataT * R;     % translated, then rotated data

            rad = guess2dRad(dataTR); % guess for the radius of the circle

            % associated 2D circle
            [pnt2d, dia2d] = Circle.fit2dCircle(data, cent, dir, rad);

            dataT2 = data - mean(data);     % translated data (to origin via mean)
            [xData, yData, zData] = separateData(dataT2);

            u = @(q) dir(3)*(q(2)-yData) - dir(2)*(q(3)-zData);
            v = @(q) dir(1)*(q(3)-zData) - dir(3)*(q(1)-xData);
            w = @(q) dir(2)*(q(1)-xData) - dir(1)*(q(2)-yData);
            g = @(q) dir(1)*(q(1)-xData) + dir(2)*(q(2)-yData) + dir(3)*(q(3)-zData);

            aNorm = sqrt(dir(1)^2 + dir(2)^2 + dir(3)^2);

            f = @(q) sqrt( (u(q).^2 + v(q).^2 + w(q).^2) / aNorm );
            fcn3D = @(q) sqrt( g(q).^2 + (f(q)-q(4)).^2 ); % objective function for 3D circle

            rad3d = dia2d/2;
            guess3d = [pnt2d, dir, rad3d];

            [ans3d, resnorm3d, residual3d, info] = LM.solve(fcn3D, guess3d, MaxIter, StepTol, GradTol, ...
                SSETol, Lambda, DampingCoeff, SuppressOutput);

            pnt = [ans3d(1), ans3d(2), ans3d(3)];
            dia = ans3d(4)*2; % ans3d(4) is the radius, so multiply by 2 to get the diameter

            pnt = pnt + cent;

            obj.pnt = pnt;
            obj.dir = dir;
            obj.dia = dia;
            obj.sigma = std(residual3d);

            if exist('info', 'var')
                obj.fitInfo = info;
            end
        end
    end

    methods
        function h = plot(obj, opts)
            arguments
                obj
                opts.dataColor = [0 0.4470 0.7410]
                opts.dataLabel (1,1) string = obj.name + " Data"
                opts.dataMarker (1,1) string = "."
                opts.dataMarkerSize (1,1) double {mustBeFinite,mustBePositive} = 12

                opts.fitColor = [0 1 0]
                opts.fitLabel (1,1) string = obj.name + " Fit"
                opts.lineStyle (1,1) string = "solid"
                opts.lineWidth (1,1) double {mustBeFinite,mustBePositive} = 2

                opts.nFitPoints (1,1) double {mustBeFinite,mustBePositive} = 200
                opts.ax = []
            end

            ax = opts.ax;
            if isempty(ax) || ~isvalid(ax)
                ax = gca;
            end

            % Parse styling via feature helpers
            dataColor = Feature.parseColor(opts.dataColor);
            fitColor  = Feature.parseColor(opts.fitColor);
            fitLS     = Feature.parseLineStyle(opts.lineStyle);

            data = obj.data;
            pnt  = obj.pnt;
            dir  = obj.dir;
            dia  = obj.dia;

            cla(ax); hold(ax,'on'); grid(ax,'on'); axis(ax,'equal'); axis(ax,'padded'); view(ax,3);
            xlabel(ax,'x'); ylabel(ax,'y'); zlabel(ax,'z');
            title(ax, opts.fitLabel);

            % Plot raw data
            plot3(ax, data(:,1), data(:,2), data(:,3), char(opts.dataMarker), ...
                    'Color', dataColor, 'MarkerSize', opts.dataMarkerSize, 'DisplayName', opts.dataLabel);

            % Plot the centroid (circle center)
            plot3(ax, pnt(1), pnt(2), pnt(3), 'xk', 'HandleVisibility', 'off');

            pts = calcCirclePoints(pnt, dir, dia, round(opts.nFitPoints));
            [X, Y, Z] = separateData(pts);

            % Fitted circle
            h = plot3(ax, X, Y, Z, 'LineStyle', fitLS, 'Color', fitColor, 'LineWidth', opts.lineWidth, ...
                'DisplayName', opts.fitLabel);

            legend(ax, "show", 'FontSize', 12);
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
            name = string(obj.name);
            ft = obj.fitType; 
            data = obj.data;

            pnt = obj.pnt(:).';
            dir = obj.dir(:).';
            dia = obj.dia;

            sig = obj.sigma;

            dataClass = class(data);
            dataSize  = size(data);

            fprintf('%s Object\n', class(obj));
            fprintf('  Name:      %s\n', name);
            fprintf('  AssocCrit: %s\n', char(ft));
            fprintf('  Point:     [%.5f  %.5f  %.5f]\n', pnt);
            fprintf('  Direction: [%.5f  %.5f  %.5f]\n', dir);
            fprintf('  Diameter:  %.5f\n', dia);
            fprintf('  Sigma:     %.5f\n', sig);
            fprintf('  Data Size: [%s]\n', [num2str(dataSize(1)), ' x ', num2str(dataSize(2))]);
        end

        function reverseDir(obj)
            obj.dir = -obj.dir;
        end
    end

    methods (Static)
        function [pnt, dia] = fit2dCircle(data, pnt, dir, rad)
            dataT = data - pnt;     % translated data
            R = getRz(dir);        % rotation matrix to align the data to the XY plane
            dataTR = dataT * R;    % rotate the data

            guess2d = [[0 0 0], rad]; % guess the point at the origin
            [xData, yData, ~] = separateData(dataTR);

            x = @(q) q(1) - xData;
            y = @(q) q(2) - yData;
            fcn2D = @(q) sqrt(x(q).^2 + y(q).^2) - q(4);

            MaxIter        = 5000;
            StepTol        = 1e-20;
            GradTol        = 1e-12;
            SSETol         = 1e-18;
            Lambda         = 1e-4;
            DampingCoeff   = 2;
            SuppressOutput = true;

            ans2d = LM.solve(fcn2D, guess2d, MaxIter, StepTol, GradTol, ...
                SSETol, Lambda, DampingCoeff, SuppressOutput);

            pnt = [ans2d(1), ans2d(2), ans2d(3)];
            rad2d = ans2d(4);
            dia = 2 * rad2d;
        end
    end
end
