function ampFac = calcRadialAmpFac(rndErr, rMax, rMin)
    % CALCRADIALAMPFAC Compute amplification factor for radial form deviations.
    %
    %   Syntax
    %     ampFac = calcRadialAmpFac(rndErr, rMax, rMin)
    %
    %   Input Arguments
    %     rndErr - Roundness error magnitude
    %       scalar double
    %     rMax - Maximum radial distance (e.g., MCC radius)
    %       scalar double
    %     rMin - Minimum radial distance (e.g., MIC radius)
    %       scalar double
    %
    %   Output Arguments
    %     ampFac - Amplification factor used to exaggerate radial deviations
    %       scalar double
    %
    %   Example
    %     ampFac = calcRadialAmpFac(rndErr, rMax, rMin);
    arguments
        rndErr {mustBeScalarOrEmpty}
        rMax   {mustBeScalarOrEmpty}
        rMin   {mustBeScalarOrEmpty}
    end

    errRatio = rndErr / mean([rMax rMin]);  % ratio of roundness error to approximate size

    %ampFac = 5 + 100^(errRatio);
    %ampFac = 1/errRatio * .025;
    ampFac = 0.05 * (mean([rMax rMin]) * 2);
end
