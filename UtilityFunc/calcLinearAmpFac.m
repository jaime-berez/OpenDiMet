% Calculates the amplification factor using the length of a line
function ampFac = calcLinearAmpFac(strErr, len, scaleFac)
    arguments
        strErr (1,1) {mustBeNonempty}
        len    (1,1) {mustBeNonzero}
        scaleFac {mustBeScalarOrEmpty} = 5
    end

    ampFac = scaleFac * (1 + (len/strErr)^-1);
end
