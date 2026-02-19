function Jmat = jacobian_cd(fcn, paramVec)
%JACOBIAN_CD Computes Jacobian matrix using central differences.

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
