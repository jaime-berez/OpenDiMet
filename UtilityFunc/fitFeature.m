function feature = fitFeature(data, featureType, associationCriteria, featureName, opts)
    % Function to fit feature to coordinate data
    arguments
        data (:, 3) double {mustBeFinite, mustBeReal, mustBeNonempty, mustBeNonNan} 
        featureType (1,1)
        associationCriteria (1,1) AssociationCriteria
        featureName (1,1) string = ""
        opts.MaxIter       (1,1) double {mustBeFinite, mustBePositive} = 5000
        opts.StepTol       (1,1) double {mustBeFinite, mustBePositive} = 1e-9
        opts.GradTol       (1,1) double {mustBeFinite, mustBePositive} = 1e-11
        opts.SSETol        (1,1) double {mustBeFinite, mustBePositive} = 1e-19
        opts.Lambda        (1,1) double {mustBeFinite, mustBePositive} = 1e-4
        opts.DampingCoeff  (1,1) double {mustBeFinite, mustBePositive} = 2
        opts.SuppressOutput(1,1) logical = true
    end

    if strlength(featureName) == 0
        try
            % Try to find the file variable in caller workspace and infer
            % the name.
            fileVar = evalin('caller', 'file');
            % Ignore the folder name and keep the base file name.
            [~, inferredName] = fileparts(fileVar);
            featureName = string(inferredName);
        catch
            featureName = "UnnamedFeature";
        end
    end

    % Convert opts to 'Name', Value list to forward to constructors
    nameValue = namedargs2cell(opts);

    % Fit the selected feature type
    switch featureType
        case "Line"
            feature = Line(featureName, data, associationCriteria, nameValue{:});
        case "Plane"
            feature = Plane(featureName, data, associationCriteria, nameValue{:});
        case "Circle"
            feature = Circle(featureName, data, associationCriteria, nameValue{:});
        case "Sphere"
            feature = Sphere(featureName, data, associationCriteria, nameValue{:});
        case "Cylinder"
            feature = Cylinder(featureName, data, associationCriteria, nameValue{:});
        case "Cone"
            feature = Cone(featureName, data, associationCriteria, nameValue{:});
        otherwise
            error(['Unsupported feature type: %s. featureType must be one of the following ' ...
                'Line, Cylinder, Plane, Circle, Sphere, Cone.'], featureType);
    end
end