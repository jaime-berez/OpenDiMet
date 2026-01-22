classdef Feature < handle
    % FEATURE Base class for geometric features.
    % The Feature class provides a foundation for the geometric feature
    % types. Each feature stores a descriptive name, an association type
    % and the raw coordinate data used for the fitting process.
    %
    % Properties:
    % name                - (1x1 string) user-defined name of the feature. If empty, the
    %                       class attempts to infer a name from the source file; otherwise
    %                       defaults to "UnnamedFeature".
    % AssociationCriteria - (1x1 AssociationCriteria) Enumeration sepcifying the fitting method
    %                       used to associate the feature to the input
    %                       data.
    % sigma               - (1x1 double) A nonnegative scalar reporting the standard deviation
    %                       of the residuals of the fitted feature. 
    % sourceFile          - (1x1 string) The full or relative path of the file from which the input
    %                       coordinate data were loaded. Used for
    %                       traceability, and naming.
    % data                - (Nx3 double, private access) Coordinate points
    %                       defining the feature. This array is stored exactly as provided by the user. 

    properties (GetAccess = public, SetAccess = public)
        name (1,1) string {mustBeTextScalar, mustBeNonempty} = ""
        AssociationCriteria (1,1) AssociationCriteria = AssociationCriteria.LeastSquares 
        sigma (1,1) double {mustBeFinite, mustBeReal, mustBeNonnegative}
        sourceFile (1,1) string = ""
    end

    properties (GetAccess = public, SetAccess = private)
        data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan}
    end

    methods
        function obj = Feature(name, data, associationCriteria, sourceFile)
            arguments
                name (1,1) string {mustBeTextScalar, mustBeNonempty}
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                associationCriteria (1,1) AssociationCriteria
                sourceFile (1,1) string = ""
            end

            obj.sourceFile = sourceFile;
            if strlength(name) == 0
                if strlength(sourceFile) > 0
                    [~, base] = fileparts(sourceFile);
                    obj.name = string(base);
                else
                    obj.name = "UnnamedFeature";
                end
            else
                obj.name = string(name);
            end
            
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
end
