function feat = fitFeature(data, featType, ft, featName, opts)
    % Function to fit feature to coordinate data
    arguments
        %data (:, 3) double {mustBeFinite, mustBeReal, mustBeNonempty, mustBeNonNan}
        data {mustBeA(data, {'double', 'string', 'char'})}
        featType {mustBeA(featType, {'char', 'string'})}
        ft {mustBeA(ft, {'fitType', 'char', 'string'})}
        featName (1,1) string = ""
        opts.MaxIter       (1,1) double {mustBeFinite, mustBePositive} = 5000
        opts.StepTol       (1,1) double {mustBeFinite, mustBePositive} = 1e-9
        opts.GradTol       (1,1) double {mustBeFinite, mustBePositive} = 1e-11
        opts.SSETol        (1,1) double {mustBeFinite, mustBePositive} = 1e-19
        opts.Lambda        (1,1) double {mustBeFinite, mustBePositive} = 1e-4
        opts.DampingCoeff  (1,1) double {mustBeFinite, mustBePositive} = 2
        opts.SuppressOutput(1,1) logical = true
        opts.materialSide (1,1) MaterialSide = MaterialSide.Unspecified
    end

    featType = string(featType);

    validFeatTypes = ["Line", "Plane", "Circle", "Cylinder", "Sphere", "Cone"];
    if ~ismember(featType, validFeatTypes)
        error("fitFeature:InvalidFeatureType", ...
                "featType must be one of: %s", strjoin(validFeatTypes, ", "));
    end

    if ~isa(ft, "fitType")
        ft = fitType.(string(ft));
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

    switch featType
        case {"Line","Plane","Circle"}
            if optsForward.materialSide ~= MaterialSide.Unspecified
                error("fitFeature:OptionNotApplicable", ...
                    "Option 'materialSide' is not applicable to featType '%s'.", featType);
            end
            optsForward = rmfield(optsForward, "materialSide");
    end

    % Convert opts to 'Name', Value list to forward to constructors
    nameValue = namedargs2cell(optsForward);
    nameValue = [nameValue, {'sourceFile', srcFile}];

    % Fit the selected feature type
    switch featType
        case "Line"
            feat = Line(featName, data, ft, nameValue{:});
        case "Plane"
            feat = Plane(featName, data, ft, nameValue{:});
        case "Circle"
            feat = Circle(featName, data, ft, nameValue{:});
        case "Sphere"
            feat = Sphere(featName, data, ft, nameValue{:});
        case "Cylinder"
            feat = Cylinder(featName, data, ft, nameValue{:});
        case "Cone"
            feat = Cone(featName, data, ft, nameValue{:});
        otherwise
            error(['Unsupported feature type: %s. featType must be one of the following ' ...
                'Line, Cylinder, Plane, Circle, Sphere, Cone.'], featType);
    end
end
