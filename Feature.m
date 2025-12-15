classdef Feature
    % FEATURE Base class for geometric features.
    % The Feature class provides a foundation for the geometric feature
    % types. Each feature stores a descriptive name, an association type
    % and the raw coordinate data used for the fitting process.
    %
    % Properties:
    % name - 1 x 1 string, user-defined name of the feature
    % AssociationCriteria - 1 x 1 AssociationCriteria enumeration, fitting method
    % used
    % data - N x 3 double, coordinate points defining the feature

    properties (GetAccess = public, SetAccess = public)
        name (1,1) string {mustBeTextScalar, mustBeNonempty} = ""
        AssociationCriteria (1,1) AssociationCriteria = AssociationCriteria.LeastSquares 
        sigma (1,1) double {mustBeFinite, mustBeReal, mustBeNonnegative}
    end

    properties (GetAccess = public, SetAccess = private)
        data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan}
    end

    methods
        function obj = Feature(name, data, associationCriteria)
            arguments
                name (1,1) string {mustBeTextScalar, mustBeNonempty}
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                associationCriteria (1,1) AssociationCriteria
            end
            obj.name = name;
            obj.AssociationCriteria = associationCriteria;
            obj.data = data;
        end
    end

    methods (Access = protected)
        function validateAssociation(feature)
            % Function to validate the AssociationCriteria.
            geometry = class(feature);
            criteria = feature.AssociationCriteria;

            % List of the supported geometries.
            supported_geometries = criteria.supportedGeometries();
            % Check if the selected geometry is supported.
            if ~ismember(lower(geometry), lower(supported_geometries))
                err = MException("Feature:UnsupportedFit", ...
                    "%s does not support %s association criterion.\nProcess terminated.", geometry, char(criteria));
                throwAsCaller(err);
            end

            % Check if the selected association criterion is implemented.
            if any(criteria == AssociationCriteria.unimplemented())
                err = MException("Feature:NotImplemented", ...
                    "The association criterion '%s' is not " + ...
                    "implemented for geometry '%s'. \nProcess terminated.", char(criteria), class(feature));
                throwAsCaller(err);
            end
        end
    end

    methods(Static, Access = protected)

        function sigma = computeSigmaFromResiduals(residuals, numParams)

            residuals = residuals(:);
            n = numel(residuals);
            p = numParams;

            if n>p
                sigma = sqrt(sum(residuals.^2) / (n-p));
            else
                sigma = NaN;
            end
        end
    end
end
