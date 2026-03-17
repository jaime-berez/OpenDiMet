%DEMOPLOTTING

clc; close all; clear;

%% Define data directory

demoScriptDirectory = fileparts(matlab.desktop.editor.getActiveFilename);
repoRoot = fileparts(demoScriptDirectory);
dataRoot = fullfile(repoRoot, "Data", "nist-l2-reference-pairs");

%% Scenario 1: Single Line

dataFolder = "Line3D";       % <----- Input

% Define files with raw coordinate data to import
file = "lin2.ds";   % <----- Input
rootDirectory = fullfile(dataRoot, dataFolder);
fullPath = fullfile(rootDirectory, file);

% Load data
data = readmatrix(fullPath, FileType = "text");

% Fit the selected geometry using loaded data 
myFeature = fitFeature(data, "Line", "LeastSquares", "sampleLine", StepTol = 1e-9, ...
    GradTol = 1e-11, SSETol = 1e-19, Lambda = 1e-4, DampingCoeff = 2);  % <----- Input

% Style 1: No input arguments
figure();
myFeature.plot(); % Colors, labels, etc. all set by default

% Style 2: string color names and default opts
figure();
myFeature.plot(dataColor = "green", dataLabel = "my data", dataMarker = '.', dataMarkerSize = 4,...
            fitColor = "red", fitLabel = "my fit", lineStyle = "--", lineWidth = 2);

% Style 3: [R G B] and [hex] color code and changed opts
figure();
myFeature.plot(dataColor = "#ff8800", dataLabel = "Data", dataMarker = '*', dataMarkerSize = 2,...
            fitColor = [0 0.5 1], fitLabel = "Fit", lineStyle = "-.", lineWidth = 4);

%% Scenario 2: Single Plane

dataFolder = "Plane";       % <----- Input

% Define files with raw coordinate data to import
file = "pla11.ds";   % <----- Input
rootDirectory = fullfile(dataRoot, dataFolder);
fullPath = fullfile(rootDirectory, file);

% Load data
data = readmatrix(fullPath, FileType = "text");

% Fit the selected geometry using loaded data 
myFeature = fitFeature(data, "Plane", "LeastSquares", "samplePlane", StepTol = 1e-9, ...
    GradTol = 1e-11, SSETol = 1e-19, Lambda = 1e-4, DampingCoeff = 2);  % <----- Input

% Style 1: No input arguments
figure();
myFeature.plot(); % Colors, labels, etc. all set by default

% Style 2: string color names and changed opts
figure();
myFeature.plot(dataColor = "green", dataLabel = "my data", dataMarker = '.', dataMarkerSize = 4,...
            fitColor = "red", fitLabel = "my fit", fitFaceAlpha = 0.4, fitEdgeColor = 'k');

% Style 3: [R G B] and [hex] color code and changed opts
figure();
myFeature.plot(dataColor = "#ff8800", dataLabel = "Data", dataMarker = '*', dataMarkerSize = 2,...
            fitColor = [0 0.5 1], fitLabel = "Fit", fitFaceAlpha = 0.4, fitEdgeColor = 'none');

%% Scenario 3: Single Circle

dataFolder = "Circle3D";       % <----- Input

% Define files with raw coordinate data to import
file = "cir1.ds";   % <----- Input
rootDirectory = fullfile(dataRoot, dataFolder);
fullPath = fullfile(rootDirectory, file);

% Load data
data = readmatrix(fullPath, FileType = "text");

% Fit the selected geometry using loaded data 
myFeature = fitFeature(data, "Circle", "LeastSquares", "sampleCircle", StepTol = 1e-9, ...
    GradTol = 1e-11, SSETol = 1e-19, Lambda = 1e-4, DampingCoeff = 2);  % <----- Input

% Style 1: No input arguments
figure();
myFeature.plot(); % Colors, labels, etc. all set by default

% Style 2: string color names and changed opts
figure();
myFeature.plot(dataColor = "green", dataLabel = "my data", dataMarker = '.', dataMarkerSize = 4,...
            fitColor = "red", fitLabel = "my fit", lineStyle = "--", lineWidth = 2);

% Style 3: [R G B] and [hex] color code and changed opts
figure();
myFeature.plot(dataColor = "#ff8800", dataLabel = "Data", dataMarker = '*', dataMarkerSize = 2,...
            fitColor = [0 0.5 1], fitLabel = "Fit", lineStyle = "-.", lineWidth = 4);

%% Scenario 4: Single Cylinder

dataFolder = "Cylinder";       % <----- Input

% Define files with raw coordinate data to import
file = "cyl2.ds";   % <----- Input
rootDirectory = fullfile(dataRoot, dataFolder);
fullPath = fullfile(rootDirectory, file);

% Load data
data = readmatrix(fullPath, FileType = "text");

% Fit the selected geometry using loaded data 
myFeature = fitFeature(data, "Cylinder", "LeastSquares", "sampleCylinder", StepTol = 1e-9, ...
    GradTol = 1e-11, SSETol = 1e-19, Lambda = 1e-4, DampingCoeff = 2);  % <----- Input

% Style 1: No input arguments
figure();
myFeature.plot(); % Colors, labels, etc. all set by default

% Style 2: string color names and changed opts
figure();
myFeature.plot(dataColor = "green", dataLabel = "my data", dataMarker = '.', dataMarkerSize = 4,...
            fitColor = "red", fitLabel = "my fit", fitFaceAlpha = 0.1, ......
            axisLineStyle = "--", axisLineWidth = 1, nFaces = 30);

% Style 3: [R G B] and [hex] color code and changed opts
figure();
myFeature.plot(dataColor = "#ff8800", dataLabel = "Data", dataMarker = '*', dataMarkerSize = 2,...
            fitColor = [0 0.5 1], fitLabel = "Fit", fitFaceAlpha = 0.7, ...
            axisLineStyle = "-.", axisLineWidth = 2, nFaces = 10);

%% Scenario 5: Single Sphere

dataFolder = "Sphere";       % <----- Input

% Define files with raw coordinate data to import
file = "sph2.ds";   % <----- Input
rootDirectory = fullfile(dataRoot, dataFolder);
fullPath = fullfile(rootDirectory, file);

% Load data
data = readmatrix(fullPath, FileType = "text");

% Fit the selected geometry using loaded data 
myFeature = fitFeature(data, "Sphere", "LeastSquares", "sampleSphere", StepTol = 1e-9, ...
    GradTol = 1e-11, SSETol = 1e-19, Lambda = 1e-4, DampingCoeff = 2);  % <----- Input

% Style 1: No input arguments
figure();
myFeature.plot(); % Colors, labels, etc. all set by default

% Style 2: string color names and changed opts
figure();
myFeature.plot(dataColor = "blue", dataLabel = "my data", dataMarker = '.', dataMarkerSize = 10,...
            fitColor = "red", fitLabel = "my fit", fitFaceAlpha = 0.1, fitEdgeColor = 'k', ......
            nFaces = 30);

% Style 3: [R G B] and [hex] color code and changed opts
figure();
myFeature.plot(dataColor = "#ff8800", dataLabel = "Data", dataMarker = '*', dataMarkerSize = 2,...
            fitColor = [0 0.5 1], fitLabel = "Fit", fitFaceAlpha = 0.7, fitEdgeColor = 'k',...
            nFaces = 100);

%% Scenario 6: Single Cone

dataFolder = "Cone";       % <----- Input

% Define files with raw coordinate data to import
file = "con3.ds";   % <----- Input
rootDirectory = fullfile(dataRoot, dataFolder);
fullPath = fullfile(rootDirectory, file);

% Load data
data = readmatrix(fullPath, FileType = "text");

% Fit the selected geometry using loaded data 
myFeature = fitFeature(data, "Cone", "LeastSquares", "sampleSphere", StepTol = 1e-9, ...
    GradTol = 1e-11, SSETol = 1e-19, Lambda = 1e-4, DampingCoeff = 2);  % <----- Input

% Style 1: No input arguments
figure();
myFeature.plot(); % Colors, labels, etc. all set by default

% Style 2: string color names and changed opts
figure();
myFeature.plot(dataColor = "blue", dataLabel = "my data", dataMarker = '.', dataMarkerSize = 10,...
            fitColor = "red", fitLabel = "my fit", fitFaceAlpha = 0.1, ......
            axisLineStyle = "--", axisLineWidth = 1, nFaces = 30);

% Style 3: [R G B] and [hex] color code and changed opts
figure();
myFeature.plot(dataColor = "#ff8800", dataLabel = "Data", dataMarker = '*', dataMarkerSize = 2,...
            fitColor = [0 0.5 1], fitLabel = "Fit", fitFaceAlpha = 0.7,...
            axisLineStyle = "-.", axisLineWidth = 2, nFaces = 100);

%% Scenario 7: Two lines

dataFolder = "Line3D";       % <----- Input

% Define files with raw coordinate data to import
file1 = "lin1.ds";   % <----- Input
file2 = "lin2.ds";   % <----- Input
rootDirectory = fullfile(dataRoot, dataFolder);
fullPath1 = fullfile(rootDirectory, file1);
fullPath2 = fullfile(rootDirectory, file2);
% Load data
data1 = readmatrix(fullPath1, FileType = "text");
data2 = readmatrix(fullPath2, FileType = "text");

% Fit the selected geometry using loaded data 
myLine1 = fitFeature(data1, "Line", "LeastSquares", "sampleLine1", StepTol = 1e-9, ...
    GradTol = 1e-11, SSETol = 1e-19, Lambda = 1e-4, DampingCoeff = 2);  % <----- Input
myLine2 = fitFeature(data2, "Line", "LeastSquares", "sampleLine2", StepTol = 1e-9, ...
    GradTol = 1e-11, SSETol = 1e-19, Lambda = 1e-4, DampingCoeff = 2);  % <----- Input

% Style 1: No input arguments
figure;
ax = axes;
hold(ax, 'on');
% Style 2: string color names and default opts
myLine1.plot(ax = ax, dataColor = "green", dataLabel = "Line 1 data", dataMarker = '.', dataMarkerSize = 4,...
            fitColor = "red", fitLabel = "Line 1 fit", lineStyle = "--", lineWidth = 2);

% Style 3: [R G B] and [hex] color code and changed opts
myLine2.plot(ax = ax, dataColor = "#ff8800", dataLabel = "Line 2 data", dataMarker = '*', dataMarkerSize = 2,...
            fitColor = [0 0.5 1], fitLabel = "Line 2 fit", lineStyle = "-.", lineWidth = 2);

%% Scenario 7: Two parallel lines

dataFolder = "Line3D";       % <----- Input

% Define files with raw coordinate data to import
file = "lin2.ds";   % <----- Input
rootDirectory = fullfile(dataRoot, dataFolder);
fullPath = fullfile(rootDirectory, file);

% Load data
data = readmatrix(fullPath, FileType = "text");

% Set offset and translate
offset = [2 0 0];
dataTrans = data + offset;

% Fit the selected geometry using loaded data 
myLine1 = fitFeature(data, "Line", "LeastSquares", "sampleLine1", StepTol = 1e-9, ...
    GradTol = 1e-11, SSETol = 1e-19, Lambda = 1e-4, DampingCoeff = 2);  % <----- Input
myLine2 = fitFeature(dataTrans, "Line", "LeastSquares", "sampleLine2", StepTol = 1e-9, ...
    GradTol = 1e-11, SSETol = 1e-19, Lambda = 1e-4, DampingCoeff = 2);  % <----- Input

% Style 1: No input arguments
figure;
ax = axes;
hold(ax, 'on');
% Style 2: string color names and default opts
myLine1.plot(ax = ax, dataColor = "green", dataLabel = "Line 1 data", dataMarker = '.', dataMarkerSize = 4,...
            fitColor = "red", fitLabel = "Line 1 fit", lineStyle = "--", lineWidth = 2, showTitle = false);

% Style 3: [R G B] and [hex] color code and changed opts
myLine2.plot(ax = ax, dataColor = "#ff8800", dataLabel = "Line 2 data", dataMarker = '*', dataMarkerSize = 2,...
            fitColor = [0 0.5 1], fitLabel = "Line 2 fit", lineStyle = "-.", lineWidth = 2, showTitle = false);

title(ax, "Two line fits (synthetic offset)");

%% Scenario 8: Plane + Line normal to the plane

% Load plane data
dataFolder = "Plane";
file = "pla10.ds";
rootDirectory = fullfile(dataRoot, dataFolder);
fullPath = fullfile(rootDirectory, file);

planeData = readmatrix(fullPath, FileType="text");

% Fit plane
myPlane = fitFeature(planeData, "Plane", "LeastSquares", "samplePlane", ...
    StepTol=1e-9, GradTol=1e-11, SSETol=1e-19, Lambda=1e-4, DampingCoeff=2);

% Build synthetic line data approximately along plane normal
p0 = myPlane.pnt;
n  = myPlane.dir / norm(myPlane.dir);

planeExtent = norm(max(planeData) - min(planeData));

% Line length tied to plane size
L = 0.8 * planeExtent;
t = linspace(-L/2, L/2, 100).';

% Offset line slightly away from plane
lineCenter = p0 + 0.1 * planeExtent * n;
lineData = lineCenter + t .* n;

% Fit line
myLine = fitFeature(lineData, "Line", "LeastSquares", "sampleLine", ...
    StepTol=1e-9, GradTol=1e-11, SSETol=1e-19, Lambda=1e-4, DampingCoeff=2);

% Plot together
figure;
ax = axes;
hold(ax, "on");

myPlane.plot(ax=ax, showTitle=false, ...
    dataColor = "blue", dataLabel = "Plane data", dataMarkerSize = 2, ...
    fitColor = "green", fitLabel = "Plane fit", ...
    fitFaceAlpha=0.25, fitEdgeColor="k");

myLine.plot(ax=ax, showTitle=false, ...
    dataColor=[0.9 0.4 0.1], dataLabel="Line data", ...
    fitColor="red", fitLabel="Line fit", ...
    lineStyle="--", lineWidth=3);

title(ax, "Plane and line normal to the plane");

%% Scenario 9: Two parallel planes

% Load plane data
dataFolder = "Plane";
file = "pla10.ds";
rootDirectory = fullfile(dataRoot, dataFolder);
fullPath = fullfile(rootDirectory, file);

planeData = readmatrix(fullPath, FileType="text");

% Fit plane
myPlane = fitFeature(planeData, "Plane", "LeastSquares", "Plane", ...
    StepTol=1e-9, GradTol=1e-11, SSETol=1e-19, Lambda=1e-4, DampingCoeff=2);

% Create second plane data
n = myPlane.dir / norm(myPlane.dir);
planeExtent = norm(max(planeData) - min(planeData));

offset = 0.1 * planeExtent;

planeDataTrans = planeData + offset * n;

% Fit second plane
myPlaneTrans = fitFeature(planeDataTrans, "Plane", "LeastSquares", "Translated plane", ...
    StepTol=1e-9, GradTol=1e-11, SSETol=1e-19, Lambda=1e-4, DampingCoeff=2);

% Plot
figure;
ax = axes;
hold(ax, "on");

myPlane.plot(ax=ax, showTitle=false, ...
    fitColor="green", fitFaceAlpha=0.3, ...
    dataColor="blue", dataLabel="Plane 1 data", ...
    fitLabel="Plane 1");

myPlaneTrans.plot(ax=ax, showTitle=false, ...
    fitColor=[1 0.6 0.4], fitFaceAlpha=0.3, ...
    dataColor="red", dataLabel="Plane 2 data", ...
    fitLabel="Plane 2");

title(ax, "Two Parallel Planes");