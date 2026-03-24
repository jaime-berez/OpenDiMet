classdef Cylinder < Feature
    % CYLINDER Fit and represent a cylinder from 3D coordinate data.
    %
    %   Syntax
    %     obj = Cylinder(name, data, fitCriterion)
    %     obj = Cylinder(name, data, fitCriterion, Name = Value)
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
    %     obj - Cylinder feature object
    %       Cylinder scalar
    %
    %   Properties
    %     pnt - 1x3 double, point on the cylinder axis
    %     dir - 1x3 double, unit vector of the cylinder axis
    %     dia - 1x1 double, cylinder diameter
    %     fitInfo - Structure containing optimization history
    %
    %   Example
    %     C = Cylinder("Cylinder 1", data, fitType.LeastSquares);
    %     C.plot();

    properties (GetAccess = public, SetAccess = private)
        pnt     (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dir     (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dia     (1,1) double {mustBeFinite, mustBeReal}
        fitInfo struct = struct()
    end

    methods
        function obj = Cylinder(name, data, fitCriterion, opts)
            % Constructor for the Cylinder class
            arguments
                name (1,1) string {mustBeTextScalar}
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                fitCriterion (1,1) fitType

                % Name-value options for LM
                opts.MaxIter (1,1) double {mustBeFinite, mustBePositive} = 5000
                opts.StepTol (1,1) double {mustBeFinite, mustBePositive} = 1e-10
                opts.GradTol (1,1) double {mustBeFinite, mustBePositive} = 1e-11
                opts.SSETol (1,1) double {mustBeFinite, mustBePositive} = 1e-19
                opts.Lambda (1,1) double {mustBeFinite, mustBePositive} = 1e-4
                opts.DampingCoeff (1,1) double {mustBeFinite, mustBePositive} = 2
                opts.SuppressOutput (1,1) logical = true
                opts.sourceFile (1,1) string = ""
                opts.materialSide (1,1) MaterialSide = MaterialSide.Unspecified
            end

            obj@Feature(name, data, fitCriterion, opts.sourceFile, opts.materialSide);
            obj.validateAssociation();

            MaxIter = opts.MaxIter;
            StepTol = opts.StepTol;
            GradTol = opts.GradTol;
            SSETol  = opts.SSETol;
            Lambda  = opts.Lambda;
            DampingCoeff   = opts.DampingCoeff;
            SuppressOutput = opts.SuppressOutput;

            dataTmp = data;           % Nx3
            cent = mean(dataTmp);
            xData = dataTmp(:,1);
            yData = dataTmp(:,2);
            zData = dataTmp(:,3);

            % Initial guesses (point = centroid; directions = axes)
            pnt = cent;

            L = Line("Line", data, fitType.LeastSquares);
            lPnt = L.pnt;

            dir1 = [1,0,0];
            dir2 = [0,1,0];
            dir3 = [0,0,1];
            dir4 = L.dir;

            dist1 = 2*std(yData);
            dist2 = 2*std(zData);
            dist3 = 2*std(xData);
            dist4 = (1/6)*( (max(data(:,1))-min(data(:,1))) + (max(data(:,2))-min(data(:,2))) + (max(data(:,3))-min(data(:,3))) );

            guess1 = [pnt, dir1, dist1];
            guess2 = [pnt, dir2, dist2];
            guess3 = [pnt, dir3, dist3];
            guess4 = [lPnt, dir4, dist4];

            % Residuals
            u = @(q) q(6)*(yData-q(2)) - q(5)*(zData-q(3));
            v = @(q) q(4)*(zData-q(3)) - q(6)*(xData-q(1));
            w = @(q) q(5)*(xData-q(1)) - q(4)*(yData-q(2));
            aNorm = @(q) sqrt(q(4)^2 + q(5)^2 + q(6)^2);
            f = @(q) sqrt((u(q).^2 + v(q).^2 + w(q).^2) / (aNorm(q)^2));
            fcn = @(q) f(q) - q(7);

            % LM Optimization
            [ans1, resnorm(1), residual1, info1] = LM.solve(fcn, guess1, MaxIter, StepTol, GradTol, ...
                SSETol, Lambda, DampingCoeff, SuppressOutput);
                pnt1 = [ans1(1:3)];
                dir1 = [ans1(4:6)]; dir1 = dir1/norm(dir1);
                dist1 = ans1(7);

            [ans2, resnorm(2), residual2, info2] = LM.solve(fcn, guess2, MaxIter, StepTol, GradTol, ...
                SSETol, Lambda, DampingCoeff, SuppressOutput);
                pnt2 = [ans2(1:3)];
                dir2 = [ans2(4:6)]; dir2 = dir2/norm(dir2);
                dist2 = ans2(7);

            [ans3, resnorm(3), residual3, info3] = LM.solve(fcn, guess3, MaxIter, StepTol, GradTol, ...
                SSETol, Lambda, DampingCoeff, SuppressOutput);
                pnt3 = [ans3(1:3)];
                dir3 = [ans3(4:6)]; dir3 = dir3/norm(dir3);
                dist3 = ans3(7);

            [ans4, resnorm(4), residual4, info4] = LM.solve(fcn, guess4, MaxIter, StepTol, GradTol, ...
                SSETol, Lambda, DampingCoeff, SuppressOutput);
                pnt4 = [ans4(1:3)]; 
                dir4 = [ans4(4:6)]; dir4 = dir4/norm(dir4);
                dist4 = ans4(7);

            [~, ind] = min(resnorm);
            if ind==1
                params = ans1; pntSel = pnt1(:)'; dirSel = dir1(:)'; radSel = dist1; info = info1; residual = residual1;
            elseif ind==2
                params = ans2; pntSel = pnt2(:)'; dirSel = dir2(:)'; radSel = dist2; info = info2; residual = residual2;
            elseif ind==3
                params = ans3; pntSel = pnt3(:)'; dirSel = dir3(:)'; radSel = dist3; info = info3; residual = residual3;
            elseif ind==4
                params = ans4; pntSel = pnt4(:)'; dirSel = dir4(:)'; radSel = dist4; info = info4; residual = residual4;
            else
                error('The value of ind must be either 1, 2, 3 or 4')
            end

            % Compute standard deviation
            obj.sigma = std(residual);

            % Assign the values to properties
            obj.pnt = pntSel;
            obj.dir = dirSel;
            obj.dia = radSel * 2; % Diameter is twice the radius

            if exist('info', 'var')
                obj.fitInfo = info;
            end
        end

        function varargout = plot(obj, opts)
            % PLOT Plot cylinder coordinate data, fitted cylinder surface, and centerline.
            %
            %   Syntax
            %     plot(obj)
            %     plot(obj, Name = Value)
            %     h = plot(obj)
            %     h = plot(obj, Name = Value)
            %
            %   Input Arguments
            %     obj - Cylinder feature object
            %       Cylinder scalar
            %
            %   Name-Value Arguments
            %     dataColor - Color of plotted data points
            %       RGB triplet | color name | short color code
            %     dataMarker - Marker symbol for data points
            %       string scalar
            %     dataMarkerSize - Marker size for data points
            %       positive scalar double
            %     dataLabel - Legend label for data points
            %       string scalar
            %     fitColor - Face color of fitted cylinder
            %       RGB triplet | color name | short color code
            %     fitFaceAlpha - Face transparency of fitted cylinder
            %       scalar double in the range [0, 1]
            %     fitEdgeColor - Edge color of fitted cylinder
            %       RGB triplet | color name | short color code | "none"
            %     fitLabel - Legend label for fitted cylinder
            %       string scalar
            %     lineStyle - Line style of cylinder centerline
            %       string scalar
            %     lineWidth - Line width of cylinder centerline
            %       positive scalar double
            %     faces - Number of circumferential faces used to render the cylinder
            %       positive scalar double
            %     ax - Target axes for plotting
            %       matlab.graphics.axis.Axes object
            %
            %   Output Arguments
            %     h - Patch handle for fitted cylinder surface
            %       Patch object
            %
            %   Example
            %     C.plot();
            %     C.plot(fitColor = [0 1 0], fitFaceAlpha = 0.3, faces = 40);

            arguments
                obj
                opts.dataColor = [0 0.4470 0.7410]
                opts.dataMarker (1,1) string = "."
                opts.dataMarkerSize (1,1) double {mustBeFinite,mustBePositive} = 12
                opts.dataLabel (1,1) string = obj.name + " Data"

                opts.fitColor = [0 1 0]
                opts.fitFaceAlpha (1,1) double {mustBeFinite,mustBeGreaterThanOrEqual(opts.fitFaceAlpha,0),mustBeLessThanOrEqual(opts.fitFaceAlpha,1)} = 0.4
                opts.fitEdgeColor = "none"
                opts.fitLabel (1,1) string = obj.name + " Fit"

                opts.lineStyle (1,1) string = "dashdot"
                opts.lineWidth (1,1) double {mustBeFinite,mustBePositive} = 1

                opts.faces (1,1) double {mustBeFinite,mustBePositive} = 50
                opts.ax = []
            end

            ax = opts.ax;
            if isempty(ax) || ~isvalid(ax)
                ax = gca;
            end

            % Parse styling
            dataColor = obj.parseColor(opts.dataColor);
            fitColor  = obj.parseColor(opts.fitColor);

            if string(opts.fitEdgeColor) == "none"
                edgeColor = "none";
            else
                edgeColor = obj.parseColor(opts.fitEdgeColor);
            end

            centerLS = obj.parseLineStyle(opts.lineStyle);

            % Geometry
            data = obj.data;          % Nx3
            pnt  = obj.pnt(:).';      % 1x3
            dir  = obj.dir(:).';      % 1x3 (unit)
            dist = obj.dia/2;         % radius

            % Clear + axes setup
            cla(ax);
            hold(ax, 'on'); axis(ax, 'equal'); axis(ax, 'padded'); grid(ax, 'on'); view(ax,3);
            xlabel(ax,'x'); ylabel(ax,'y'); zlabel(ax,'z');
            title(ax, opts.fitLabel);

            % Plot raw data
            plot3(ax, data(:,1), data(:,2), data(:,3), opts.dataMarker, 'Color', dataColor, ...
                'MarkerSize', opts.dataMarkerSize, 'DisplayName', opts.dataLabel);
            hold(ax,'on'); axis(ax,'equal'); axis(ax,'padded'); grid(ax,'on');

            % Mark centroid / axis point
            plot3(ax, pnt(1), pnt(2), pnt(3), 'xk', 'HandleVisibility', 'off');

            % Create a Cylinder
            faces = round(opts.faces);
            radius = obj.dia/2;

            % Height of the point cloud
            dataT = data - pnt;
            a = dir(1); b = dir(2); c = dir(3);

            % Rotation that aligns axis with +Z
            Rz = [1-a^2/(1+c) -a*b/(1+c) a; -a*b/(1+c) 1-b^2/(1+c) b; -a -b c];
            dataTR = dataT * Rz;

            scale = 0.25;
            height = (max(dataTR(:,3)) - min(dataTR(:,3))) * (1+scale);

            [V, F] = genCylSurf(obj.pnt, obj.dir, radius, height, faces);

            h = patch(ax, 'Vertices', V, 'Faces', F, ...
                'FaceColor', fitColor, ...
                'EdgeColor', edgeColor, ...
                'FaceAlpha', opts.fitFaceAlpha, ...
                'DisplayName', opts.fitLabel);

            [pnt1, pnt2] = calcFeatExtent(obj.pnt, obj.dir, height, 0.5, 1.2); % bias of 0.5
            plot3(ax, [pnt1(1) pnt2(1)], [pnt1(2) pnt2(2)], [pnt1(3) pnt2(3)], 'LineStyle', centerLS, ...
                'LineWidth', opts.lineWidth, 'Color', [0 0 0], 'HandleVisibility', 'off');

            % End circles
            topPnt    = [0, 0, height*0.5];   topPnt    = topPnt    / Rz + pnt;
            botPnt    = [0, 0,-height*0.5];   botPnt    = botPnt    / Rz + pnt;

            plotEndCircle(topPnt, dir, dist*2, faces);
            plotEndCircle(botPnt, dir, dist*2, faces);

            % Legend
            legend(ax, "show", 'FontSize', 12);
            hold(ax, "off");
            if nargout > 0
                varargout{1} = h;
            end
        end

        function showFitInfo(obj)
            % SHOWFITINFO Display the stored Levenberg-Marquardt optimization summary.
            %
            %   Syntax
            %     showFitInfo(obj)
            %
            %   Input Arguments
            %     obj - Cylinder feature object
            %       Cylinder scalar
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
            % DISP Display a formatted summary of the Cylinder feature object.
            %
            %   Syntax
            %     disp(obj)
            %
            %   Input Arguments
            %     obj - Cylinder feature object
            %       Cylinder scalar
            %
            %   Example
            %     disp(C);

            name  = string(obj.name);
            ft    = obj.fitType;
            data  = obj.data;

            pnt = obj.pnt(:).';
            dir = obj.dir(:).';
            dia = obj.dia;

            sig = obj.sigma;

            dataClass = class(data);
            dataSize  = size(data);
            materialSide = obj.materialSide;

            fprintf('%s Object\n', class(obj));
            fprintf('  Name:      %s\n', name);

            if materialSide ~= MaterialSide.Unspecified
                fprintf('  MatSide:   %s\n', char(materialSide));
            end

            fprintf('  FitCrit: %s\n', char(ft));
            fprintf('  Point:     [%.4f  %.4f  %.4f]\n', pnt);
            fprintf('  Direction: [%.4f  %.4f  %.4f]\n', dir);
            fprintf('  Diameter:  %.4f\n', dia);
            fprintf('  Sigma:     %.4f\n', sig);
            fprintf('  Data Size: [%s]\n', [num2str(dataSize(1)), ' x ', num2str(dataSize(2))]);
        end

        function reverseDir(obj)
            % REVERSEDIR Reverse the orientation of the cylinder axis direction.
            %
            %   Syntax
            %     reverseDir(obj)
            %
            %   Input Arguments
            %     obj - Cylinder feature object
            %       Cylinder scalar
            %
            %   Example
            %     C.reverseDir();
            obj.dir = -obj.dir;
        end
    end
end
