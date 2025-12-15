classdef Line < Feature
    % LINE Class for fitting and representing a straight line form data.
    % The Line class constructs a line feature from measured 3D points
    % using a fit-based constructor using the specified AssociationCriteria. It inherits 
    % from Feature and stores both geometric description and the fitting parameters 
    % used to obtain it.
    % 
    % Properties:
    % point 1 x 3 double, point on the fitted line (centroid)
    % direction - 1 x 3 double, unit vector describing the line's
    % orientation
    %
    % Methods:
    % Line(name, data, AssociationCriteria) - construct and fit the line.
    % plot() - visualize the data and the fitted line.
    % disp() - formatted textual description.

    properties (GetAccess = public, SetAccess = private)
        point (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        direction (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        fitInfo struct = struct()
    end

    methods
        function obj = Line(name, data, associationCriteria, opts)
            % Constructor function for the Line Class
            arguments
                name (1,1) string {mustBeTextScalar, mustBeNonempty}
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
            end
            obj@Feature(name, data, associationCriteria);
            obj.validateAssociation();

            point = mean(data);
            data1 = data-point;

            % [U, Lam, V] = svd(data1);
            % 
            % [largestLam, index] = max(diag(Lam));
            % direction = V(:, index)';

            A = data1' * data1;              
            [eigVec, eigValMat] = eig(A);    

            eigVals = diag(eigValMat);       
            [~, idx] = max(eigVals);         % largest variance direction

            direction = eigVec(:, idx).';   
            direction = direction / norm(direction);  

            residuals = calcStraightnessResiduals(data, point, direction);
            numParams = 4;
            obj.sigma = Feature.computeSigmaFromResiduals(residuals, numParams);

            obj.point = point;
            obj.direction = direction; % Store the direction vector in the object
            obj.fitInfo = struct('method', 'SVD', 'description', ['Least-squares line fit using ' ...
            'Singular Value Decomposition.']);
        end

        function h = plot(obj, dataColor, dataLabel, fitColor, fitLabel, ax, linestyle)
            % Function to plot the fitted line
            arguments
                obj               
                dataColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(dataColor,0),...
                    mustBeLessThanOrEqual(dataColor,1)} = [0 0.4470 0.7410]
                dataLabel (1,:) char = obj.name + ' Data'
                fitColor (1,3) double {mustBeFinite, mustBeReal, mustBeGreaterThanOrEqual(fitColor,0),...
                    mustBeLessThanOrEqual(fitColor,1)} = [0 1 0]
                fitLabel (1,:) char = obj.name + ' Fit'
                ax = []
                linestyle = 'g-.'
            end
                
            data = obj.data;
            point = obj.point;
            direction = obj.direction;
            Plot.plotData(data); %plot the data points 
            hold on; grid on; axis equal; axis padded; %configure the figure
            Plot.plotPoint(point); %plot the centroid
            h = Plot.plotLine(data, point, direction, dataColor, dataLabel, fitColor, fitLabel, ax, linestyle);
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
            % Custom display for Line objects
            % Extract base info
            name = string(obj.name);
            associationCriteria = obj.AssociationCriteria;
            data = obj.data;
            point = obj.point;
            direction = obj.direction;
            sigma = obj.sigma;

            % Print formatted output
            fprintf('%s Object\n', class(obj));
            fprintf('  Name:            %s\n', name);
            fprintf('  AssociationCriteria: %s\n', char(associationCriteria));
            fprintf('  Point:           [%.4f  %.4f  %.4f]\n', point);
            fprintf('  Direction:       [%.4f  %.4f  %.4f]\n', direction);
            fprintf('  Sigma:           %.4f\n', sigma);
        end
    end
end
