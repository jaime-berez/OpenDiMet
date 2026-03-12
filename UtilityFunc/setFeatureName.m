function featureName = setFeatureName(customName, fileName)
    % SETFEATURENAME Determine the name of a feature from a custom name or file name.
    %
    %   Syntax
    %     featureName = setFeatureName(customName, fileName)
    %
    %   Description
    %     Determines the feature name to use based on user input. If a custom
    %     name is provided, it is used directly. Otherwise, the feature name is
    %     inferred from the base name of the input file.
    %
    %   Input Arguments
    %     customName
    %         1xN char
    %         User-defined feature name. If empty, the name will be derived
    %         from the input file name.
    %
    %     fileName
    %         1xN char
    %         File name or path used to infer the feature name when no custom
    %         name is provided.
    %
    %   Output Arguments
    %     featureName
    %         1xN char
    %         Name assigned to the feature.
    %
    %   Example
    %     name = setFeatureName('', 'circleData.csv');
    %     % Returns 'circleData'
    %
    %     name = setFeatureName('Hole1', 'circleData.csv');
    %     % Returns 'Hole1'
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
