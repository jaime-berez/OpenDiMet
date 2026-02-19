classdef Sphere < Feature
    % SPHERE Class for fitting and representing a sphere form data.
    % ...

    properties (GetAccess = public, SetAccess = private)
        pnt (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dia (1,1) double {mustBeFinite, mustBeReal}
        fitInfo struct = struct()
    end

    methods
        % Constructor for the sphere class
        function obj = Sphere(name, data, ft, opts)
            arguments
                name (1,1) string {mustBeTextScalar}
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                ft (1,1) fitType

                % Name-value options for LM
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

            obj@Feature(name, data, ft, opts.sourceFile, opts.materialSide);
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
            [xData, yData, zData] = separateData(data);

            % Initial guess radius (Intersecting Chords Theorem heuristic)
            rad0 = guess3dRad(data);

            % Format the guess: [cx cy cz r]
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
            % PLOT Plot sphere coordinate data and the fitted sphere.
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
            % Custom display for Sphere objects
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
            fprintf('  AssocCrit: %s\n', char(ft));
            fprintf('  Point:     [%.4f  %.4f  %.4f]\n', pnt);
            fprintf('  Diameter:  %.4f\n', dia);
            fprintf('  Sigma:     %.4f\n', sig);
            fprintf('  Data Size: [%s]\n', [num2str(dataSize(1)), ' x ', num2str(dataSize(2))]);
        end
    end
end
