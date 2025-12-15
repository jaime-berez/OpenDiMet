% Calculates the amplification factor using the length of a line
function [ampFac] = cafStr(straightness,lineLength,scalingFactor)
    arguments
        straightness (1,1) {mustBeNonempty}
        lineLength (1,1) {mustBeNonzero}
        scalingFactor {mustBeScalarOrEmpty} = 5
    end

    ampFac = scalingFactor * (1+(lineLength/straightness)^-1);
end