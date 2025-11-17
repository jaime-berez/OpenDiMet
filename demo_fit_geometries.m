% DEMO_FIT_GEOMETRIES
% Demo script to fit and plot Line / Plane / Circle /
% Sphere / Cylinder / Cone from a chosen data file using OOP classes.
%
% Workflow:
%   1) Choose data folder
%   2) Choose geometry
%   4) Choose a point file
%   5) Load --> Fit --> Plot -->  Report

clc; close all;

% ---- 1) Choose data folder ----
defaultRoot = "G:\Shared drives\research-BerezLab-GroupDrive\ResearchProjects\OpenDiMet\Test Data";
dataRoot = uigetdir(defaultRoot, 'Select the folder that contains point files'); % If cancel button 
% is pressed then MATLAB returns 0

% If cancel button is pressed display a canceled message and return
 if isequal(dataRoot, 0) 
    disp('Selection Canceled.'); 
    return;
end
dataRoot = string(dataRoot); % Change char to string

% ---- 2) Choose geometry ----
geometries = ["Line","Plane","Circle","Sphere","Cylinder","Cone"]; % Selection of geometries to fit
gIdx = menu('Select a geometry to fit:', geometries); % Opens a pop-up dialog box which returns the index
% of the chosen geometry.
% If nothing is chosen, MATLAB returns 0 and display a cancel message
if gIdx < 1 
    disp('Selection Canceled.'); 
    return; 
end
geomName = geometries(gIdx); % extract the exact geometry name from the array

% ---- 3) Choose Association Criteria
associations = string(enumeration('AssociationCriteria')); % Enumearation of the association criteria
aIdx = menu('Select an association criterion:', associations); % Opens a pop-up dialog box which returns
% the index of the chosen association criterion.
% If nothing is chosen, MATLAB returns 0 and displays a cancel message.
if aIdx < 1
    disp('Selection Canceled.');
    return;
end
assoc = associations(aIdx); % Extract the selected association criterion

% ---- 4) Choose the data file ----

% Open a pop-up to choose the data file for the selected geometry
[fname, fpath] = uigetfile({'*.txt','Text files (*.txt)'}, ...
    sprintf('Choose point file for %s', geomName), dataRoot);

% If nothing is chosen, display a cancel message and return
if isequal(fname, 0)
    disp('Selection Canceled.'); 
    return; 
end

% Store the full path including the filename
filePath = string(fullfile(fpath, fname));

% ---- 5) Load data ----

% Using MATLAB's error handling structure --> try ... catch ... end
try
    data = readmatrix(filePath);
    validateData(data);

    % If either readmatrix or validateData fails, using MATLAB
    % exception ME object to show a message and return
catch ME
    fprintf(2, 'Error reading data file: %s\n', ME.message); % 2 - print to the standard
%  error output (red text)
    return;
end

% ---- 6) Fit the selected geometry ----

% Using MATLAB's error handling structure --> try ... catch ... end
try
    %tic;
    obj = constructFeature(geomName, data, assoc);
    %t_fit = toc;
catch ME
    fprintf(2, 'Error during fitting %s: %s\n', geomName, ME.message); % 2 - print to the standard 
% error output (red text)
    return;
end

% ---- 7) Plot ----

% Using MATLAB's error handling structure --> try ... catch ... end
try
    figure('Name', sprintf('%s Fit: %s', geomName, fname), 'NumberTitle', 'off'); % set the custom name 
    % for figure
    obj.plot([1 0 0], 'Raw Data', [0.4940 0.1840 0.5560], 'Fitted Geometry');
    drawnow;
catch ME
    fprintf(2, 'Plotting error: %s\n', ME.message); % 2 - print to the standard 
% error output (red text)
end

% ---- 8) Report fitted parameters by displaying the object overdrive function output ----
try
    disp(obj);
catch ME
    fprintf(2, 'Display Error: %s\n', ME.message);
end

% Helpers
function validateData(data)
    if ~isnumeric(data) || size(data,2) ~= 3
        error('Data must be numeric with size N x 3 (XYZ points). Got %s.', mat2str(size(data)));
    end
    if any(~isfinite(data), 'all')
        error('Data contains NaN/Inf.');
    end
end

function obj = constructFeature(geomName, data, assoc)
    % Construct the correct feature object.
    switch geomName
        case "Line"
            obj = Line("Line", data, assoc);
        case "Plane"
            obj = Plane("Plane", data, assoc);
        case "Circle"
            obj = Circle("Circle", data, assoc);
        case "Sphere"
            obj = Sphere("Sphere", data, assoc);
        case "Cylinder"
            obj = Cylinder("Cylinder", data, assoc);
        case "Cone"
            obj = Cone("Cone", data, assoc);
        otherwise
            error('Unsupported geometry: %s', geomName);
    end
end
