function ampFac = calcLinearAmpFac(strErr, len, scaleFac)
    % CALCLINEARAMPFAC Compute amplification factor for linear form deviations.
    %
    %   Syntax
    %     ampFac = calcLinearAmpFac(strErr, len)
    %     ampFac = calcLinearAmpFac(strErr, len, scaleFac)
    %
    %   Input Arguments
    %     strErr - Straightness error magnitude
    %       scalar double
    %     len - Length of the associated linear feature
    %       nonzero scalar double
    %     scaleFac - User-defined scaling factor controlling amplification
    %       scalar double
    %
    %   Output Arguments
    %     ampFac - Amplification factor used to exaggerate linear deviations
    %       scalar double
    %
    %   Example
    %     ampFac = calcLinearAmpFac(strErr, len);
    %     ampFac = calcLinearAmpFac(strErr, len, 10);
    arguments
        strErr (1,1) {mustBeNonempty}
        len    (1,1) {mustBeNonzero}
        scaleFac {mustBeScalarOrEmpty} = 5
    end

    ampFac = scaleFac * (1 + (len/strErr)^-1);
end
