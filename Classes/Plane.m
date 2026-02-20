classdef Plane < Feature
    % PLANE Class for fitting and representing a plane from coordinate data.
    % The Plane class constructs a plane feature from measured coordinate points
    % according to the specified fitType. It inherits
    % from Feature and stores both the original data and the associated
    % feature parameters.
    %
    % Properties:
    % pnt     : (1x3 double) point on the associated plane.
    % dir     : (1x3 double) unit normal vector of the associated plane.
    % fitInfo : (struct) struct describing how the plane was fit (e.g.,
    %          method name, optimization history).

    properties (GetAccess = public, SetAccess = private)
        pnt (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dir (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        fitInfo struct = struct()
    end

    methods
        function obj = Plane(name, data, ft, opts)
            % Plane Constructor
            arguments
                name (1,1) string {mustBeTextScalar}
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                ft (1,1) fitType

                opts.MaxIter       (1,1) double {mustBeFinite, mustBePositive} = 5000
                opts.StepTol       (1,1) double {mustBeFinite, mustBePositive} = 1e-9
                opts.GradTol       (1,1) double {mustBeFinite, mustBePositive} = 1e-11
                opts.SSETol        (1,1) double {mustBeFinite, mustBePositive} = 1e-19
                opts.Lambda        (1,1) double {mustBeFinite, mustBePositive} = 1e-4
                opts.DampingCoeff  (1,1) double {mustBeFinite, mustBePositive} = 2
                opts.SuppressOutput(1,1) logical = true
                opts.sourceFile (1,1) string = ""
            end

            obj@Feature(name, data, ft, opts.sourceFile);
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

        function h = plot(obj, opts)
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

            [X, Y, Z] = calcPlaneCorners(data, pnt, dir); % corners for plotting

            h = fill3(ax, X, Y, Z, fitColor, ...
                'EdgeColor', edgeColor, ...
                'FaceAlpha', opts.fitFaceAlpha, ...
                'DisplayName', opts.fitLabel);

            legend(ax, "show", 'FontSize', 12);
            hold(ax, "off");
        end

        function showFitInfo(obj)
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
            % Custom display for Plane object
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
            fprintf('  AssocCrit: %s\n', char(ft));
            fprintf('  Point:     [%.4f  %.4f  %.4f]\n', pnt);
            fprintf('  Direction: [%.4f  %.4f  %.4f]\n', dir);
            fprintf('  Sigma:     %.4f\n', sig);
            fprintf('  Data Size: [%s]\n', [num2str(dataSize(1)), ' x ', num2str(dataSize(2))]);
        end

        function reverseDir(obj)
            obj.dir = -obj.dir;
        end
    end
end
