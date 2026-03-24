classdef Sphere < Feature
    % SPHERE Fit and represent a sphere from 3D coordinate data.
    %
    %   Syntax
    %     obj = Sphere(name, data, fitCriterion)
    %     obj = Sphere(name, data, fitCriterion, Name = Value)
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
    %     materialSide - Material-side designation
    %       MaterialSide enumeration
    %
    %   Output Arguments
    %     obj - Sphere feature object
    %       Sphere scalar
    %
    %   Properties
    %     pnt - 1 x 3 double, fitted sphere center
    %     dia - 1 x 1 double, fitted sphere diameter
    %     fitInfo - Structure containing optimization history
    %
    %   Example
    %     S = Sphere("Sphere 1", data, fitType.LeastSquares);
    %     S.plot();

    properties (GetAccess = public, SetAccess = private)
        pnt (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dia (1,1) double {mustBeFinite, mustBeReal}
        fitInfo struct = struct()
    end

    methods
        % Constructor for the Sphere class
        function obj = Sphere(name, data, fitCriterion, opts)
            arguments
                name (1,1) string {mustBeTextScalar}
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                fitCriterion (1,1) fitType

                opts.MaxIter (1,1) double {mustBeFinite, mustBePositive} = 5000
                opts.StepTol (1,1) double {mustBeFinite, mustBePositive} = 1e-12
                opts.GradTol (1,1) double {mustBeFinite, mustBePositive} = 1e-12
                opts.SSETol (1,1) double {mustBeFinite, mustBePositive} = 1e-16
                opts.Lambda (1,1) double {mustBeFinite, mustBePositive} = 1e-4
                opts.DampingCoeff (1,1) double {mustBeFinite, mustBePositive} = 2
                opts.SuppressOutput (1,1) logical = true
                opts.sourceFile (1,1) string = ""
                opts.materialSide (1,1) MaterialSide = MaterialSide.Unspecified
            end

            obj@Feature(name, data, fitCriterion, opts.sourceFile, opts.materialSide);
            obj.validateAssociation();

            maxIter = opts.MaxIter;
            stepTol = opts.StepTol;
            gradTol = opts.GradTol;
            sseTol  = opts.SSETol;
            lambda  = opts.Lambda;
            dampingCoeff   = opts.DampingCoeff;
            suppressOutput = opts.SuppressOutput;

            pnt0 = mean(data);

            % Break up data into x,y,z components
            xData = data(:,1);
            yData = data(:,2);
            zData = data(:,3);

            % Initial guess radius
            rad0 = guess3dCircRad(data);

            q0 = [pnt0(1), pnt0(2), pnt0(3), rad0];

            % Objective function
            dx = @(q) q(1) - xData;
            dy = @(q) q(2) - yData;
            dz = @(q) q(3) - zData;
            fcn = @(q) sqrt(dx(q).^2 + dy(q).^2 + dz(q).^2) - q(4);

            % Associate a sphere
            [qHat, resnorm, residual, info] = LM.solve(fcn, q0, maxIter, stepTol, gradTol, ...
                sseTol, lambda, dampingCoeff, suppressOutput);

            pntHat = [qHat(1), qHat(2), qHat(3)];
            diaHat = qHat(4) * 2;

            obj.sigma = std(residual);
            obj.pnt = pntHat;
            obj.dia = diaHat;

            if exist('info', 'var')
                obj.fitInfo = info;
            end
        end
    end

    methods
        function h = plot(obj, opts)
            % PLOT Plot sphere coordinate data and fitted sphere surface.
            %
            %   Syntax
            %     h = plot(obj)
            %     h = plot(obj, Name = Value)
            %
            %   Input Arguments
            %     obj - Sphere feature object
            %       Sphere scalar
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
            %     fitColor - Face color of fitted sphere
            %       RGB triplet | color name | short color code
            %     fitLabel - Legend label for fitted sphere
            %       string scalar
            %     fitFaceAlpha - Face transparency of fitted sphere
            %       scalar double in the range [0, 1]
            %     fitEdgeColor - Edge color of fitted sphere
            %       RGB triplet | color name | short color code | "none"
            %     faces - Number of mesh subdivisions used to render the sphere
            %       positive scalar double
            %     ax - Target axes for plotting
            %       matlab.graphics.axis.Axes object
            %
            %   Output Arguments
            %     h - Surface handle for fitted sphere
            %       Surface object
            %
            %   Example
            %     S.plot();
            %     S.plot(fitColor = [0 1 0], fitFaceAlpha = 0.3, faces = 40);

            arguments
                obj
                opts.dataColor = [0 0.4470 0.7410]
                opts.dataLabel (1,1) string = obj.name + " Data"
                opts.dataMarker (1,1) string = "."
                opts.dataMarkerSize (1,1) double {mustBeFinite,mustBePositive} = 12

                opts.fitColor = [0 1 0]
                opts.fitLabel (1,1) string = obj.name + " Fit"
                opts.fitFaceAlpha (1,1) double {mustBeFinite, ...
                    mustBeGreaterThanOrEqual(opts.fitFaceAlpha,0), ...
                    mustBeLessThanOrEqual(opts.fitFaceAlpha,1)} = 0.35
                opts.fitEdgeColor = "none"     % "none" or a color
                opts.faces (1,1) double {mustBeFinite,mustBePositive} = 27

                opts.ax = []
            end

            ax = opts.ax;
            if isempty(ax) || ~isvalid(ax)
                ax = gca;
            end

            % Parse styling via feature helpers
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
            dia  = obj.dia;

            cla(ax); hold(ax,'on'); axis(ax,'equal'); axis(ax,'padded'); grid(ax,'on'); view(ax,3);
            xlabel(ax,'x'); ylabel(ax,'y'); zlabel(ax,'z');
            title(ax, sprintf('%s', opts.fitLabel));

            % Plot coordinate data
            plot3(ax, data(:,1), data(:,2), data(:,3), char(opts.dataMarker), ...
                'Color', dataColor, 'MarkerSize', opts.dataMarkerSize, 'DisplayName', opts.dataLabel);

            % Plot center
            plot3(ax, pnt(1), pnt(2), pnt(3), 'xk', 'HandleVisibility', 'off');

            % Plot a sphere mesh
            faces = round(opts.faces);
            [X, Y, Z] = sphere(faces);
            X = X*(dia/2) + pnt(1);
            Y = Y*(dia/2) + pnt(2);
            Z = Z*(dia/2) + pnt(3);

            % Plot the fitted sphere
            h = surf(ax, X, Y, Z, 'LineStyle','none', 'FaceColor', fitColor, ...
                'FaceAlpha', opts.fitFaceAlpha, 'EdgeColor', edgeColor, 'EdgeAlpha', 0.35, ...
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
            %     obj - Sphere feature object
            %       Sphere scalar
            %
            %   Example
            %     S.showFitInfo();

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
            % DISP Display a formatted summary of the Sphere feature object.
            %
            %   Syntax
            %     disp(obj)
            %
            %   Input Arguments
            %     obj - Sphere feature object
            %       Sphere scalar
            %
            %   Example
            %     disp(S);
            
            name = string(obj.name);
            ft   = obj.fitType;
            data = obj.data;

            pnt = obj.pnt(:).';
            dia = obj.dia;
            sig = obj.sigma;

            dataClass = class(data);
            dataSize = size(data);
            materialSide = obj.materialSide;

            fprintf('%s Object\n', class(obj));
            fprintf('  Name:      %s\n', name);
            if materialSide ~= MaterialSide.Unspecified
                fprintf('  MatSide:   %s\n', char(materialSide));
            end
            fprintf('  FitCrit: %s\n', char(ft));
            fprintf('  Point:     [%.4f  %.4f  %.4f]\n', pnt);
            fprintf('  Diameter:  %.4f\n', dia);
            fprintf('  Sigma:     %.4f\n', sig);
            fprintf('  Data Size: [%s]\n', [num2str(dataSize(1)), ' x ', num2str(dataSize(2))]);
        end
    end
end
