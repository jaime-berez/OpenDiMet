classdef Plane < Feature
    % PLANE Class for fitting and representing a plane from coordinate data.
    % The Plane class constructs a plane feature from measured coordinate points
    % according to the specified AssociationCriteria. It inherits 
    % from Feature and stores both the original data and the associated
    % feature parameters.
    %
    % Properties:
    % point     : (1x3 double) point on the associated plane.
    % direction : (1x3 double) unit normal vector of the associated plane.
    % fitInfo   : (struct) struct describing how the plane was fit (e.g.,
    %             method name, optimization history).
    %
    % Methods:
    % Plane(name, data, AssociationCriteria) : Construct and fit the plane from data.
    % plot()                                 : Plot the coordinate data and the associated plane.
    % disp()                                 : Formatted display of the
    %                                          associated plane properties.
    % showFitInfo()                          : Display stored association
    %                                          metadata.
    % reverseDir()                           : Reverse the direction of the
    %                                          associated plane.

    properties (GetAccess = public, SetAccess = private)
        point (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        direction (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        fitInfo struct = struct()
    end

    methods
        function obj = Plane(name, data, associationCriteria, opts)
            % Plane Constructor
            % obj = Plane(name, data, associationCriteria, opts)
            % Construct a plane object and compute the associated plane
            % from the supplied coordinate data.
            % Inputs:
            % name                  : (1x1 string) User-defined feature name. If empty, 
            %                         the Feature base class will infer a
            %                         name from the source file or assign "UnnamedFeature".
            % data                  : (Nx3 double) 3D coordinate points
            %                         defining the feature.
            % associationCriteria   : AssociationCriteria enumeration
            %                         specifies the association rule or method. only applicable
            %                         criteria are permitted based on the list in
            %                         validateAssociation in Feature class.
            arguments
                name (1,1) string {mustBeTextScalar}
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                associationCriteria (1,1) AssociationCriteria
                % Dummy LM-style options
                opts.MaxIter       (1,1) double {mustBeFinite, mustBePositive} = 5000
                opts.StepTol       (1,1) double {mustBeFinite, mustBePositive} = 1e-9
                opts.GradTol       (1,1) double {mustBeFinite, mustBePositive} = 1e-11
                opts.SSETol        (1,1) double {mustBeFinite, mustBePositive} = 1e-19
                opts.Lambda        (1,1) double {mustBeFinite, mustBePositive} = 1e-4
                opts.DampingCoeff  (1,1) double {mustBeFinite, mustBePositive} = 2
                opts.SuppressOutput(1,1) logical = true
                opts.sourceFile (1,1) string = ""
            end
            obj@Feature(name, data, associationCriteria, opts.sourceFile);
            obj.validateAssociation();
            % Computes and plots the centroid of the plane
            dataOrig = data;
            centroid = mean(dataOrig,1);
            X=dataOrig-centroid;
            % Performs SVD on the data using the built-in svd command
            % [~,Lam,V] = svd(X,0);
            % [~,lamIndex] = min(diag(Lam));
            % 
            % % Choose the eigenvector corresponding to the smallest eigenvalue
            % direction = V(:,lamIndex)';
            % direction = direction/norm(direction);

            A = X.' * X;                   
            [eigVec, eigValMat] = eig(A);  

            eigVals = diag(eigValMat);     
            [~, idx] = min(eigVals);       % smallest eigenvalue

            direction = eigVec(:, idx).';  % 1x3 normal
            direction = direction / norm(direction);
            residuals = X * direction.';   % Signed distance to the plane
            obj.sigma = std(residuals);
            obj.point = centroid;
            obj.direction = direction;
            obj.fitInfo = struct('method', 'SVD', 'description', ['Least-squares plane fit using ' ...
            'Singular Value Decomposition.']);
        end

        function h = plot(obj, opts)
            % PLOT Plot plane coordinate data and fitted plane.
            %
            % h = obj.plot() uses defaults.
            % h = obj.plot(Name = Value, ...) customizes appearance.
            %
            % Options (Name = Value)
            % dataColor         : color name/'r'/RGB/[hex] (default: Matlab blue)
            % dataMarker        : marker char (default: '.')
            % dataMarkerSize    : scalar (default: 10)
            % dataLabel         : string (default: "<name> Data")
            % fitColor          : color name/'r'/RGB/[hex] (default: green)
            % fitLabel          : string (default: "<name> Fit")
            % fitFaceAlpha      : scalar in [0,1] (default: 0.4)
            % fitEdgeColor      : "none" or color (default: "k")
            % ax                : axes handle (default: gca)
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
            point = obj.point;
            direction = obj.direction;

            cla(ax); hold(ax,'on'); grid(ax,'on');
            axis(ax,'equal'); axis(ax,'padded'); view(ax,3);
            xlabel(ax,'x'); ylabel(ax,'y'); zlabel(ax,'z');
            title(ax, opts.fitLabel);

            % Plot coordinate data
            plot3(ax, data(:,1), data(:,2), data(:,3), char(opts.dataMarker), ...
                'Color', dataColor, 'MarkerSize', opts.dataMarkerSize, 'DisplayName', opts.dataLabel)
            % hold(ax,'on'); grid(ax,'on'); axis(ax,'equal'); axis(ax, 'padded'); view(ax, 3);
            
            % Plot centroid
            plot3(ax, point(1), point(2), point(3), 'xk', ...
                'HandleVisibility', 'off');
            
            [X,Y,Z] = calcPlaneCorners(data, point, direction); %calculate the corners of the plane for plotting
            % Plot.plotPlane(X,Y,Z, fitColor, 0.4, "N", fitColor, fitLabel); %plot the associated plane
            % hold on;

            h = fill3(ax, X, Y, Z, fitColor, ...
                'EdgeColor', edgeColor, ...
                'FaceAlpha', opts.fitFaceAlpha, ...
                'DisplayName', opts.fitLabel);
                
            % Plot a plane using fill3()
            % if showEdge == "N"||"n"
            %     h = fill3(X,Y,Z,fitColor,'EdgeColor','k', 'FaceAlpha', 0.4,'DisplayName',fitLabel);
            % elseif showEdge == "Y"||"y"
            %     h = fill3(X,Y,Z,fitColor,'EdgeColor',fitColor, 'FaceAlpha',0.4, ...
            %         'DisplayName', fitLabel);
            % else
            %     error("showEdge must be Y or N.");
            % end  
            % title(ax, fitLabel);
            % xlabel("x"); ylabel("y"); zlabel("z");

            legend(ax, "show", 'FontSize',12);
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
            % Extract base info
            name = string(obj.name);
            assoc = obj.AssociationCriteria;
            data = obj.data;
            point = obj.point(:).';
            direction = obj.direction(:).';
            sigma = obj.sigma;
            dataClass = class(data);
            dataSize = size(data);

            % Print formatted output
            fprintf('%s Object\n', class(obj));
            fprintf('  Name:      %s\n', name);
            fprintf('  AssocCrit: %s\n', char(assoc));
            fprintf('  Point:     [%.4f  %.4f  %.4f]\n', point);
            fprintf('  Direction: [%.4f  %.4f  %.4f]\n', direction);
            fprintf('  Sigma:     %.4f\n', sigma);
            fprintf('  Data Size: [%s]\n', [num2str(dataSize(1)), ' x ', num2str(dataSize(2))]);
        end

        function reverseDir(obj)
            % REVERSEDIR Function to reverse the direction vector of the
            % object.

            obj.direction = -obj.direction;
        end
    end
end