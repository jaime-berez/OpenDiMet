function feat = fitFeature(data, featType, fitCriterion, featName, opts)
    % FITFEATURE Fit a geometric feature to coordinate data.
    %
    %   Syntax
    %     feat = fitFeature(data, featType, fitCriterion)
    %     feat = fitFeature(data, featType, fitCriterion, featName)
    %     feat = fitFeature(data, featType, fitCriterion, featName, Name = Value)
    %
    %   Input Arguments
    %     data - Measured coordinate data or path to a data file
    %       Nx3 double matrix | string scalar | character vector
    %     featType - Geometry type to be fitted
    %       string scalar | character vector
    %       Supported values: "Line", "Plane", "Circle", "Sphere", "Cylinder", "Cone"
    %     fitCriterion - Fitting criterion
    %       fitType enumeration | string scalar | character vector
    %     featName - Name assigned to the created feature
    %       string scalar
    %
    %   Name-Value Arguments
    %     MaxIter - Maximum number of LM iterations
    %       positive scalar double
    %     StepTol - Step-size convergence tolerance
    %       positive scalar double
    %     GradTol - Gradient convergence tolerance
    %       positive scalar double
    %     SSETol - Sum-of-squared-errors convergence tolerance
    %       positive scalar double
    %     Lambda - Initial damping parameter for LM
    %       positive scalar double
    %     DampingCoeff - LM damping update coefficient
    %       positive scalar double
    %     SuppressOutput - Flag to suppress optimizer output
    %       logical scalar
    %     materialSide - Material-side designation for applicable geometries
    %       MaterialSide enumeration
    %     refDir - 1x3 double - Reference direction used to constrain the plane
    %       orientation
    %       Specifies a direction pointing outward from the material
    %       surface and is required for constrained plane fitting methods.
    %
    %   Output Arguments
    %     feat - Fitted feature object
    %       Line | Plane | Circle | Sphere | Cylinder | Cone
    %
    %   Example
    %     feat = fitFeature(data, "Plane", fitType.LeastSquares);
    %     feat = fitFeature("points.txt", "Cylinder", fitType.LeastSquares, "Cylinder 1");
    
    arguments
        data {mustBeA(data, {'double', 'string', 'char'})}
        featType {mustBeTextScalar, mustBeMember(featType, ["Line","Plane","Circle","Sphere","Cylinder","Cone"])}
        fitCriterion {mustBeTextScalar, mustBeMember(fitCriterion, ...
                ["LeastSquares","MiniMax","MinimumCircumscribed", ...
                "MaximumInscribed","MinimumTotalDistance","WeightedLeastSquares"])}
        featName (1,1) string = ""
        opts.MaxIter       (1,1) double {mustBeFinite, mustBePositive} = 5000
        opts.StepTol       (1,1) double {mustBeFinite, mustBePositive} = 1e-9
        opts.GradTol       (1,1) double {mustBeFinite, mustBePositive} = 1e-11
        opts.SSETol        (1,1) double {mustBeFinite, mustBePositive} = 1e-19
        opts.Lambda        (1,1) double {mustBeFinite, mustBePositive} = 1e-4
        opts.DampingCoeff  (1,1) double {mustBeFinite, mustBePositive} = 2
        opts.SuppressOutput(1,1) logical = true
        opts.materialSide (1,1) MaterialSide = MaterialSide.Unspecified
        opts.refDir double = []
    end

    featType = string(featType);

    validFeatTypes = ["Line", "Plane", "Circle", "Cylinder", "Sphere", "Cone"];
    if ~ismember(featType, validFeatTypes)
        error("fitFeature:InvalidFeatureType", ...
                "featType must be one of: %s", strjoin(validFeatTypes, ", "));
    end
    

    if ~isa(fitCriterion, "fitType")
        fitCriterion = fitType.(string(fitCriterion));
    end

    srcFile = "";
    if isnumeric(data)
        data = data;
    else
        srcFile = string(data);
        data = readData(srcFile);
    end

    if strlength(featName) == 0
        if strlength(srcFile) > 0
            [~, base] = fileparts(srcFile);
            featName = string(base);
        else
            featName = "UnnamedFeature";
        end
    end

    % Filter geometry inapplicable options before forwarding
    optsForward = opts;

    % switch featType
    %     case {"Line","Plane","Circle"}
    %         if optsForward.materialSide ~= MaterialSide.Unspecified
    %             error("fitFeature:OptionNotApplicable", ...
    %                 "Option 'materialSide' is not applicable to featType '%s'.", featType);
    %         end
    %         optsForward = rmfield(optsForward, "materialSide");
    % end

    % materialSide only applies to Sphere, Cylinder, Cone
    if ismember(featType, ["Line","Plane","Circle"])
        if optsForward.materialSide ~= MaterialSide.Unspecified
            error("fitFeature:OptionNotApplicable", ...
                "Option 'materialSide' is not applicable to featType '%s'.", featType);
        end
        optsForward = rmfield(optsForward, "materialSide");
    end
    
    % refDir only applies to Line and Plane
    if ~ismember(featType, ["Line","Plane"])
        if ~isempty(optsForward.refDir)
            error("fitFeature:OptionNotApplicable", ...
                "Option 'refDir' is not applicable to featType '%s'.", featType);
        end
        optsForward = rmfield(optsForward, "refDir");
    end

    % Convert opts to 'Name', Value list to forward to constructors
    nameValue = namedargs2cell(optsForward);
    nameValue = [nameValue, {'sourceFile', srcFile}];

    % Fit the selected feature type
    switch featType
        case "Line"
            feat = Line(featName, data, fitCriterion, nameValue{:});
        case "Plane"
            feat = Plane(featName, data, fitCriterion, nameValue{:});
        case "Circle"
            feat = Circle(featName, data, fitCriterion, nameValue{:});
        case "Sphere"
            feat = Sphere(featName, data, fitCriterion, nameValue{:});
        case "Cylinder"
            feat = Cylinder(featName, data, fitCriterion, nameValue{:});
        case "Cone"
            feat = Cone(featName, data, fitCriterion, nameValue{:});
        otherwise
            error(['Unsupported feature type: %s. featType must be one of the following ' ...
                'Line, Cylinder, Plane, Circle, Sphere, Cone.'], featType);
    end
end
