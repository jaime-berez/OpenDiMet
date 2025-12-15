function featureName = setFeatureName(customName, fileName)
    arguments
        customName (1,:) char {mustBeTextScalar}
        fileName (1,:) char {mustBeTextScalar, mustBeNonempty}
    end
    
    if isempty(customName)
        [~, featureName, ~] = fileparts(fileName);
    else
        featureName = customName;
    end
end
