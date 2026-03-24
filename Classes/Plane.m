classdef Plane < Feature
    % PLANE Fit and represent a plane from 3D coordinate data.
    %
    %   Syntax
    %     obj = Plane(name, data, fitCriterion)
    %     obj = Plane(name, data, fitCriterion, Name = Value)
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
    %     obj - Plane feature object
    %       Plane scalar
    %
    %   Properties
    %     pnt - 1x3 double, point on the fitted plane
    %     dir - 1x3 double, unit normal vector of the fitted plane
    %     fitInfo - Structure containing fitting method information
    %
    %   Example
    %     P = Plane("Plane 1", data, fitType.LeastSquares);
    %     P.plot();

    properties (GetAccess = public, SetAccess = private)
        pnt (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dir (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        fitInfo struct = struct()
    end

    methods
        function obj = Plane(name, data, fitCriterion, opts)
            % Constructor for the Plane class
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

            % Computes and plots the centroid of the plane
            dataOrig = data;
            cent = mean(dataOrig, 1);
            dataT = dataOrig - cent;

            A = dataT.' * dataT;
            [eigVec, eigValMat] = eig(A);

            eigVals = diag(eigValMat);
            [~, idx] = min(eigVals);         % smallest eigenvalue

            dir = eigVec(:, idx).';          % 1x3 normal
            dir = dir / norm(dir);

            residuals = dataT * dir.';       % signed distance to plane
            obj.sigma = std(residuals);

            obj.pnt = cent;
            obj.dir = dir;

            obj.fitInfo = struct('method', 'SVD', 'description', ['Least-squares plane fit using ' ...
                'Singular Value Decomposition.']);
        end

        function varargout = plot(obj, opts)
            % PLOT Plot plane coordinate data and fitted plane surface.
            %
            %   Syntax
            %     plot(obj)
            %     plot(obj, Name = Value)
            %     h = plot(obj)
            %     h = plot(obj, Name = Value)
            %
            %   Input Arguments
            %     obj - Plane feature object
            %       Plane scalar
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
            %     fitColor - Face color of fitted plane
            %       RGB triplet | color name | short color code
            %     fitLabel - Legend label for fitted plane
            %       string scalar
            %     fitFaceAlpha - Face transparency of fitted plane
            %       scalar double in the range [0, 1]
            %     fitEdgeColor - Edge color of fitted plane
            %       RGB triplet | color name | short color code | "none"
            %     ax - Target axes for plotting
            %       matlab.graphics.axis.Axes object
            %
            %   Output Arguments
            %     h - Patch handle for fitted plane surface
            %       Patch object
            %
            %   Example
            %     P.plot();
            %     P.plot(fitColor = [0 1 0], fitFaceAlpha = 0.3);

            arguments
                obj
                opts.dataColor = [0 0.4470 0.7410]
                opts.dataLabel (1,1) string = obj.name + " Data"
                opts.dataMarker (1,1) string = "."
                opts.dataMarkerSize (1,1) double {mustBeFinite,mustBePositive} = 10

                opts.fitColor = [0 1 0]
                opts.fitLabel (1,1) string = obj.name + " Fit"
                opts.fitFaceAlpha (1,1) double {mustBeFinite, ...
                    mustBeGreaterThanOrEqual(opts.fitFaceAlpha,0), ...
                    mustBeLessThanOrEqual(opts.fitFaceAlpha,1)} = 0.4
                opts.fitEdgeColor = "k"    % "none" or color

                opts.ax = []
            end

            ax = opts.ax;
            if isempty(ax) || ~isvalid(ax)
                ax = gca;
            end

            % Parse styling
            dataColor = Feature.parseColor(opts.dataColor);
            fitColor  = Feature.parseColor(opts.fitColor);

            if string(opts.fitEdgeColor) == "none"
                edgeColor = "none";
            else
                edgeColor = Feature.parseColor(opts.fitEdgeColor);
            end

            % Geometry
            data = obj.data;
            pnt  = obj.pnt;
            dir  = obj.dir;

            cla(ax); hold(ax,'on'); grid(ax,'on');
            axis(ax,'equal'); axis(ax,'padded'); view(ax,3);
            xlabel(ax,'x'); ylabel(ax,'y'); zlabel(ax,'z');
            title(ax, opts.fitLabel);

            % Plot coordinate data
            plot3(ax, data(:,1), data(:,2), data(:,3), char(opts.dataMarker), ...
                'Color', dataColor, 'MarkerSize', opts.dataMarkerSize, 'DisplayName', opts.dataLabel)

            % Plot centroid
            plot3(ax, pnt(1), pnt(2), pnt(3), 'xk', 'HandleVisibility', 'off');

            [V, F] = genPlaneSurf(data, pnt, dir);  % scalingFactor optional

            h = patch(ax, 'Vertices', V, 'Faces', F, ...
                'FaceColor', fitColor, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', opts.fitFaceAlpha, ...
                'DisplayName', opts.fitLabel);

            legend(ax, "show", 'FontSize', 12);
            hold(ax, "off");
            if nargout > 0
                varargout{1} = h;
            end
        end

        function showFitInfo(obj)
            % SHOWFITINFO Display stored fitting information for the Plane object.
            %
            %   Syntax
            %     showFitInfo(obj)
            %
            %   Input Arguments
            %     obj - Plane feature object
            %       Plane scalar
            %
            %   Example
            %     P.showFitInfo();

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
            % DISP Display a formatted summary of the Plane feature object.
            %
            %   Syntax
            %     disp(obj)
            %
            %   Input Arguments
            %     obj - Plane feature object
            %       Plane scalar
            %
            %   Example
            %     disp(P);

            name = string(obj.name);
            ft   = obj.fitType;
            data = obj.data;

            pnt  = obj.pnt(:).';
            dir  = obj.dir(:).';
            sig  = obj.sigma;

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
            % REVERSEDIR Reverse the orientation of the fitted plane normal vector.
            %
            %   Syntax
            %     reverseDir(obj)
            %
            %   Input Arguments
            %     obj - Plane feature object
            %       Plane scalar
            %
            %   Example
            %     P.reverseDir();
            obj.dir = -obj.dir;
        end
    end
end
