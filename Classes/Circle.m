classdef Circle < Feature
    % CIRCLE Fit and represent a circular feature from 3D coordinate data.
    %
    %   Syntax
    %     obj = Circle(name, data, fitCriterion)
    %     obj = Circle(name, data, fitCriterion, Name = Value)
    %
    %   Input Arguments
    %     name - Feature name
    %       string scalar | character vector
    %     data - Measured 3D point coordinates
    %       Nx3 double matrix
    %     fitCriterion - Fitting criterion
    %       fitType enumeration
    %
    %   Name-Value Arguments
    %     MaxIter - Maximum number of LM iterations
    %       positive scalar double
    %     StepTol - Step-size convergence tolerance
    %       positive scalar double
    %     GradTol - Gradient convergence tolerance
    %       positive scalar double
    %     SSETol - Sum-of-squared-errors convergence tolerance
    %       positive scalar double
    %     Lambda - Initial damping parameter for LM
    %       positive scalar double
    %     DampingCoeff - LM damping update coefficient
    %       positive scalar double
    %     SuppressOutput - Flag to suppress optimizer output
    %       logical scalar
    %     sourceFile - Source file associated with the data
    %       string scalar
    %
    %   Output Arguments
    %     obj - Circle feature object
    %       Circle scalar
    %
    %   Properties
    %     pnt - 1x3 double, center of the fitted circle
    %     dir - 1x3 double, unit normal vector of the circle plane
    %     dia - 1x1 double, circle diameter
    %     fitInfo - Structure containing optimization history
    %
    %   Example
    %     C = Circle("Circle 1", data, fitType.LeastSquares);
    %     C.plot();

    properties (GetAccess = public, SetAccess = private)
        pnt (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dir (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dia (1,1) double {mustBeFinite, mustBeReal}
        fitInfo struct = struct()
    end

    methods
        function obj = Circle(name, data, fitCriterion, opts)
            % Constructor for the Circle class
            arguments
                name (1,1) string {mustBeTextScalar}
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                fitCriterion (1,1) fitType

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

            obj@Feature(name, data, fitCriterion, opts.sourceFile);
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
            R = rotMatA2Z(dir);         % rotation matrix to align dir with [0 0 1]
            dataTR = dataT * R;     % translated, then rotated data

            rad = guess2dCircRad(dataTR); % guess for the radius of the circle

            % associated 2D circle
            [pnt2d, dia2d] = Circle.fit2dCircle(data, cent, dir, rad);

            dataT2 = data - mean(data);     % translated data (to origin via mean)
            % [xData, yData, zData] = separateData(dataT2);
            xData = dataT2(:,1);
            yData = dataT2(:,2);
            zData = dataT2(:,3);

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
            % PLOT Plot circle coordinate data and fitted circle.
            %
            %   Syntax
            %     h = plot(obj)
            %     h = plot(obj, Name = Value)
            %
            %   Input Arguments
            %     obj - Circle feature object
            %       Circle scalar
            %
            %   Name-Value Arguments
            %     dataColor - Color of plotted data points
            %       RGB triplet | color name | short color code
            %     dataLabel - Legend label for data points
            %       string scalar
            %     dataMarker - Marker symbol for data points
            %       string scalar
            %     dataMarkerSize - Marker size for data points
            %       positive scalar double
            %     fitColor - Color of fitted circle
            %       RGB triplet | color name | short color code
            %     fitLabel - Legend label for fitted circle
            %       string scalar
            %     lineStyle - Line style for fitted circle
            %       string scalar
            %     lineWidth - Line width for fitted circle
            %       positive scalar double
            %     nFitPoints - Number of points used to render fitted circle
            %       positive scalar double
            %     ax - Target axes for plotting
            %       matlab.graphics.axis.Axes object
            %
            %   Output Arguments
            %     h - Handle to plotted circle line
            %       Line object
            %
            %   Example
            %     C.plot();
            %     C.plot(fitColor = [0 1 0], nFitPoints = 300);

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

            pts = calcPntsOnCirc(pnt, dir, dia, round(opts.nFitPoints));
            % [X, Y, Z] = separateData(pts);
            X = pts(:,1);
            Y = pts(:,2);
            Z = pts(:,3);

            % Fitted circle
            h = plot3(ax, X, Y, Z, 'LineStyle', fitLS, 'Color', fitColor, 'LineWidth', opts.lineWidth, ...
                'DisplayName', opts.fitLabel);

            legend(ax, "show", 'FontSize', 12);
            hold(ax, "off");
        end

        function showFitInfo(obj)
            % SHOWFITINFO Display the stored Levenberg-Marquardt optimization summary.
            %
            %   Syntax
            %     showFitInfo(obj)
            %
            %   Input Arguments
            %     obj - Circle feature object
            %       Circle scalar
            %
            %   Example
            %     C.showFitInfo();

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
            % DISP Display a formatted summary of the Circle feature object.
            %
            %   Syntax
            %     disp(obj)
            %
            %   Input Arguments
            %     obj - Circle feature object
            %       Circle scalar
            %
            %   Example
            %     disp(C);

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
            % REVERSEDIR Reverse the orientation of the circle normal vector.
            %
            %   Syntax
            %     reverseDir(obj)
            %
            %   Input Arguments
            %     obj - Circle feature object
            %       Circle scalar
            %
            %   Example
            %     C.reverseDir();

            obj.dir = -obj.dir;
        end
    end

    methods (Static)
        function [pnt, dia] = fit2dCircle(data, pnt, dir, rad)
            % FIT2DCIRCLE Fit a circle to data projected onto a plane.
            %
            %   Syntax
            %     [pnt, dia] = Circle.fit2dCircle(data, pnt, dir, rad)
            %
            %   Input Arguments
            %     data - Measured 3D point coordinates
            %       Nx3 double matrix
            %     pnt - Point on the circle plane used for translation
            %       1x3 double vector
            %     dir - Unit normal vector of the circle plane
            %       1x3 double vector
            %     rad - Initial guess for the circle radius
            %       positive scalar double
            %
            %   Output Arguments
            %     pnt - Estimated center of the fitted circle
            %       1x3 double vector
            %     dia - Diameter of the fitted circle
            %       1x1 double
            %
            %   Example
            %     [pnt, dia] = Circle.fit2dCircle(data, pnt, dir, rad);

            dataT = data - pnt;     % translated data
            R = rotMatA2Z(dir);        % rotation matrix to align the data to the XY plane
            dataTR = dataT * R;    % rotate the data

            guess2d = [[0 0 0], rad]; % guess the point at the origin
            % [xData, yData, ~] = separateData(dataTR);
            xData = dataTR(:,1);
            yData = dataTR(:,2);

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
