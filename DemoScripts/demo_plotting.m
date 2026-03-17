%DEMOPLOTTING

clc; close all; clear;

%% Define data directory

demoScriptDirectory = fileparts(matlab.desktop.editor.getActiveFilename);
repoRoot = fileparts(demoScriptDirectory);
dataRoot = fullfile(repoRoot, "Data", "nist-l2-reference-pairs");

%% Scenario 1: Single Line

dataFolder = "Line3D";       % <----- Input

% Define files with raw coordinate data to import
file = "lin1.ds";   % <----- Input
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