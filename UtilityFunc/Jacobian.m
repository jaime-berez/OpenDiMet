function Jmat = jacobian_cd(fcn, paramVec)
    % JACOBIAN_CD Compute the Jacobian matrix of a function using central differences.
    %
    %   Syntax
    %     Jmat = jacobian_cd(fcn, paramVec)
    %
    %   Input Arguments
    %     fcn - Function handle returning residual values
    %       function handle
    %     paramVec - Parameter vector at which the Jacobian is evaluated
    %       Nx1 or 1xN double vector
    %
    %   Output Arguments
    %     Jmat - Jacobian matrix of partial derivatives
    %       (M*K) x N double matrix
    %
    %   Example
    %     J = jacobian_cd(fcn, paramVec);

    nParams = numel(paramVec);

    f0 = fcn(paramVec);          % MxK output
    [nRows, nCols] = size(f0);

    Jmat = zeros(nRows*nCols, nParams);

    for idx = 1:nParams

        epsVal = 1e-6 * (1 + abs(paramVec(idx)));

        dParam = zeros(size(paramVec));
        dParam(idx) = epsVal;

        fPlus  = fcn(paramVec + dParam);
        fMinus = fcn(paramVec - dParam);

        % Central difference approximation
        diffVal = (fPlus - fMinus) / (2 * epsVal);

        Jmat(:, idx) = diffVal(:);
    end
end
