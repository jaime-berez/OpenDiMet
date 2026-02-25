% Calculates the amplification factor for roundness error based on the MIC
% and MCC radi
function ampFac = calcRadialAmpFac(rndErr, rMax, rMin)
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
