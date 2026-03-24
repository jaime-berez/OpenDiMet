classdef Line < Feature
    % LINE Fit and represent a straight line from 3D coordinate data.
    %
    %   Syntax
    %     obj = Line(name, data, fitCriterion)
    %     obj = Line(name, data, fitCriterion, Name = Value)
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
    %     obj - Line feature object
    %       Line scalar
    %
    %   Properties
    %     pnt - 1x3 double, point on the fitted line
    %     dir - 1x3 double, unit direction vector of the fitted line
    %     fitInfo - Structure containing fitting method information
    %
    %   Example
    %     L = Line("Line 1", data, fitType.LeastSquares);
    %     L.plot();

    properties (GetAccess = public, SetAccess = private)
        pnt (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dir (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        fitInfo struct = struct()
    end

    methods
        function obj = Line(name, data, fitCriterion, opts)
            % Constructor for the Line Class
            arguments
                name (1,1) string {mustBeTextScalar}
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                fitCriterion (1,1) fitType

                opts.MaxIter       (1,1) double {mustBeFinite, mustBePositive} = 5000
                opts.StepTol       (1,1) double {mustBeFinite, mustBePositive} = 1e-9
                opts.GradTol       (1,1) double {mustBeFinite, mustBePositive} = 1e-11
                opts.SSETol        (1,1) double {mustBeFinite, mustBePositive} = 1e-19
                opts.Lambda        (1,1) double {mustBeFinite, mustBePositive} = 1e-4
                opts.DampingCoeff  (1,1) double {mustBeFinite, mustBePositive} = 2
                opts.SuppressOutput(1,1) logical = true
                opts.sourceFile (1,1) string = ""
            end

            obj@Feature(name, data, fitCriterion, opts.sourceFile);
            obj.validateAssociation();

            pnt = mean(data);
            dataT = data - pnt;

            A = dataT.' * dataT;
            [eigVec, eigValMat] = eig(A);

            eigVals = diag(eigValMat);
            [~, idx] = max(eigVals);       % largest variance direction

            dir = eigVec(:, idx).';
            dir = dir / norm(dir);

            % residuals = calcStraightnessResiduals(data, pnt, dir);
            proj = dataT * dir'; 
            residuals = vecnorm(dataT - proj * dir, 2, 2);
            obj.sigma = std(residuals);

            obj.pnt = pnt;
            obj.dir = dir; % Store the direction vector in the object
            obj.fitInfo = struct('method', 'SVD', 'description', ['Least-squares line fit using ' ...
                'Singular Value Decomposition.']);
        end

        function h = plot(obj, opts)
            % PLOT Plot line coordinate data and fitted line segment.
            %
            %   Syntax
            %     h = plot(obj)
            %     h = plot(obj, Name = Value)
            %
            %   Input Arguments
            %     obj - Line feature object
            %       Line scalar
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
            %     fitColor - Color of fitted line
            %       RGB triplet | color name | short color code
            %     fitLabel - Legend label for fitted line
            %       string scalar
            %     lineStyle - Line style for fitted line
            %       string scalar
            %     lineWidth - Line width for fitted line
            %       positive scalar double
            %     ax - Target axes for plotting
            %       matlab.graphics.axis.Axes object
            %
            %   Output Arguments
            %     h - Handle to plotted fitted line
            %       Line object
            %
            %   Example
            %     L.plot();
            %     L.plot(fitColor = [0 1 0], lineStyle = "--");

            arguments
                obj
                opts.dataColor = [0 0.4470 0.7410]
                opts.dataLabel (1,1) string = obj.name + " Data"
                opts.dataMarker (1,1) string = "."
                opts.dataMarkerSize (1,1) double {mustBeFinite,mustBePositive} = 12

                opts.fitColor = [0 1 0]
                opts.fitLabel (1,1) string = obj.name + " Fit"
                opts.lineStyle (1,1) string = "dashdot"
                opts.lineWidth (1,1) double {mustBeFinite,mustBePositive} = 2

                opts.ax = []
            end

            ax = opts.ax;
            if isempty(ax) || ~isvalid(ax)
                ax = gca;
            end

            % Parse styling via feature helpers
            dataColor = obj.parseColor(opts.dataColor);
            fitColor  = obj.parseColor(opts.fitColor);
            fitLS     = obj.parseLineStyle(opts.lineStyle);

            % Geometry
            data = obj.data;
            pnt  = obj.pnt;
            dir  = obj.dir;

            cla(ax); hold(ax,'on'); axis(ax,'equal'); axis(ax,'padded'); grid(ax,'on'); view(ax,3);

            % Plot the raw data
            plot3(ax, data(:,1), data(:,2), data(:,3), char(opts.dataMarker), 'Color', dataColor, ...
                'MarkerSize', opts.dataMarkerSize, 'DisplayName', opts.dataLabel);

            % Plot the centroid point
            plot3(ax, pnt(1), pnt(2), pnt(3), 'xk', 'HandleVisibility', 'off');

            % Calculate the length of the line segment
            len = calcLineLength(data, pnt, dir, 1);

            % Compute the end points of the line
            [pStart, pEnd] = calcFeatExtent(pnt, dir, len, 0.5, 1);

            % Plot the line
            h = plot3(ax, [pStart(1) pEnd(1)], [pStart(2) pEnd(2)], [pStart(3) pEnd(3)], ...
                'LineStyle', fitLS, 'Color', fitColor, 'LineWidth', opts.lineWidth, ...
                'DisplayName', opts.fitLabel);

            title(ax, opts.fitLabel);
            xlabel(ax,'x'); ylabel(ax,'y'); zlabel(ax,'z');
            legend(ax, "show", 'FontSize', 12);
            hold(ax, "off");
        end

        function showFitInfo(obj)
            % SHOWFITINFO Display stored fitting information for the Line object.
            %
            %   Syntax
            %     showFitInfo(obj)
            %
            %   Input Arguments
            %     obj - Line feature object
            %       Line scalar
            %
            %   Example
            %     L.showFitInfo();

            if isempty(obj.fitInfo)
                disp('No optimization information available for this object.');
                return;
            end

            if isfield(obj.fitInfo, 'history')
                T = array2table(obj.fitInfo.history, 'VariableNames', obj.fitInfo.labels);
                fprintf('--- Levenberg–Marquardt Optimization Summary ---\n');
                fprintf('Iterations: %d\nFinal SSE: %.4e\n\n', ...
                    obj.fitInfo.iter, obj.fitInfo.final_cost);
                disp(T);
            else
                fprintf('--- Analytical Fit Information ---\n');
                fprintf('Method: %s\n', obj.fitInfo.method);
                fprintf('Description: %s\n', obj.fitInfo.description);
            end
        end

        function disp(obj)
            % DISP Display a formatted summary of the Line feature object.
            %
            %   Syntax
            %     disp(obj)
            %
            %   Input Arguments
            %     obj - Line feature object
            %       Line scalar
            %
            %   Example
            %     disp(L);

            name = string(obj.name);
            ft   = obj.fitType;
            data = obj.data;

            pnt = obj.pnt;
            dir = obj.dir;
            sig = obj.sigma;

            dataClass = class(data);
            dataSize  = size(data);

            fprintf('%s Object\n', class(obj));
            fprintf('  Name:      %s\n', name);
            fprintf('  FitCrit: %s\n', char(ft));
            fprintf('  Point:     [%.4f  %.4f  %.4f]\n', pnt);
            fprintf('  Direction: [%.4f  %.4f  %.4f]\n', dir);
            fprintf('  Sigma:     %.4f\n', sig);
            fprintf('  Data Size: [%s]\n', [num2str(dataSize(1)), ' x ', num2str(dataSize(2))]);
        end

        function reverseDir(obj)
            % REVERSEDIR Reverse the orientation of the fitted line direction vector.
            %
            %   Syntax
            %     reverseDir(obj)
            %
            %   Input Arguments
            %     obj - Line feature object
            %       Line scalar
            %
            %   Example
            %     L.reverseDir();
            
            obj.dir = -obj.dir;
        end
    end
end
