function J = jacobian_cd(func, x)
% Computes Jacobian matrix using central differences.
%
% Inputs:
%   modelFunc   - Function handle: modelFunc(params, xData)
%   xData       - MxN matrix of inputs
%   params      - 1xP row vector of parameters
%
% Output:
%   J           - [M*K x P] Jacobian matrix (flattened output rows)
    
    numParams = numel(x);
    y0 = func(x);  % MxK
    [M, K] = size(y0);
    J = zeros(M*K, numParams);
    % Debugging code: col_norms shouldn't be very small
    %col_norms = vecnorm(J);
    %disp('Jacobian column norms:');
    %disp(col_norms);
    
    for p = 1:numParams
        epsilon = 1e-6*(1+abs(x(p)));
        %dp = zeros(numParams,1);
        dp = zeros(size(x));
        dp(p) = epsilon;

        yPlus  = func(x + dp);
        yMinus = func(x - dp);

        % Central difference
        diff = (yPlus - yMinus) / (2 * epsilon);  % MxK
        J(:, p) = diff(:);
    end  
    % Degubbing code: condJ shouldn't be very large
    %condJ = cond(J);  % or cond(J'*J)
    %fprintf('Jacobian condition number: %.2e\n', condJ);
end