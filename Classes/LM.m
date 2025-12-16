classdef LM
    %LM Class for the Levenberg–Marquardt algorithm
    methods (Static)
        function [x,resnorm, residual, info] = solve(fcn,guess,MaxIter,StepTol,GradTol,SSETol, ...
                Lambda, DampingCoeff, suppressOutput)
            %   Levenberg-Marquardt Algorithm
            %
            %   func:       objective function to optimize (data is passed in through
            %   the func)
            %   guess:      matrix of the guess of parameters
            %   maxIter:    Maximum number of iterations
            %   tol:        Default value for the tolerances (step tolerance)
            %   grad-tol:   Optional tolerance value for the gradient tolerance
            %   SSE_tol:    Optional tolerance value for the sum squared error
            %   tolerance
            %
            %   results:    Output matrix with the optimized parameters
            arguments
                fcn 
                guess 
                MaxIter (1,1) double {mustBeFinite, mustBePositive}
                StepTol (1,1) double {mustBeFinite, mustBePositive}
                GradTol (1,1) double {mustBeFinite, mustBePositive}
                SSETol (1,1) double {mustBeFinite, mustBePositive}
                Lambda (1,1) double {mustBeFinite, mustBePositive}
                DampingCoeff (1,1) double {mustBeFinite, mustBePositive}
                suppressOutput (1,1) logical 
            end
                
            % Initial variables
            %lambda = 1e-4;  %Levenberg-marquardt Parameter
            %dampIni = 0.2;       %Damping adjustment factor 
            damp = DampingCoeff;
            x = guess; %set the parameters for the first iteration to be the guessed parameters    
            x = x(:);
            % doTileLayout = 0; %variable to enable/disable tile layout of parameters
            % 
            % if doTileLayout ==1
            %     trackLambda = zeros(1,2);
            %     trackSSE = zeros(1,2);
            %     trackRho = zeros(1,2);
            %     trackDelta = zeros(1,2);
            % end

            collectInfo = nargout > 3;  % only if user requests it
            if collectInfo
                info.history = zeros(MaxIter,6);
            end
        
            
            for k=1:MaxIter
                r = fcn(x); % Residual of the coordinate @ k
                %if suppressOutput==false; fprintf('Iteration: %-3i\n',k); end
        
                
                J = Jacobian(fcn,x); % Approximate Jacobian
                %J = sphereJacob(data,x);
                
                A = J'*J; % Gauss-Newton approx to Hessian matrix
                g = J'*r; % Gradient of the cost function
        
                %Solve the damped normal equations: (A +lambda*I) * delta = -g
                %This is equal to (J'T+lambda*I)*delta = -(J'*r)
                delta = -(A + Lambda * eye(length(A))) \ g; %note the left-hand division
                x_new = x + delta;  % Trial update to the parameters
                r_new = fcn(x_new); % Residual with the new parameters
        
                % Calculate the gain ratio (rho) to assess step quality
                cost_current = 0.5 * norm(r)^2;
                cost_new = 0.5 * norm(r_new)^2;
                %model_improvement = delta' * (lambda * delta - g);
                %model_improvement = 0.5 * delta' * (A * delta + lambda * delta);
                %model_improvement = 0.5 * delta' *(lambda * delta + g);
                %model_improvement = 0.5 * delta' *(lambda*delta/2-g);
                model_improvement = 0.5 * delta' * ((A + Lambda * eye(length(A))) * delta);
                rho = (cost_current - cost_new)/model_improvement;
                
                % Debugging printouts
                % fprintf('\n--- Iteration %d ---\n', k);
                % fprintf('  Cost (current): %.6e\n', cost_current);
                % fprintf('  Cost (new):     %.6e\n', cost_new);
                % fprintf('  Model improvement: %.6e\n', model_improvement);
                % fprintf('  rho:            %.6e\n', rho);
                % fprintf('  Norm(delta):    %.6e\n', norm(delta));
                % fprintf('  Norm(g):        %.6e\n', norm(g));
                % fprintf('  lambda:         %.6e\n', lambda);

                if collectInfo
                    info.history(k,:) = [k, cost_current, norm(g), norm(delta), Lambda, rho];
                end

                if ~suppressOutput
                    fprintf('Iter %3d | Cost %.3e | λ %.3e | ρ %.3e\n', k, cost_current, Lambda, rho);
                end
        
                %If the step was successful, accept it and decrease lambda
                if rho > 0
                    x = x_new; %replace the old parameters with the new optimized parameters
                    %lambda  = lambda * max(1/3, 1-rho); %decrease lambda
                    Lambda = Lambda*max(1/3,1-(2*rho-1)^3);
                    damp = DampingCoeff; % set the damping factor back to initial value
                else
                    %If the step was not successful, increase lambda and reject the
                    %update
                    Lambda = Lambda*damp; % multiply lamba by the damping factor
                    damp=damp*2; % increase the damping factor
                end
        
                % Check for convergence based on gradient
                if norm(g) < GradTol*(1+norm(x)) %check if the magnitude of g is less than the tolerance value
                    if suppressOutput==false; fprintf('Converged: gradient below tolerance. \n'); end
                    break;
                end
        
                %Check if the step size is too small
                if norm(delta)<StepTol*(1+norm(x))
                    if suppressOutput==false; fprintf('Converged: step size below tolerance. \n'); end
                    break;
                end
        
                %check if the sum squared error is suffiently small
                if abs(cost_current-cost_new) < SSETol * (1+abs(cost_current))
                    if suppressOutput==false; fprintf('Converged: Change in error less than the tolerance \n'); end
                    break;
                end
                
                % if doTileLayout ==1
                %     %record the variables that change
                %     trackLambda(k,1:2) = [k,lambda];
                %     trackSSE(k,1:2) = [k,cost_current];
                %     trackRho(k,1:2) = [k,rho];
                %     trackDelta(k,1:2) = [k,norm(delta)];
                % end
                % %fprintf('Condition number of A: %e\n', cond(A));
        
            end
            if suppressOutput==false; fprintf('%-12s %-2d\n','Iterations:',k); end
            
            % if doTileLayout==1
            %     tiledlayout(4,1);
            %     nexttile;
            %     plot(trackLambda(:,1),trackLambda(:,2),'r-');
            %     xlabel('Iteration'); ylabel('lambda'); title('Lambda');
            %     set(gca, 'YScale', 'log');
            %     nexttile;
            %     plot(trackSSE(:,1),trackSSE(:,2),'b-');
            %     xlabel('iteration'); ylabel('Sum Squared Error'); title('Sum Squared Error');
            %     set(gca, 'YScale', 'log');
            %     nexttile
            %     plot(trackRho(:,1),trackRho(:,2),'g-');
            %     xlabel('iteration'); ylabel('rho'); title('rho');
            %     set(gca, 'YScale', 'log');
            %     nexttile
            %     plot(trackDelta(:,1),trackDelta(:,2),'-');
            %     xlabel('iteration'); ylabel('delta'); title('delta');
            %     set(gca, 'YScale', 'log');
            % end
            %resnorm = norm(func(x))^2;
            x = x(:)'; %forces the initial guess to be a row vector
            resnorm = sum(fcn(x).^2); %same equation that MATLAB uses for lsqnonlin
            residual = fcn(x); %same as lsqnonlin

            if collectInfo
                info.iter = k;
                info.final_cost = resnorm;
                info.history = info.history(1:k,:); 
                info.labels = {'iter','cost','grad_norm','delta_norm','lambda','rho'};
            end
        end
    end
end
