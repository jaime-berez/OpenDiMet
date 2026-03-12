classdef Feature < handle
    % FEATURE Base class for geometric features.
    %
    %   Syntax
    %     obj = Feature(name, data, fitCriterion)
    %     obj = Feature(name, data, fitCriterion, sourceFile)
    %     obj = Feature(name, data, fitCriterion, sourceFile, materialSide)
    %
    %   Input Arguments
    %     name - Feature name
    %       string scalar | character vector
    %     data - Measured 3D point coordinates
    %       Nx3 double matrix
    %     fitCriterion - Fitting criterion
    %       fitType enumeration
    %     sourceFile - Source file associated with the data
    %       string scalar
    %     materialSide - Material-side designation
    %       MaterialSide enumeration
    %
    %   Output Arguments
    %     obj - Geometric feature base object
    %       Feature scalar
    %
    %   Properties
    %     name - 1x1 string, feature name
    %     fitType - 1x1 fitType, association criterion used for fitting
    %     sigma - 1x1 double, standard deviation of fitting residuals
    %     sourceFile - 1x1 string, source file associated with the input data
    %     materialSide - 1x1 MaterialSide, material-side designation
    %     data - Nx3 double, measured coordinate points used to define the feature
    %
    %   Example
    %     F = Feature("My Feature", data, fitType.LeastSquares);

    properties (GetAccess = public, SetAccess = public)
        name (1,1) string {mustBeTextScalar, mustBeNonempty} = ""
        fitType (1,1) fitType = fitType.LeastSquares
        sigma (1,1) double {mustBeFinite, mustBeReal, mustBeNonnegative}
        sourceFile (1,1) string = ""
        materialSide (1,1) MaterialSide = MaterialSide.Unspecified
    end

    properties (GetAccess = public, SetAccess = private)
        data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan}
    end

    methods
        function obj = Feature(name, data, fitCriterion, sourceFile, materialSide)
            % Constructor for feature class
            arguments
                name (1,1) string {mustBeTextScalar, mustBeNonempty}
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                fitCriterion (1,1) fitType
                sourceFile (1,1) string = ""
                materialSide (1,1) MaterialSide = MaterialSide.Unspecified
            end

            obj.sourceFile = sourceFile;
            obj.materialSide = materialSide;

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

            obj.fitType = fitCriterion;
            obj.data = data;
        end
    end

    methods (Access = protected)
        function validateAssociation(feat)
            % VALIDATEASSOCIATION Validate that the selected fitting criterion supports the geometry.
            %
            %   Syntax
            %     validateAssociation(feat)
            %
            %   Input Arguments
            %     feat - Geometric feature object
            %       Feature scalar
            %
            %   Example
            %     feat.validateAssociation();

            geom = class(feat);
            ft = feat.fitType;

            % List of the supported geometries
            supportedGeometries = ft.supportedGeometries();

            % Check if the selected geometry is supported
            if ~ismember(lower(geom), lower(supportedGeometries))
                err = MException("Feature:UnsupportedFit", ...
                    "%s does not support %s association criterion.\nProcess terminated.", geom, char(ft));
                throwAsCaller(err);
            end

            % Check if the selected fitType is implemented
            if any(ft == fitType.unimplemented())
                err = MException("Feature:NotImplemented", ...
                    "The association criterion '%s' is not " + ...
                    "implemented for geometry '%s'. \nProcess terminated.", char(ft), class(feat));
                throwAsCaller(err);
            end
        end
    end

    methods (Static, Access = protected)
        function rgb = parseColor(clr)
            % PARSECOLOR Convert a color specification to an RGB triplet.
            %
            %   Syntax
            %     rgb = Feature.parseColor(clr)
            %
            %   Input Arguments
            %     clr - Color specification
            %       1x3 numeric RGB triplet | color name | short color code | hex string
            %
            %   Output Arguments
            %     rgb - RGB color triplet
            %       1x3 double vector
            %
            %   Example
            %     rgb = Feature.parseColor("green");
            %     rgb = Feature.parseColor("#00FF00");

            if isnumeric(clr)
                rgb = clr;
                return;
            end

            s = lower(strtrim(string(clr)));

            % Matlab like names and short codes
            switch s
                case {"r", "red"},    rgb = [1 0 0];
                case {"g","green"},   rgb = [0 1 0];
                case {"b","blue"},    rgb = [0 0 1];
                case {"c","cyan"},    rgb = [0 1 1];
                case {"m","magenta"}, rgb = [1 0 1];
                case {"y","yellow"},  rgb = [1 1 0];
                case {"k","black"},   rgb = [0 0 0];
                case {"w","white"},   rgb = [1 1 1];

                otherwise
                    % Hex color
                    if startsWith(s,"#") && strlength(s)==7
                        vals = sscanf(char(extractAfter(s,1)), '%2x%2x%2x');
                        rgb = (vals(:).'/255);
                    else
                        error("Cylinder:InvalidColor", ...
                            "Unrecognized color '%s'. Use a name (e.g. 'green'), short code (e.g. 'g'), hex '#RRGGBB', or RGB [1x3].", s);
                    end
            end
        end

        function ls = parseLineStyle(style)
            % PARSELINESTYLE Convert a line-style specification to a MATLAB line-style code.
            %
            %   Syntax
            %     ls = Feature.parseLineStyle(style)
            %
            %   Input Arguments
            %     style - Line-style specification
            %       string scalar | character vector
            %
            %   Output Arguments
            %     ls - MATLAB line-style code
            %       string scalar
            %
            %   Example
            %     ls = Feature.parseLineStyle("dashdot");
            %     ls = Feature.parseLineStyle("--");

            s = lower(strtrim(string(style)));
            switch s
                case {"solid","-"}
                    ls = "-";
                case {"dashed","dash","--"}
                    ls = "--";
                case {"dotted","dot",":"}
                    ls = ":";
                case {"dashdot","-."}
                    ls = "-.";
                case {"none",""}
                    ls = "none";
                otherwise
                    error("Cylinder:InvalidLineStyle", ...
                        "Unrecognized line style '%s'. Use: solid, dashed, dotted, dashdot, none.", s);
            end
        end
    end
end
