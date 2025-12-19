classdef Sphere < Feature
    % SPHERE Class for fitting and representing a sphere form data.
    % The Sphere class constructs a sphere feature from measured 3D points
    % using a fit-based constructor using the specified AssociationCriteria. It inherits 
    % from Feature and stores both geometric description and the fitting parameters 
    % used to obtain it.
    %
    % Properties:
    % point - 1 x 3 double, fitted sphere center
    % diamater - 1 x 1 double, fitted sphere diameter
    %
    % Methods:
    % Sphere(name, data, AssociationCriteria): construct and fit the sphere.
    % plot(): visualize the data and the fitted sphere.
    % disp(): formatted textual description.

    properties (GetAccess = public, SetAccess = private)
        point (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        diameter (1,1) double {mustBeFinite, mustBeReal}
        fitInfo struct = struct()
    end

    methods
        % Constructor for the sphere class
        function obj = Sphere(name, data, associationCriteria, opts)
            arguments
                name (1,1) string {mustBeTextScalar, mustBeNonempty}
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                associationCriteria (1,1) AssociationCriteria

                % Name-value options for LM
                opts.MaxIter (1,1) double {mustBeFinite, mustBePositive} = 5000
                opts.StepTol (1,1) double {mustBeFinite, mustBePositive} = 1e-12
                opts.GradTol (1,1) double {mustBeFinite, mustBePositive} = 1e-12
                opts.SSETol (1,1) double {mustBeFinite, mustBePositive} = 1e-16
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

            centroid = mean(data);
            % Break up data into x,y,z components
            [xD, yD, zD] = separateData(data);

            % Initial guess data
            point = centroid;

            % Use the Instersecting Cords Theorem to guess Sphere's radius
            radius = guess3dRad(data);

            % Format the guess
            guess = [point(1),point(2),point(3),radius];
            
            % Format the objective function
            %fcn = @(q) abs(q(1)-data)-q(2);
            %fcn = @(q) ((abs(q(1)-xD))+(abs(q(2)-yD))+(abs(q(3)-zD))-q(4));
            x = @(q) q(1)-xD;
            y = @(q) q(2)-yD;
            z = @(q) q(3)-zD;
            fcn = @(q) sqrt(x(q).^2+y(q).^2+z(q).^2)-q(4);
            
             % Associate a sphere
            [answer, resnorm, residual, info] = LM.solve(fcn,guess, MaxIter, StepTol, GradTol, ...
                SSETol, Lambda, DampingCoeff, SuppressOutput);
        
            point = [answer(1),answer(2),answer(3)];
            diameter =answer(4)*2;
            obj.sigma = std(residual);
            obj.point = point;
            obj.diameter = diameter;

            if exist('info', 'var')
                obj.fitInfo = info;
            end
        end
    end

    methods
        function h = plot(obj, dataColor, dataLabel, fitColor, fitLabel, faces, ax)
            % Function to plot the fitted sphere
            arguments
                obj
                dataColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(dataColor,0),...
                    mustBeLessThanOrEqual(dataColor,1)} = [0 0.4470 0.7410]
                dataLabel (1,:) char = obj.name + ' Data'
                fitColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(fitColor,0),...
                    mustBeLessThanOrEqual(fitColor,1)} = [0 1 0]
                fitLabel (1,:) char = obj.name + ' Fit'  
                faces (1,1) double = 27
                ax = []
            end
            data = obj.data;
            point = obj.point;
            diameter = obj.diameter;

            %Plot.plotData(data);
            %hold on; grid on; axis equal; axis padded; %configure the figure
            %Plot.plotPoint(point);
            %h = Plot.plotSphere(data, point, diameter, dataColor, dataLabel, fitColor, fitLabel, faces, ax);
            %title("Coordinate data and associated sphereical surface");
            %xlabel("x");    ylabel("y");    zlabel("z");
            if isempty(ax) || ~isvalid(ax)
                ax = gca;
            end
            
            cla(ax); hold(ax, 'on'); axis(ax,'equal'); grid(ax,'on'); view(ax,3);
            xlabel(ax,'x'); ylabel(ax,'y'); zlabel(ax,'z');
            title(ax, sprintf('%s', fitLabel));

            plot3(ax, data(:,1),data(:,2),data(:,3),'.', ...
                 'Color',dataColor, 'DisplayName',dataLabel);

            plot3(ax, point(1), point(2), point(3), 'xk', 'HandleVisibility', 'off');
        
            % Plot a sphere
            [X,Y,Z] = sphere(faces);
            X=X*diameter/2+point(1);
            Y=Y*diameter/2+point(2);
            Z=Z*diameter/2+point(3);
            h = surf(ax, X,Y,Z,'FaceColor',fitColor,'FaceAlpha',0.35,'EdgeColor',...
                'none','EdgeAlpha',0.35, 'DisplayName',fitLabel); %plot the fitted sphere  
            legend(ax, "show", 'FontSize',12);
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
            % Extract base info
            name = string(obj.name);
            associationCriteria = obj.AssociationCriteria;
            data = obj.data;
            point = obj.point(:).';
            diameter = obj.diameter;
            sigma = obj.sigma;
            dataClass = class(data);
            dataSize = size(data);

            % Print formatted output
            fprintf('%s Object\n', class(obj));
            fprintf('  Name:      %s\n', name);
            fprintf('  AssocCrit: %s\n', char(associationCriteria));
            fprintf('  Point:     [%.4f  %.4f  %.4f]\n', point);
            fprintf('  Diameter:  %.4f\n', diameter);
            fprintf('  Sigma:     %.4f\n', sigma);
            fprintf('  Data Size: [%s]\n', [num2str(dataSize(1)), ' x ', num2str(dataSize(2))]);
        end
    end
end

    