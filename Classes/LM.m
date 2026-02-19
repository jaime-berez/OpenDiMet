classdef LM
    %LM Class for the Levenberg–Marquardt algorithm
    methods (Static)
        function [x,resnorm,residual,info] = solve(fcn,guess,maxIter,stepTol,gradTol,sseTol, ...
                lambda,dampingCoeff,suppressOutput)
            %   Levenberg-Marquardt Algorithm
            arguments
                fcn
                guess
                maxIter (1,1) double {mustBeFinite, mustBePositive}
                stepTol (1,1) double {mustBeFinite, mustBePositive}
                gradTol (1,1) double {mustBeFinite, mustBePositive}
                sseTol  (1,1) double {mustBeFinite, mustBePositive}
                lambda  (1,1) double {mustBeFinite, mustBePositive}
                dampingCoeff (1,1) double {mustBeFinite, mustBePositive}
                suppressOutput (1,1) logical
            end

            % Initial variables
            damp = dampingCoeff;
            x = guess;
            x = x(:);

            collectInfo = nargout > 3;  % only if user requests it
            if collectInfo
                info.history = zeros(maxIter,6);
            end

            for k = 1:maxIter
                r = fcn(x); % Residual @ k

                J = Jacobian(fcn,x); % Approximate Jacobian

                A = J.'*J; % Gauss-Newton approx Hessian
                g = J.'*r; % Gradient of the cost function

                % Solve damped normal equations: (A + lambda*I) * delta = -g
                delta = -(A + lambda * eye(length(A))) \ g;
                xNew = x + delta;
                rNew = fcn(xNew);

                % Gain ratio rho
                costCur = 0.5 * norm(r)^2;
                costNew = 0.5 * norm(rNew)^2;

                modelImprovement = 0.5 * delta.' * ((A + lambda * eye(length(A))) * delta);
                rho = (costCur - costNew) / modelImprovement;

                if collectInfo
                    info.history(k,:) = [k, costCur, norm(g), norm(delta), lambda, rho];
                end

                if ~suppressOutput
                    fprintf('Iter %3d | Cost %.3e | λ %.3e | ρ %.3e\n', k, costCur, lambda, rho);
                end

                % Accept/reject step
                if rho > 0
                    x = xNew;
                    lambda = lambda * max(1/3, 1-(2*rho-1)^3);
                    damp = dampingCoeff;
                else
                    lambda = lambda * damp;
                    damp = damp * 2;
                end

                % Convergence: gradient
                if norm(g) < gradTol*(1+norm(x))
                    if ~suppressOutput; fprintf('Converged: gradient below tolerance.\n'); end
                    break;
                end

                % Convergence: step size
                if norm(delta) < stepTol*(1+norm(x))
                    if ~suppressOutput; fprintf('Converged: step size below tolerance.\n'); end
                    break;
                end

                % Convergence: SSE change
                if abs(costCur - costNew) < sseTol * (1+abs(costCur))
                    if ~suppressOutput; fprintf('Converged: change in error below tolerance.\n'); end
                    break;
                end
            end

            if ~suppressOutput; fprintf('%-12s %-2d\n','Iterations:',k); end

            x = x(:).';              % force row vector
            resnorm  = sum(fcn(x).^2);
            residual = fcn(x);

            if collectInfo
                info.iter = k;
                info.final_cost = resnorm;
                info.history = info.history(1:k,:);
                info.labels = {'iter','cost','grad_norm','delta_norm','lambda','rho'};
            end
        end
    end
end
