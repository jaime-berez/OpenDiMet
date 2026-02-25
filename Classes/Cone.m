classdef Cone < Feature
% CONE Class for fitting and representing a cone from 3D data.
% The Cone class constructs a conical feature from measured 3D points
% using a fit-based constructor using the specified fitType. It inherits 
% from Feature and stores both geometric description and the fitting parameters 
% used to obtain it.
%
% Properties:
% pnt    - 1 x 3 double, point on the cone axis
% dir    - 1 x 3 double, unit vector of the cone axis
% ang    - 1 x 1 double, cone angle
% dist   - 1 x 1 double, orthogonal distance from point on the axis to the surface
% apex   - 1 x 3 double, cone apex
% smallR - 1 x 1 double, radius near the apex
% bigR   - 1 x 1 double, radius at the far end
% height - 1 x 1 double, cone height

    properties (GetAccess = public, SetAccess = private)
        pnt (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dir (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        ang (1,1) double {mustBeFinite, mustBeReal, mustBeNonNan}
        dist (1,1) double {mustBeFinite, mustBeReal, mustBeNonnegative, mustBeNonNan}
        apex (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan}
        smallR (1,1) double {mustBeFinite, mustBeReal, mustBeNonNan}
        bigR (1,1) double {mustBeFinite, mustBeReal, mustBeNonNan}
        height (1,1) {mustBeFinite, mustBeReal, mustBeNonNan}
        fitInfo struct = struct()
    end

    methods
        function obj = Cone(name, data, ft, opts)
            % Constructor method for the Cone class
            arguments
                name (1,1) string {mustBeTextScalar}
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                ft (1,1) fitType
                opts.MaxIter (1,1) double {mustBeFinite, mustBePositive} = 5000
                opts.StepTol (1,1) double {mustBeFinite, mustBePositive} = 1e-9
                opts.GradTol (1,1) double {mustBeFinite, mustBePositive} = 1e-11
                opts.SSETol (1,1) double {mustBeFinite, mustBePositive} = 1e-19
                opts.Lambda (1,1) double {mustBeFinite, mustBePositive} = 1e-4
                opts.DampingCoeff (1,1) double {mustBeFinite, mustBePositive} = 2
                opts.SuppressOutput (1,1) logical = true
                opts.sourceFile (1,1) string = ""
                opts.materialSide (1,1) MaterialSide = MaterialSide.Unspecified
            end

            obj@Feature(name, data, ft, opts.sourceFile, opts.materialSide);
            obj.validateAssociation();

            MaxIter = opts.MaxIter;
            StepTol = opts.StepTol;
            GradTol = opts.GradTol;
            SSETol  = opts.SSETol;
            Lambda  = opts.Lambda;
            DampingCoeff   = opts.DampingCoeff;
            SuppressOutput = opts.SuppressOutput;

            cent = mean(data);
            dataT = data - cent; % translated data to origin

            % Break the data up into separate x,y,z vectors
            xData = dataT(:,1);
            yData = dataT(:,2);
            zData = dataT(:,3);

            C = Cylinder("Cylinder", dataT, fitType.LeastSquares);
            cylPnt = C.pnt;
            cylDir = C.dir;
            cylDia = C.dia;

            pnt = cylPnt;      % [x,y,z]
            dir = cylDir;      % [A,B,C]

            ang5  = deg2rad(1);
            ang45 = deg2rad(45);
            ang85 = deg2rad(89);

            dist = cylDia/2;

            % Combine the initial guess data into guess vectors
            guess1 = [pnt(1), pnt(2), pnt(3), dir(1), dir(2), dir(3), ang5,  dist];
            guess2 = [pnt(1), pnt(2), pnt(3), dir(1), dir(2), dir(3), ang45, dist];
            guess3 = [pnt(1), pnt(2), pnt(3), dir(1), dir(2), dir(3), ang85, dist];

            fcn = @(q) Cone.opFun(q, xData, yData, zData);

            [ans1, res(1), residual1, info1] = LM.solve(fcn, guess1, MaxIter, StepTol, GradTol, ...
                SSETol, Lambda, DampingCoeff, SuppressOutput);
            [ans2, res(2), residual2, info2] = LM.solve(fcn, guess2, MaxIter, StepTol, GradTol, ...
                SSETol, Lambda, DampingCoeff, SuppressOutput);
            [ans3, res(3), residual3, info3] = LM.solve(fcn, guess3, MaxIter, StepTol, GradTol, ...
                SSETol, Lambda, DampingCoeff, SuppressOutput);

            [~, ind] = min(res);

            answers   = {ans1, ans2, ans3};
            infos     = {info1, info2, info3};
            residuals = {residual1, residual2, residual3};

            qbest    = answers{ind};
            bestInfo = infos{ind};
            resBest  = residuals{ind};

            obj.sigma = std(resBest);

            [pnt, dir, ang, dist, apex] = formatConeOutput(qbest, cent);

            % Derive smallR / bigR from data span
            [smallR, bigR, height] = calcConeRadii(data, pnt, apex, dir, ang, dist);

            obj.pnt = pnt;
            obj.dir = dir;
            obj.ang = ang;
            obj.dist = dist;
            obj.apex = apex;
            obj.smallR = smallR;
            obj.bigR = bigR;
            obj.height = height;

            if exist('bestInfo', 'var')
                obj.fitInfo = bestInfo;
            end
        end
    end

    methods
        function h = plot(obj, opts)
            % PLOT Plot cone coordinate data and the fitted cone.
            arguments
                obj
                opts.dataColor = [0 0.4470 0.7410]
                opts.dataLabel (1,1) string = obj.name + " Data"
                opts.dataMarker (1,1) string = "."
                opts.dataMarkerSize (1,1) double {mustBeFinite,mustBePositive} = 10

                opts.fitColor = [0 1 0]
                opts.fitLabel (1,1) string = obj.name + " Fit"
                opts.fitFaceAlpha (1,1) double {mustBeFinite,mustBeGreaterThanOrEqual(opts.fitFaceAlpha,0),mustBeLessThanOrEqual(opts.fitFaceAlpha,1)} = 0.5
                opts.fitEdgeColor = "none"
                opts.faces (1,1) double {mustBeFinite,mustBePositive} = 27

                opts.lineStyle (1,1) string = "dashdot"
                opts.lineWidth (1,1) double {mustBeFinite,mustBePositive} = 1
                opts.lineColor = "k"

                opts.ax = []
            end

            ax = opts.ax;
            if isempty(ax) || ~isvalid(ax)
                ax = gca;
            end

            % Parse styling via feature helpers
            dataColor = Feature.parseColor(opts.dataColor);
            fitColor  = Feature.parseColor(opts.fitColor);
            centerLC  = Feature.parseColor(opts.lineColor);
            centerLS  = Feature.parseLineStyle(opts.lineStyle);

            if string(opts.fitEdgeColor) == "none"
                edgeColor = "none";
            else
                edgeColor = Feature.parseColor(opts.fitEdgeColor);
            end

            % Geometry
            data   = obj.data;
            pnt    = obj.pnt;
            dir    = obj.dir;
            smallR = obj.smallR;
            bigR   = obj.bigR;
            height = obj.height;

            cla(ax); hold(ax,'on'); axis(ax,'equal'); axis(ax,'padded'); grid(ax,'on'); view(ax,3);
            xlabel(ax,'x'); ylabel(ax,'y'); zlabel(ax,'z');
            title(ax, opts.fitLabel);

            % Plot raw data
            plot3(ax, data(:,1), data(:,2), data(:,3), char(opts.dataMarker), ...
                'Color', dataColor, 'MarkerSize', opts.dataMarkerSize, 'DisplayName', opts.dataLabel);

            % Plot centroid (axis point)
            plot3(ax, pnt(1), pnt(2), pnt(3), 'xk', 'HandleVisibility','off');

            % Create a cone based on the parameters calculated above
            faces = round(opts.faces);
            [X, Y, Z] = cylinder([smallR bigR], faces);
            Z = Z*height - height/2;

            cone = xyz2Mat(X, Y, Z);

            R = rotMatA2Z(dir); % rotation matrix

            % Rotate the cone to match the direction of the data, then translate to match the position
            cone1 = cone / R;
            cone2 = cone1 + pnt;

            % Plot the cone
            [Xc, Yc, Zc] = mat2xyz(cone2);

            h = surf(ax, Xc, Yc, Zc, 'LineStyle','none', ...
                'EdgeColor', edgeColor, 'FaceAlpha', opts.fitFaceAlpha, 'FaceColor', fitColor, ...
                'DisplayName', opts.fitLabel);

            p1 = pnt - (height/2)*dir;
            p2 = pnt + (height/2)*dir;

            plot3(ax, [p1(1) p2(1)], [p1(2) p2(2)], [p1(3) p2(3)], ...
                'LineStyle', centerLS, 'LineWidth', opts.lineWidth, ...
                'Color', centerLC, 'HandleVisibility','off');

            legend(ax, 'show', 'FontSize', 12);
            hold(ax,'off');
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
            % Custom display for Cone objects
            name = string(obj.name);
            ft   = obj.fitType;
            data = obj.data;

            pnt  = obj.pnt(:).';
            dir  = obj.dir(:).';
            ang  = obj.ang;
            dist = obj.dist;

            apex   = obj.apex;
            smallR = obj.smallR;
            bigR   = obj.bigR;
            height = obj.height;

            sig = obj.sigma;

            dataClass = class(data);
            dataSize  = size(data);
            materialSide = obj.materialSide;

            fprintf('%s Object\n', class(obj));
            fprintf('  Name:           %s\n', name);
            if materialSide ~= MaterialSide.Unspecified
                fprintf('  MatSide:        %s\n', char(materialSide));
            end
            fprintf('  AssocCrit:      %s\n', char(ft));
            fprintf('  Point:          [%.4f  %.4f  %.4f]\n', pnt);
            fprintf('  Direction:      [%.4f  %.4f  %.4f]\n', dir);
            fprintf('  Included Angle: %.4f\n', rad2deg(ang*2));
            fprintf('  Distance:       %.4f\n', dist);
            fprintf('  Apex:           [%.4f %.4f %.4f]\n', apex);
            fprintf('  Small R:        %.4f\n', smallR);
            fprintf('  Big R:          %.4f\n', bigR);
            fprintf('  Height:         %.4f\n', height);
            fprintf('  Sigma:          %.4f\n', sig);
            fprintf('  Data Size:      [%s]\n', [num2str(dataSize(1)), ' x ', num2str(dataSize(2))]);
        end
    end

    methods (Static, Access = private)
        function r = opFun(q, xData, yData, zData)
            % q = [x, y, z, A, B, C, angle, s]
            qq = q;

            % Angle normalization
            if qq(7) > pi
                qq(7) = mod(qq(7), pi);
                qq(4:6) = -qq(4:6);
            elseif qq(7) > (pi/2)
                qq(7) = pi - qq(7);
            end

            % Distance normalization
            if qq(8) < 0
                qq(8) = -qq(8);
                qq(4:6) = -qq(4:6);
            end

            u     = @(p) p(6).*(yData - p(2)) - p(5).*(zData - p(3));
            v     = @(p) p(4).*(zData - p(3)) - p(6).*(xData - p(1));
            w     = @(p) p(5).*(xData - p(1)) - p(4).*(yData - p(2));
            aNorm = @(p) sqrt(p(4).^2 + p(5).^2 + p(6).^2);
            f     = @(p) sqrt((u(p).^2 + v(p).^2 + w(p).^2) ./ (aNorm(p).^2));
            g     = @(p) ( p(4).*(xData - p(1)) + p(5).*(yData - p(2)) + p(6).*(zData - p(3)) ) ./ aNorm(p);

            ang = mod(qq(7), 2*pi);
            r   = f(qq).*cos(ang) + g(qq).*sin(ang) - qq(8);
        end
    end
end
