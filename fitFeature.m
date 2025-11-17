function feature = fitFeature(featureName, data, featureType, associationCriteria)
    % Function to fit feature to coordinate data
    arguments
        featureName (1,:) char {mustBeTextScalar, mustBeNonempty}
        data (:, 3) double {mustBeFinite, mustBeReal, mustBeNonempty, mustBeNonNan} 
        featureType (1,1)
        associationCriteria (1,1) AssociationCriteria
    end

    % Fit the selected feature type
    switch featureType
        case "Line"
            feature = Line(featureName, data, associationCriteria);
        case "Plane"
            feature = Plane(featureName, data, associationCriteria);
        case "Circle"
            feature = Circle(featureName, data, associationCriteria);
        case "Sphere"
            feature = Sphere(featureName, data, associationCriteria);
        case "Cylinder"
            feature = Cylinder(featureName, data, associationCriteria);
        case "Cone"
            feature = Cone(featureName, data, associationCriteria);
        otherwise
            error(['Unsupported feature type: %s. featureType must be one of the following ' ...
                'Line, Cylinder, Plane, Circle, Sphere, Cone.'], featureType);
    end
end