classdef Feature < handle
    % FEATURE Base class for geometric features.
    % The Feature class provides a foundation for the geometric feature
    % types. Each feature stores a descriptive name, an association type
    % and the raw coordinate data used for the fitting process.
    %
    % Properties:
    % name                : (1x1 string) user-defined name of the feature. If empty, the
    %                       class attempts to infer a name from the source file; otherwise
    %                       defaults to "UnnamedFeature".
    % fitType             : (1x1 fitType) Enumeration sepcifying the fitting method
    %                       used to associate the feature to the input
    %                       data.
    % sigma               : (1x1 double) A nonnegative scalar reporting the standard deviation
    %                       of the residuals of the fitted feature. 
    % sourceFile          : (1x1 string) The full or relative path of the file from which the input
    %                       coordinate data were loaded. Used for
    %                       traceability, and naming.
    % data                : (Nx3 double, private access) Coordinate points
    %                       defining the feature. This array is stored exactly as provided by the user. 

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
        function obj = Feature(name, data, ft, sourceFile, materialSide)
            arguments
                name (1,1) string {mustBeTextScalar, mustBeNonempty}
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                ft (1,1) fitType
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

            obj.fitType = ft;
            obj.data = data;
        end
    end

    methods (Access = protected)
        function validateAssociation(feat)
            % Function to validate the fitType
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
            % Accept RGB (1x3), Matlab short codes, names, or hex '#RRGGBB'.

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
