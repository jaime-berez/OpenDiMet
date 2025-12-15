function feature = fitFeature(featureName, data, featureType, associationCriteria, varargin)
    % Function to fit feature to coordinate data
    arguments
        featureName (1,:) char {mustBeTextScalar, mustBeNonempty}
        data (:, 3) double {mustBeFinite, mustBeReal, mustBeNonempty, mustBeNonNan} 
        featureType (1,1)
        associationCriteria (1,1) AssociationCriteria
    end
    % Repeating arguments block for variable argument
    arguments (Repeating)
        varargin
    end

    % Fit the selected feature type
    switch featureType
        case "Line"
            feature = Line(featureName, data, associationCriteria, varargin{:});
        case "Plane"
            feature = Plane(featureName, data, associationCriteria, varargin{:});
        case "Circle"
            feature = Circle(featureName, data, associationCriteria, varargin{:});
        case "Sphere"
            feature = Sphere(featureName, data, associationCriteria, varargin{:});
        case "Cylinder"
            feature = Cylinder(featureName, data, associationCriteria, varargin{:});
        case "Cone"
            feature = Cone(featureName, data, associationCriteria, varargin{:});
        otherwise
            error(['Unsupported feature type: %s. featureType must be one of the following ' ...
                'Line, Cylinder, Plane, Circle, Sphere, Cone.'], featureType);
    end
end