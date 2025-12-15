% Calculates the amplification factor for roundness error based on the MIC
% and MCC radi
function [ampFac] = cafrou(circError,Rmax,Rmin)
    arguments
        circError {mustBeScalarOrEmpty}
        Rmax {mustBeScalarOrEmpty}
        Rmin {mustBeScalarOrEmpty}
    end

    err2sz = circError/mean([Rmax Rmin]); %ratio of the roundness error to the approximate size of the feature
    
    %ampFac = 5+100^(err2sz); %amplification factor
    %ampFac = 1/err2sz*.025;
    ampFac = 0.05*(mean([Rmax Rmin])*2);

end
