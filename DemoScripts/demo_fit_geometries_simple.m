% DEMO_FIT_GEOMETRIES_SIMPLE
% Simplified demo for fitting and plotting one of:
% Line / Plane / Circle / Sphere / Cylinder / Cone
%
% Hard-coded workflow:
%   1) Define folder path containing coordinate data sets
%   2) Define file name for a single coordinate data set representing a
%   single feature (line, plane, circle, cylinder, sphere, or cone)
%   3) Optionally, define a desired name for the feature
%   4) Load data, fit, plot, and display object

clc; close all; clear;


%% ---- User Input ----

%Define directory for data
demoScriptDirectory = fileparts(mfilename('fullpath'));
repoRoot = fileparts(demoScriptDirectory);
dataFolder = "Line3D";       % <----- Input
rootDirectory = fullfile(repoRoot, "Data", "nist-l2-reference-pairs", dataFolder);

% Define files with raw coordinate data to import
file = "lin27.ds";   % <----- Input

%% ---- Load data ----

data1 = readmatrix(fullfile(rootDirectory,file), FileType = "text");

%% ---- Option 1: Fit the selected geometry using loaded data ----

myFeature = fitFeature(data1, "Line", "LeastSquares", "Name", StepTol = 1e-9, ...
    GradTol = 1e-11, SSETol = 1e-19, Lambda = 1e-4, DampingCoeff = 2, materialSide = "Internal");  % <----- Input

%% ---- Option 2: Fit the selected geometry using the file path ----

% path = fullfile(rootDirectory, file);

% myFeature = fitFeature(path, "Plane", "LeastSquares", "pla28", MaxIter = 5000, StepTOl = 1e-9, ...
%     GradTol = 1e-11, SSETol = 1e-19, Lambda = 1e-4, DampingCoeff = 2);
    
%% ---- Report fitted parameters, plot result----
disp(myFeature);

% Style 1: No input arguments
figure();
myFeature.plot(); % Colors, labels, etc. all set by default

% Style 2: string color names
figure();
myFeature.plot(dataColor = "green", dataLabel = "my data", ...
            fitColor = "red", fitLabel = "my fit", centerLineStyle = "dashed");

% Style 3: [R G B] and [hex]
figure();
myFeature.plot(dataColor = "#ff8800", dataLabel = "my data", ...
            fitColor = [0 0.5 1], fitLabel = "my fit", centerLineStyle = "dashdot");