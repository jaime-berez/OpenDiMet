function sigma = calcSigmaFromResiduals(residuals, numParams)
%CALCSIGMAFROMRESIDUALS Function to calculate standard deviation or sigma
%from residuals.

    residuals = residuals(:);
    n = numel(residuals);
    p = numParams;

    if n>p
        sigma = sqrt(sum(residuals.^2) / (n-p));
    else
        sigma = NaN;
    end
end