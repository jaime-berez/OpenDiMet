% DEMOBENCHMARKING Benchmarking script for comparing OpenDiMet and
% Polyworks compared to reference NIST results. This script benchmarks
% OpenDiMet, and Polyworks results and produces a boxplot to compare the
% results with NIST.

%% Loading and preprocessing the data
clear; clc; close all

% Define the polyworks results excel file, the root directory for the
% reference dataset, and the number of files for each geometry.
benchmarkFile = "G:\My Drive\PhD\Research\SQA_NIST_Data_Reference_Sets_Results_2021-12-07.xlsx";
rootDirectory = "Data\nist-l2-reference-pairs\";
numOfFiles = 30;

% Load the polyworks table and rename the columns to a MATLAB suitable
% format
T = readtable(benchmarkFile, "TextType", "string");
T.Properties.VariableNames = matlab.lang.makeValidName(T.Properties.VariableNames);

% Check to see if the column names are as expected after makeValidName:
% ObjectName, Control, Nom, Meas
if ~all(ismember(["ObjectName", "Control", "Meas"], string(T.Properties.VariableNames)))
    error("Excel file must contain columns: Object Name, Control, Meas");
end

%% Geometry definitions
% Each geometry definition provides the following
% -- Name
% -- NIST folder and prefix
% -- OpenDiMet fitFeature arguments
% -- Polyworks parser availability and function
geometries = struct('name', {}, 'members', {}, 'hasEpsilon', {}, ...
    'hasAlpha', {}, 'hasDelta', {}, 'hasPsi', {}, 'hasBenchmark', {});

% Line2D
geometries(end+1) = makeGeometry("Line2D", makeMember("Line2d", "lin2d", "Line", "line", true, ...
    @parseLine2DPolyworks), true, true, false, false);

% Line3D
geometries(end+1) = makeGeometry("Line3D", makeMember("Line3d", "lin", "Line", "line", true, ...
    @parseLine3DPolyworks), true, true, false, false);

% Plane
geometries(end+1) = makeGeometry("Plane", makeMember("Plane", "pla", "Plane", "plane", true, ...
    @parsePlanePolyworks), true, true, false, false);

% Circle2D
geometries(end+1) = makeGeometry("Circle2D", makeMember("Circle2d", "cir2d", "Circle", "circle", true, ...
    @parseCircle2DPolyworks), true, true, true, false);

% Circle3D
geometries(end+1) = makeGeometry("Circle3D", makeMember("Circle3d", "cir", "Circle", "circle", true, ...
    @parseCircle3DPolyworks), true, true, true, false);

% Sphere
geometries(end+1) = makeGeometry("Sphere", makeMember("Sphere", "sph", "Sphere", "sphere", false, ...
    []), true, false, true, false);

% Cylinder
geometries(end+1) = makeGeometry("Cylinder", makeMember("Cylinder", "cyl", "Cylinder", "cylinder", true, ...
    @parseCylinderPolyworks), true, true, true, false);

% Cone
geometries(end+1) = makeGeometry("Cone", makeMember("Cone", "con", "Cone", "cone", true, ...
    @parseConePolyworks), true, true, true, true);

%% Error Computation Block

% Collect all errors for plotting
epsilonErrors = [];
epsilonErrorsLabel = strings(0,1);
alphaErrors = [];
alphaErrorsLabel = strings(0,1);
deltaErrors = [];
deltaErrorsLabel = strings(0,1);
psiErrors = [];
psiErrorsLabel = strings(0,1);

fprintf("=== Running benchmark across all geometries ===\n");

for g = 1:numel(geometries)
    G = geometries(g);
    fprintf("\n--- %s ---\n", G.name);

    % Build vectors for each source and each geometry
    for source = ["OpenDiMet", "Polyworks"]
        hasThisSource = (source == "OpenDiMet") || (source == "Polyworks" && G.hasBenchmark);
        if ~hasThisSource
            continue;
        end

        epsilonVector = [];
        alphaVector = [];
        deltaVector = [];
        psiVector = [];

        % Loop over members inside the geometry groups (if any)
        for m = 1:numel(G.members)
            M = G.members(m);
            if source == "Polyworks" && ~M.hasPolyworks
                continue;
            end

            for i = 1:numOfFiles
                dsFile = rootDirectory + M.folder + "\" + M.prefix + string(i) + ".ds";
                fitFile = rootDirectory + M.folder + "\" + M.prefix + string(i) + ".fit";

                data = readmatrix(dsFile, "FileType", "text");
                reference = readmatrix(fitFile, "FileType", "text");
                reference = reference(:);

                % Compute params for OpenDiMet
                if source == "OpenDiMet"
                    feature = fitFeature(data, M.geometryType, "LeastSquares", M.fitArg);
                    params = paramsFromFeature(feature, M.geometryType);
                else
                    params = M.benchmarkParser(T, i);
                end

                % Compute errors vs NIST
                [epsilonError, alphaError, deltaError, psiError] = computeErrors(G.name, ...
                    params, reference, data);

                epsilonVector(end+1,1) = epsilonError;
                if ~isnan(alphaError)
                    alphaVector(end+1,1) = alphaError;
                end
                if ~isnan(deltaError)
                    deltaVector(end+1,1) = deltaError;
                end
                if ~isnan(psiError)
                    psiVector(end+1,1) = psiError;
                end
            end
        end

        % Append into global error arrays with labels "Geometry - Source"
        tag = G.name + " (" + source + ")";

        epsilonErrors = [epsilonErrors; epsilonVector];
        epsilonErrorsLabel = [epsilonErrorsLabel; repmat(tag, numel(epsilonVector), 1)];

        if ~isempty(alphaVector)
            alphaErrors = [alphaErrors; alphaVector];
            alphaErrorsLabel = [alphaErrorsLabel; repmat(tag, numel(alphaVector), 1)];

            % Debugging
            % tags = unique(alphaErrorsLabel);
            % for k = 1:numel(tags)
            %     tag = tags(k);
            %     v = alphaErrors(alphaErrorsLabel == tag);
            %     v = v(isfinite(v) & v > 0);
            %     if isempty(v)
            %         fprintf("%s: no positive finite alpha\n", tag);
            %     else
            %         fprintf("%s: min=%g  median=%g  max=%g\n", tag, min(v), median(v), max(v));
            %     end
            % end
        end

        if ~isempty(deltaVector)
            deltaErrors = [deltaErrors; deltaVector];
            deltaErrorsLabel = [deltaErrorsLabel; repmat(tag, numel(deltaVector), 1)];
        end

        if ~isempty(psiVector)
            psiErrors = [psiErrors; psiVector];
            psiErrorsLabel = [psiErrorsLabel; repmat(tag, numel(psiVector), 1)];
        end
    end
end

%% Viz Block
figure('Name', 'Benchmark: OpenDiMet vs Polyworks vs NIST');
t = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'tight');
t.Title.String = "Association errors compared to NIST (OpenDiMet and Polyworks)";

nexttile;
boxplot(epsilonErrors, categorical(epsilonErrorsLabel));
set(gca, 'YScale', 'log');
grid on;
title("Location Error \epsilon");
ylabel("Error (Length Units)");

nexttile;
boxplot(alphaErrors, categorical(alphaErrorsLabel));
set(gca, 'YScale', 'log');
grid on;
title("Orientation Error \alpha");
ylabel("Error (Radians)");

nexttile;
boxplot(deltaErrors, categorical(deltaErrorsLabel));
set(gca, 'YScale', 'log');
grid on;
title("Size Error \delta");
ylabel("Error (Length Units)");

nexttile;
boxplot(psiErrors, categorical(psiErrorsLabel));
set(gca, 'YScale', 'log');
grid on;
title("Angle Error \psi");
ylabel("Error (Radians)");

%% Helper functions

function G = makeGeometry(name, members, hasEpsilon, hasAlpha, hasDelta, hasPsi)
%MAKEGEOMETRIES Function to fully describe a geometry. Returns a struct that
%carries all metadata needed to define the geometry and the error metrics
%tied to that geometry.
    G = struct();
    G.name = name;
    G.members = members;
    G.hasEpsilon = hasEpsilon;
    G.hasAlpha = hasAlpha;
    G.hasDelta = hasDelta;
    G.hasPsi = hasPsi;
    G.hasBenchmark = any([members.hasPolyworks]);
end

function M = makeMember(folder, prefix, geometryType, fitArg, hasPolyworks, parserFcn)
%MAKEMEMBER Function to describe how to process each geometry dataset.
%Returns a struct with the parameters to read datasets for each geometry,
%exceute association calls, and parse excel sheet for that specific
%geometry.
    M = struct();
    M.folder = string(folder);
    M.prefix = string(prefix);
    M.geometryType = string(geometryType);
    M.fitArg = string(fitArg);
    M.hasPolyworks = logical(hasPolyworks);
    M.benchmarkParser = parserFcn;
end

function params = paramsFromFeature(feature, geometryType)
%PARAMSFROMFEATURE Function to extract parameters from individual OpenDiMet
%objects to a params structure. This function handles the unique set of
%parameters applicable for each geometries and encapsulates them into a
%struct object.
    params = struct();
    params.point = feature.point;

    switch string(geometryType)
        case {"Line", "Plane", "Circle", "Cylinder", "Cone"}
            direction = feature.direction;
            params.direction = direction/norm(direction);
        otherwise
            params.direction = [NaN NaN NaN];
    end

    switch string(geometryType)
        case {"Circle", "Sphere", "Cylinder"}
            params.size = feature.diameter;
        case "Cone"
            params.size = feature.distance;
        otherwise
            params.size = NaN;
    end

    if string(geometryType) == "Cone"
        params.angleRad = deg2rad(feature.angle);
    else
        params.angleRad = NaN;
    end
end

function [epsilonError, alphaError, deltaError, psiError] = computeErrors(geometryName, ...
    params, reference, data)
%COMPUTEERRORS Function to compute location, orientation, size, and angle
%errors for individual geometry types.
    % Initialize error values as NaN
    epsilonError = NaN;
    alphaError = NaN;
    deltaError = NaN;
    psiError = NaN;

    geometryName = string(geometryName);
    reference = reference(:);

    % Extract the reference points (the first 3 elements of NIST .fit
    % files)
    pointReference = reference(1:3).';

    % Compute location error / epsilonError
    if geometryName == "Cylinder" || geometryName == "Cone"
        % In cases of cylinder and cone, compute the epsilonErrors by
        % projecting the centroid onto the axis of the geometry.
        centroid = mean(data,1);
        pointProjection = pp2l(params.point, centroid, params.direction);
        epsilonError = norm(pointProjection - pointReference);
    else
        epsilonError = norm(params.point - pointReference);
    end

    % Compute orientation error / alphaError
    if any(geometryName == ["Line2D", "Line3D", "Plane", "Circle2D", "Circle3D", "Cylinder", "Cone"])
        directionReference = reference(4:6).';
        directionReference = directionReference/norm(directionReference);
        directionCosine = abs(dot(params.direction(:)', directionReference)); % abs to make flip invariant
        directionCosine = max(min(directionCosine,1),-1);
        alphaError = acos(directionCosine);
    end

    % Compute size error / deltaError
    if any(geometryName == ["Circle2D", "Circle3D", "Cylinder"])
        deltaError = abs(params.size - reference(7));
    elseif geometryName == "Sphere"
        deltaError = abs(params.size - reference(4));
    elseif geometryName == "Cone"
        deltaError = abs(params.size - reference(7)); % distance
    end

    % Compute angel error / psiError
    if geometryName == "Cone"
        angleReferenceRad = deg2rad(reference(8));
        d = params.angleRad - angleReferenceRad;
        psiError = abs(mod(d + pi, 2*pi) - pi);   % wraps into (-pi,pi]
    end
end

function value = getControlMeasure(Tobj, key)
%GETCONTROLMEASURE Function to get the control measures from the excel
%sheet with selective keys. Returns a value tied to the specific key
%mentioned in the argument.
    idx = strcmpi(Tobj.Control, key);
    if ~any(idx)
        error("Missing Control '%s' for ObjectName '%s'.", key, string(Tobj.ObjectName(1)));
    end
    value = Tobj.Meas(find(idx,1,'first'));
end

%% Excel sheet parsers

function params = parseCircle2DPolyworks(T, idx)
%PARSECIRCLE2DPOLYWORKS Function to parse parameters from the polyworks
%excel sheet for 2d circles. Returns a struct object with the parsed results.
    obj = "CIR2D" + string(idx);
    Tobj = T(T.ObjectName == obj, :);

    if isempty(Tobj)
        error("No rows for '%s'", obj)
    end
    
    radius = getControlMeasure(Tobj, "Radius");
    x = getControlMeasure(Tobj, "X");
    y = getControlMeasure(Tobj, "Y");
    z = getControlMeasure(Tobj, "Z");
    i = getControlMeasure(Tobj, "I");
    j = getControlMeasure(Tobj, "J");
    k = getControlMeasure(Tobj, "K");

    d = [i j k];
    d = d/norm(d);
    params.point = [x y z];
    params.direction = d;
    params.size = 2*radius;
    params.angleRad = NaN;
end

function params = parseCircle3DPolyworks(T, idx)
%PARSECIRCLE3DPOLYWORKS Function to parse parameters from the polyworks
%excel sheet for 3d circles. Returns a struct object with the parsed
%results.
    obj = "CIR" + string(idx);
    Tobj = T(T.ObjectName == obj, :);

    if isempty(Tobj)
        error("No rows for '%s'", obj);
    end
    
    radius = getControlMeasure(Tobj, "Radius");
    x = getControlMeasure(Tobj, "X");
    y = getControlMeasure(Tobj, "Y");
    z = getControlMeasure(Tobj, "Z");
    i = getControlMeasure(Tobj, "I");
    j = getControlMeasure(Tobj, "J");
    k = getControlMeasure(Tobj, "K");

    d = [i j k];
    d = d/norm(d);
    params.point = [x y z];
    params.direction = d;
    params.size = 2*radius;
    params.angleRad = NaN;
end

function params = parseLine2DPolyworks(T, idx)
%PARSELINE2DPOLYWORKS Function to parse parameters from the polyworks excel
%sheet for 2d lines. Returns a struct object with the parsed results.
    objDirection = "LIN2D" + string(idx);
    objPoint = "LIN2D_PNT" + string(idx);

    TDirection = T(T.ObjectName == objDirection, :);
    TPoint = T(T.ObjectName == objPoint, :);

    if isempty(TDirection)
        error("No rows for '%s'", objDirection);
    end

    if isempty(TPoint)
        error("No rows for '%s'", objPoint);
    end

    i = getControlMeasure(TDirection, "I");
    j = getControlMeasure(TDirection, "J");
    k = getControlMeasure(TDirection, "K");
    x = getControlMeasure(TPoint, "X");
    y = getControlMeasure(TPoint, "Y");
    z = getControlMeasure(TPoint, "Z");

    d = [i j k];
    d = d/norm(d);
    params.point = [x y z];
    params.direction = d;
    params.size = NaN;
    params.angleRad = NaN;
end

function params = parseLine3DPolyworks(T, idx)
%PARSELINE3DPOLYWORKS Function to parse parameters from the polyworks excel
%sheet for 3d lines. Returns a struct object with the parsed results.
    objDirection = "LIN" + string(idx);
    objPoint = "LIN_PNT" + string(idx);

    TDirection = T(T.ObjectName == objDirection, :);
    TPoint = T(T.ObjectName == objPoint, :);

    if isempty(TDirection)
        error("No rows for '%s'", objDirection);
    end

    if isempty(TPoint)
        error("No rows for '%s'", objPoint);
    end

    i = getControlMeasure(TDirection, "I");
    j = getControlMeasure(TDirection, "J");
    k = getControlMeasure(TDirection, "K");
    x = getControlMeasure(TPoint, "X");
    y = getControlMeasure(TPoint, "Y");
    z = getControlMeasure(TPoint, "Z");

    d = [i j k];
    d = d/norm(d);
    params.point = [x y z];
    params.direction = d;
    params.size = NaN;
    params.angleRad = NaN;
end

function params = parsePlanePolyworks(T, idx)
%PARSEPLANEPOLYWORKS Function to parse parameters from the polyworks excel
%sheet for planes. Returns a struct object with parsed results.
    objDirection = "PLA" + string(idx);
    objPoint = "PLA_PNT" + string(idx);

    TDirection = T(T.ObjectName == objDirection, :);
    TPoint = T(T.ObjectName == objPoint, :);

    if isempty(TDirection)
        error("No rows for '%s'", objDirection);
    end
    if isempty(TPoint)
        error("No rows for '%s'", objPoint);
    end

    i = getControlMeasure(TDirection, "I");
    j = getControlMeasure(TDirection, "J");
    k = getControlMeasure(TDirection, "K");
    x = getControlMeasure(TPoint, "X");
    y = getControlMeasure(TPoint, "Y");
    z = getControlMeasure(TPoint, "Z");

    d = [i j k];
    d = d/norm(d);
    params.point = [x y z];
    params.direction = d;
    params.size = NaN;
    params.angleRad = NaN;
end

function params = parseCylinderPolyworks(T, idx)
%PARSECYLINDERPOLYWORKS Function to parse parameters from the polyworks
%excel sheet for cylinders. Returns a struct object with parsed results.
    objMain = "CYL" + string(idx);
    objPoint = "CYL_CIR" + string(idx);

    TMain = T(T.ObjectName == objMain, :);
    TPoint = T(T.ObjectName == objPoint, :);

    if isempty(TMain)
        error("No rows for '%s'", objMain);
    end
    if isempty(TPoint)
        error("No rows for '%s'", objPoint);
    end

    radius = getControlMeasure(TMain, "Radius");
    i = getControlMeasure(TMain, "I");
    j = getControlMeasure(TMain, "J");
    k = getControlMeasure(TMain, "K");
    x = getControlMeasure(TPoint, "X");
    y = getControlMeasure(TPoint, "Y");
    z = getControlMeasure(TPoint, "Z");

    d = [i j k];
    d = d/norm(d);
    params.point = [x y z];
    params.direction = d;
    params.size = 2*radius;
    params.angleRad = NaN;
end

function params = parseConePolyworks(T, idx)
%PARSECONEPOLYWORKS Function to parse parameters from the polyworks excel
%sheet for cones. Returns a struct object with parsed results.
    objMain = "CON" + string(idx);
    objPoint = "CON_CIR" + string(idx);

    TMain = T(T.ObjectName == objMain, :);
    TPoint = T(T.ObjectName == objPoint, :);

    if isempty(TMain)
        error("No rows for '%s'", objMain);
    end
    if isempty(TPoint)
        error("No rows for '%s'", objPoint);
    end

    angleDeg = getControlMeasure(TMain, "Included Angle");
    i = getControlMeasure(TMain, "I");
    j = getControlMeasure(TMain, "J");
    k = getControlMeasure(TMain, "K");
    x = getControlMeasure(TPoint, "X");
    y = getControlMeasure(TPoint, "Y");
    z = getControlMeasure(TPoint, "Z");
    distance = NaN; % Distance is not present in the excel sheet as a result

    d = [i j k];
    d = d/norm(d);
    params.point = [x y z];
    params.direction = d;
    params.size = distance;
    params.angleRad = deg2rad(angleDeg);
end


