classdef Plane < Feature
    % PLANE Class for fitting and representing a plane from data.
    % The Plane class constructs a plane feature from measured coordinate points
    % according to the specified AssociationCriteria. It inherits 
    % from Feature and stores both the original data and the associated
    % feature parameters.
    %
    % Properties:
    % point - 1 x 3 double, point on the associated plane.
    % direction - 1 x 3 double, unit normal vector of the associated plane.
    %
    % Methods:
    % Plane(name, data, AssociationCriteria) - construct and fit the plane.
    % plot() - visualize the data and the fitted plane.
    % disp() - formatted textual description.

    properties (GetAccess = public, SetAccess = private)
        point (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        direction (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        fitInfo struct = struct()
    end
    methods
        % Constructor method for the Plane class
        function obj = Plane(name, data, associationCriteria)
            arguments
                name (1,1) string {mustBeTextScalar, mustBeNonempty}
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                associationCriteria (1,1) AssociationCriteria
            end
            obj@Feature(name, data, associationCriteria);
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
            obj.point = centroid;
            obj.direction = direction;
            obj.fitInfo = struct('method', 'SVD', 'description', ['Least-squares plane fit using ' ...
            'Singular Value Decomposition.']);
        end

        function h = plot(obj, dataColor, dataLabel, fitColor, fitLabel, ax)
            % Function to plot the fitted plane
            arguments
                obj
                dataColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(dataColor,0),...
                    mustBeLessThanOrEqual(dataColor,1)} = [0 0.4470 0.7410]
                dataLabel (1,:) char = 'Data Points'
                fitColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(fitColor,0),...
                    mustBeLessThanOrEqual(fitColor,1)} = [0 1 0]
                fitLabel (1,:) char = 'Fitted Plane'  
                ax = []
            end
            data = obj.data;
            point = obj.point;
            direction = obj.direction;
            
            if isempty(ax) || ~isvalid(ax)
                ax =gca;
            end

            % Plot raw data
            plot3(ax, data(:,1), data(:,2), data(:,3), '.', ...
                'Color', dataColor, 'DisplayName', dataLabel)
            hold(ax,'on'); grid(ax,'on'); axis(ax,'equal'); axis(ax,'padded');
            
            % Plot the centroid
            plot3(ax, point(1), point(2), point(3), 'xk', ...
                'HandleVisibility', 'off');
            
            [X,Y,Z] = calcPlaneCorners(data, point, direction); %calculate the corners of the plane for plotting
            Plot.plotPlane(X,Y,Z, fitColor, 0.4, "N", fitColor); %plot the associated plane
            title(ax, fitLabel);
            xlabel("x"); ylabel("y"); zlabel("z");

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

            % Print formatted output
            fprintf('%s Object\n', class(obj));
            fprintf('  Name:            %s\n', name);
            fprintf('  AssociationCriteria: %s\n', char(assoc));
            fprintf('  Point:           [%.4f  %.4f  %.4f]\n', point);
            fprintf('  Direction:       [%.4f  %.4f  %.4f]\n', direction);
        end
    end
end