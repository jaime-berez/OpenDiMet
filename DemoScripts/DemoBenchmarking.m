% DEMOBENCHMARKING Benchmarking script for comparing OpenDiMet and
% Polyworks compared to reference NIST results. This script benchmarks
% OpenDiMet, and Polyworks results and produces a boxplot to compare the
% results with NIST.

%% Loading and preprocessing the data
clear; clc; close all

% Define the polyworks results excel file, the root directory for the
% reference dataset, and the number of files for each geometry.
benchmarkFile = "G:\Shared drives\research-BerezLab-GroupDrive\ResearchProjects" + ...
                "\OpenDiMet\SQA_NIST_Data_Reference_Sets_Results_2021-12-07.xlsx";
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
% -- Name.
% -- NIST folder and prefix.
% -- OpenDiMet fitFeature arguments.
% -- Polyworks parser availability and function.
% -- Information regarding specific errors tied to indvidual geometries.
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

% Per-file audit log
varNames = {'Geometry','Source','Member','FileIndex','dsFile','fitFile', ...
            'epsilon','alpha','delta','psi', 'alphaDeg', 'psiDeg', 'Note'};
resultsLog = table( ...
    strings(0,1), strings(0,1), strings(0,1), ...
    zeros(0,1),   strings(0,1), strings(0,1), ...
    NaN(0,1),     NaN(0,1),     NaN(0,1),     NaN(0,1), ...
    NaN(0,1), NaN(0,1), ...
    strings(0,1), ...
    'VariableNames', varNames );


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
                
                % Debugging (cone #1 only, OpenDiMet only)
                % if G.name=="Cone" && source=="OpenDiMet" && i==1
                %     fprintf("feature.angle raw      = %.12g\n", feature.angle);
                %     fprintf("feature.angle as deg   = %.6f\n", rad2deg(feature.angle));
                %     fprintf("reference(8) raw       = %.12g\n", reference(8));
                % end

                % Compute errors vs NIST
                [epsilonError, alphaError, deltaError, psiError] = computeErrors(G.name, ...
                    params, reference, data);

                alphaDeg = rad2deg(alphaError);
                psiDeg = rad2deg(psiError);

                note = "";      
                if source == "Polyworks" && G.name=="Cone" && isnan(deltaError)
                    note = "Polyworks export missing cone distance -> delta undefined";
                end
                
                if isnan(alphaError) && any(G.name==["Line2D","Line3D","Plane","Circle2D",...
                            "Circle3D","Cylinder","Cone"])
                    note = note + " alpha undefined";
                end

                % Append to audit log
                resultsLog = [resultsLog; { ...
                    G.name, source, M.folder, ...
                    i, dsFile, fitFile, ...
                    epsilonError, alphaError, deltaError, psiError, alphaDeg, ...
                    psiDeg, note}];

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


%% Populate the error table with results

alphaErrorsDeg = rad2deg(alphaErrors);
psiErrorsDeg = rad2deg(psiErrors);

epsilonSummary = summarizeErrorVectors(epsilonErrors, epsilonErrorsLabel);
alphaSummary   = summarizeErrorVectors(alphaErrorsDeg, alphaErrorsLabel);
deltaSummary   = summarizeErrorVectors(deltaErrors, deltaErrorsLabel);
psiSummary     = summarizeErrorVectors(psiErrorsDeg, psiErrorsLabel);

outFile = "benchmark_summary_tables.xlsx";
writetable(epsilonSummary, outFile, "Sheet","epsilon");
writetable(alphaSummary,   outFile, "Sheet","alpha");
writetable(deltaSummary,   outFile, "Sheet","delta");
writetable(psiSummary,     outFile, "Sheet","psi");

writetable(resultsLog, "benchmark_per_file_errors.xlsx");

% Top 10 worst cone cases by metric (OpenDiMet + Polyworks)
coneAll = resultsLog(resultsLog.Geometry=="Cone", :);

for source = ["OpenDiMet","Polyworks"]
    coneS = coneAll(coneAll.Source==source, :);

    % epsilon
    tmp = coneS(isfinite(coneS.epsilon), :);
    tmp = sortrows(tmp, "epsilon", "descend");
    writetable(tmp(1:min(10,height(tmp)),:), "cone_top10_epsilon_" + source + ".xlsx");

    % alpha
    tmp = coneS(isfinite(coneS.alpha), :);
    tmp = sortrows(tmp, "alphaDeg", "descend");
    writetable(tmp(1:min(10,height(tmp)),:), "cone_top10_alpha_" + source + ".xlsx");

    % delta
    tmp = coneS(isfinite(coneS.delta), :);
    tmp = sortrows(tmp, "delta", "descend");
    writetable(tmp(1:min(10,height(tmp)),:), "cone_top10_delta_" + source + ".xlsx");

    % psi
    tmp = coneS(isfinite(coneS.psi), :);
    tmp = sortrows(tmp, "psiDeg", "descend");
    writetable(tmp(1:min(10,height(tmp)),:), "cone_top10_psi_" + source + ".xlsx");
end

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
        params.angleRad = 2 * feature.angle;
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
        % directionCosine = abs(dot(params.direction(:)', directionReference)); % abs to make flip invariant
        % directionCosine = max(min(directionCosine,1),-1);
        % alphaError = acos(directionCosine);
        directionCosine = params.direction(:)';
        directionCosine = directionCosine/norm(directionCosine);
        cosAlpha = abs(dot(directionCosine, directionReference));
        sinAlpha = norm(cross(directionCosine, directionReference));
        alphaError = atan2(sinAlpha, cosAlpha);
    end

    % Compute size error / deltaError
    if any(geometryName == ["Circle2D", "Circle3D", "Cylinder"])
        deltaError = abs(params.size - reference(7));
    elseif geometryName == "Sphere"
        deltaError = abs(params.size - reference(4));
    elseif geometryName == "Cone"
        deltaError = abs(params.size - reference(7)); % distance
    end

    % Compute angle error / psiError
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

%% Summarizing the errors

function S = summarizeErrorVectors(values, labels)
%SUMMARIZEERRORVECTORS Function to summarize the error vectors for
%analysis. Returns a table with summary stats.
    tags = unique(labels);
    nTags = numel(tags);

    Tag = strings(nTags,1);
    N = zeros(nTags,1);
    Min = NaN(nTags,1);
    Q1 = NaN(nTags,1);
    Median = NaN(nTags,1);
    Q3 = NaN(nTags,1);
    IQR = NaN(nTags,1);
    Max = NaN(nTags,1);
    P95 = NaN(nTags,1);

    for k = 1:nTags
        t = tags(k);
        v = values(labels == t);

        v = v(isfinite(v));
        v = v(v >= 0);

        Tag(k) = string(t);
        N(k) = numel(v);

        if N(k) > 0
            Min(k) = min(v);
            Q1(k) = prctile(v,25);
            Median(k) = median(v);
            Q3(k) = prctile(v,75);
            IQR(k) = Q3(k) - Q1(k);
            Max(k) = max(v);
            P95(k) = prctile(v,95);
        end
    end

    S = table(Tag, N, Min, Q1, Median, Q3, IQR, P95, Max);
    S = sortrows(S, "Tag");
end


%% Viz Block

figure('Name', 'Benchmark: OpenDiMet vs Polyworks vs NIST');
set(gcf, 'Color', 'w');
t = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
geomOrder = ["Circle2D","Circle3D","Cone","Cylinder","Sphere","Line2D","Line3D","Plane"];

% Color set 1
% cOpenDiMet = [0.10 0.60 0.20]; % green
% cPolyworks = [0.15 0.35 0.85]; % blue

% % Color set 2
% cOpenDiMet = [0 0 0]; % black
% cPolyworks = [0.35 0.35 0.35]; % gray

% Color set 3
cOpenDiMet = [1 0 0];
cPolyworks = [0 0 1];

ax = nexttile;
plotGroupedBoxPlot(ax, resultsLog, "epsilon", "Location Error [mm]",  "Location Error, \epsilon", ... 
                        geomOrder, cOpenDiMet, cPolyworks, false, true);
ax = nexttile;
plotGroupedBoxPlot(ax, resultsLog, "alphaDeg",   "Orientation Error [deg]", "Orientation Error, \alpha", ...
                        geomOrder, cOpenDiMet, cPolyworks, false, true);
ax = nexttile;
plotGroupedBoxPlot(ax, resultsLog, "delta",   "Size Error [mm]",  "Size Error, \delta", ...
                        geomOrder, cOpenDiMet, cPolyworks, false, true);
ax = nexttile;
plotGroupedBoxPlot(ax, resultsLog, "psiDeg",     "Angle Error [deg]", "Angle Error, \psi", ...
                        geomOrder, cOpenDiMet, cPolyworks, true, true);

% Helper function to plot grouped box plots
function plotGroupedBoxPlot(ax, resultsLog, metricName, yLab, ttl, ...
        geomOrder, cOD, cPW, showLegend, showOnlyWithData)
%PLOTGROUPEDBOXPLOT Function to plot grouped box plots of association
%errors from resultsLog.

    if nargin < 10    
        showOnlyWithData = false;   
    end
    
    metricName = string(metricName);
    
    % Pull data    
    geom = string(resultsLog.Geometry);    
    source = string(resultsLog.Source);    
    y = resultsLog.(metricName);    
    ok = isfinite(y) & ~isnan(y) & (y >= 0);    
    geom = geom(ok);    
    source = source(ok);    
    y = y(ok);
    
    % Log scale can't show 0, map 0s to eps  
    yPlot = y;    
    yPlot(yPlot == 0) = eps;   

    % Map geometry    
    [tf, pos] = ismember(geom, geomOrder);    
    geom = geom(tf);    
    source = source(tf);    
    yPlot = yPlot(tf);    
    pos = pos(tf);
    
    % Split by source    
    isOD = source == "OpenDiMet";    
    isPW = source == "Polyworks";
    
    % Offsets so boxes sit side-by-side per geometry    
    off = 0.18;    
    hold(ax, 'on');    
    ax.ColorOrder = [1 0 0; 0 0 1];    
    ax.ColorOrderIndex = 1;    
    if any(isOD)    
        bc1 = boxchart(ax, pos(isOD) - off, yPlot(isOD));        
        bc1.BoxFaceColor = 'none';        
        bc1.BoxEdgeColor = cOD;        
        bc1.WhiskerLineColor = cOD;        
        bc1.MarkerColor = cOD;        
        bc1.MarkerStyle = 'o';        
        bc1.MarkerSize = 3;        
        bc1.LineWidth = 1.0;    
    end
    
    if any(isPW)  
        bc2 = boxchart(ax, pos(isPW) + off, yPlot(isPW));     
        bc2.BoxFaceColor = 'none';
        bc2.BoxEdgeColor = cPW;        
        bc2.WhiskerLineColor = cPW;        
        bc2.MarkerColor = cPW;        
        bc2.MarkerStyle = 's';       
        bc2.MarkerSize = 3;        
        bc2.LineWidth = 1.0;    
    end
    
    % Formatting    
    ax.YScale = 'log';    
    ax.LineWidth = 1.2;    
    ax.Box = 'on';    
    ax.FontSize = 8;    
    ax.FontName = 'Arial';    
    grid(ax, 'on');    
    ax.GridAlpha = 0.15;    
    ax.MinorGridAlpha = 0.08;    
    ax.XMinorTick = 'off';    
    ax.YMinorTick = 'on';    
    title(ax, ttl, 'FontSize', 8, 'FontName', 'Arial', 'FontWeight', 'normal');    
    ylabel(ax, yLab, 'FontSize', 8);
    
    % Lock identical x-frame for all subplots    
    ax.XLim = [0, numel(geomOrder) + 1];    
    ax.XTick = 1:numel(geomOrder);    
    ax.XTickLabel = geomOrder;    
    ax.XTickLabelRotation = 25;
    
    % Only label geometries that appear in this metric    
    if showOnlyWithData    
        present = false(size(geomOrder));     
        present(unique(pos)) = true;       
        labels = strings(size(geomOrder));        
        labels(present) = geomOrder(present);        
        ax.XTickLabel = labels; % keeps spacing, hides unused labels    
    end
    
    % Legend inside each subplot 
    if showLegend     
        % Define location of the legend      
        lx = 0.55; ly = 0.55; lw = 0.42; lh = 0.42;    
        % Call the helper       
        drawCustomLegendBox(ax, lx, ly, lw, lh, cOD, cPW);    
    end 

    % Export plot
    hold(ax, 'off');
    set(gcf, 'Units', 'inches');
    set(gcf, 'Position', [1 1 8 6]); % 8 in wide and 6 inch tall
    figName = 'Least-squares association error';

    % High-resolution raster file
    exportgraphics(gcf, figName + ".png", ...
                        'Resolution', 600, 'BackgroundColor', 'white');
    % Vector formats
    exportgraphics(gcf, figName + ".pdf", 'ContentType', 'vector');

    exportgraphics(gcf, figName + ".svg", 'ContentType', 'vector');

    exportgraphics(gcf, figName + ".eps", 'ContentType', 'vector');
end

function drawCustomLegendBox(ax, x, y, w, h, cOD, cPW)
%DRAWCUSTOMLEGENDBOX Function to draw custom legend box inside the plot
%with a specified length, width, height, and position.

    % Setup & Helper for coordinate conversion
    xLim = xlim(ax);
    yLim = ylim(ax);
    xLog = strcmp(ax.XScale, 'log');
    yLog = strcmp(ax.YScale, 'log');

    function val = n2d(normVal, lims, isLog)
        if isLog
            val = 10.^(log10(lims(1)) + normVal .* (log10(lims(2)) - log10(lims(1))));
        else
            val = lims(1) + normVal .* (lims(2) - lims(1));
        end
    end

    % Draw Legend Background
    rectX = n2d(x, xLim, xLog);
    rectW = n2d(x + w, xLim, xLog) - rectX;
    rectY_bottom = n2d(y, yLim, yLog);
    rectY_top = n2d(y + h, yLim, yLog);
    rectH = rectY_top - rectY_bottom;

    rectangle(ax, 'Position', [rectX, rectY_bottom, rectW, rectH], ...
        'Curvature', 0.02, ...
        'FaceColor', 'w', 'EdgeColor', 'k', 'LineWidth', 1);

    % Layout Constants
    iconX_center = x + 0.06;   
    icon_width   = 0.025;       
    textX        = x + 0.13;   
    
    % Adjustment
    y1_norm = y + h * 0.86; % OpenDiMet 
    y2_norm = y + h * 0.76; % Polyworks 
    yc_norm = y + h * 0.38; % Diagram Center

    % Draw Series Lines
    % OpenDiMet (Red)
    lx1 = n2d(iconX_center - icon_width, xLim, xLog);
    lx2 = n2d(iconX_center + icon_width, xLim, xLog);
    ly1 = n2d(y1_norm, yLim, yLog);
    plot(ax, [lx1 lx2], [ly1 ly1], '-', 'Color', cOD, 'LineWidth', 2);
    text(ax, textX, y1_norm, 'OpenDiMet', 'Units', 'normalized', ...
        'FontSize', 7, 'FontName', 'Arial', 'VerticalAlignment', 'middle');

    % Polyworks (Blue)
    ly2 = n2d(y2_norm, yLim, yLog);
    plot(ax, [lx1 lx2], [ly2 ly2], '-', 'Color', cPW, 'LineWidth', 2);
    text(ax, textX, y2_norm, 'Polyworks', 'Units', 'normalized', ...
        'FontSize', 7, 'FontName', 'Arial', 'VerticalAlignment', 'middle');

    % Draw Diagram Geometry
    xc_norm = iconX_center; 
    
    % Dimensions
    boxH_norm = 0.04;   
    whiskH_norm = 0.09; 
    boxW_norm = 0.025;   
    outlier_gap = 0.03; 
    
    % Convert to data coords
    wx          = n2d(xc_norm, xLim, xLog);
    yBoxTop     = n2d(yc_norm + boxH_norm, yLim, yLog);    
    yBoxBottom  = n2d(yc_norm - boxH_norm, yLim, yLog);    
    yWhiskTop   = n2d(yc_norm + whiskH_norm, yLim, yLog);  
    yWhiskBott  = n2d(yc_norm - whiskH_norm, yLim, yLog);  

    % Whiskers
    plot(ax, [wx wx], [yBoxTop yWhiskTop], 'k-', 'LineWidth', 1);
    plot(ax, [wx wx], [yWhiskBott yBoxBottom], 'k-', 'LineWidth', 1);
    
    % Box
    bx1 = n2d(xc_norm - boxW_norm, xLim, xLog);
    bx2 = n2d(xc_norm + boxW_norm, xLim, xLog);
    plot(ax, [bx1 bx2 bx2 bx1 bx1], [yBoxBottom yBoxBottom yBoxTop yBoxTop yBoxBottom], ...
         'k-', 'LineWidth', 1);

    % Median Line
    my = n2d(yc_norm, yLim, yLog);
    plot(ax, [bx1 bx2], [my my], 'k-', 'LineWidth', 1);
    
    % Caps
    capW_norm = boxW_norm * 0.6; 
    cx1 = n2d(xc_norm - capW_norm, xLim, xLog);
    cx2 = n2d(xc_norm + capW_norm, xLim, xLog);
    plot(ax, [cx1 cx2], [yWhiskTop yWhiskTop], 'k-', 'LineWidth', 1);
    plot(ax, [cx1 cx2], [yWhiskBott yWhiskBott], 'k-', 'LineWidth', 1);

    % Outliers (Circle & Square)
    oy = n2d(yc_norm + whiskH_norm + outlier_gap, yLim, yLog);
    wx_circle = n2d(xc_norm - 0.015, xLim, xLog); 
    wx_square = n2d(xc_norm + 0.015, xLim, xLog);
    plot(ax, wx_circle, oy, 'ko', 'MarkerSize', 3, 'LineWidth', 1); 
    plot(ax, wx_square, oy, 'ks', 'MarkerSize', 3, 'LineWidth', 1); 

    % Labels
    fSz = 6; 
    txtCol = 'k';
    
    % Outlier
    text(ax, textX, yc_norm + whiskH_norm + outlier_gap, '\leftarrow Outlier', ...
        'Units', 'normalized', 'FontSize', fSz, 'Color', txtCol, 'VerticalAlignment', 'middle');

    % Top Whisker
    text(ax, textX, yc_norm + whiskH_norm, '\leftarrow Q3 + 1.5*IQR', ...
        'Units', 'normalized', 'FontSize', fSz, 'Color', txtCol, 'VerticalAlignment', 'middle');

    % Q3
    text(ax, textX, yc_norm + boxH_norm, '\leftarrow 75^{th} Percentile (Q3)', ...
        'Units', 'normalized', 'FontSize', fSz, 'Color', txtCol, 'VerticalAlignment', 'middle');

    % Median
    text(ax, textX, yc_norm, '\leftarrow Median', ...
        'Units', 'normalized', 'FontSize', fSz, 'Color', txtCol, 'VerticalAlignment', 'middle');

    % Q1
    text(ax, textX, yc_norm - boxH_norm, '\leftarrow 25^{th} Percentile (Q1)', ...
        'Units', 'normalized', 'FontSize', fSz, 'Color', txtCol, 'VerticalAlignment', 'middle');
        
    % Bottom Whisker
    text(ax, textX, yc_norm - whiskH_norm, '\leftarrow Q1 - 1.5*IQR', ...
        'Units', 'normalized', 'FontSize', fSz, 'Color', txtCol, 'VerticalAlignment', 'middle');
end




