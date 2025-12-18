%% Demonstration script for evaluating the association error of the association algorithm
% This script performs association on all the NIST reference datasets,
% reports the associated parameters, and reports the association error of
% each parameter.
clear; clc; close all;
begin=tic; %start a timer to track how long the entire script takes to process

%% Choose the geometry and select the appropriate file path
geometry=input('Enter\n1 for 2D Line,\n2 for 3D Line,\n3 for Plane,\n4 for 2D Circle,\n5 for 3D Circle,\n6 for Sphere,\n7 for Cylinder, or\n8 for Cone\n');
%Flags to enable comparison of the corresponding parameters
doAlpha = false;    %If TRUE, orientations will be compared
doDelta = false;    %If TRUE, size will be compared
doPsi = false;      %If TRUE, angle will be compared
switch geometry
    case 1 % 2D line
        filePath = "Data\nist-l2-reference-pairs\Line2d\lin2d";
        doAlpha = true;
    case 2 % 3D line
        filePath = "Data\nist-l2-reference-pairs\Line3d\lin";
        doAlpha = true;
    case 3 % Plane
        filePath = "Data\nist-l2-reference-pairs\Plane\pla";
        doAlpha = true;
    case 4 % 2D Circle
        filePath = "Data\nist-l2-reference-pairs\Circle2d\cir2d";
        doAlpha = true; doDelta = true;
    case 5 % 3D Circle
        filePath = "Data\nist-l2-reference-pairs\Circle3d\cir";
        doAlpha = true; doDelta = true;
    case 6 % Sphere
        filePath = "Data\nist-l2-reference-pairs\Sphere\sph";
        doDelta = true;
    case 7 % Cylinder
        filePath = "Data\nist-l2-reference-pairs\Cylinder\cyl";
        doAlpha = true; doDelta = true;
    case 8 % Cone
        filePath = "Data\nist-l2-reference-pairs\Cone\con";
        doAlpha = true; doDelta = true; doPsi = true;
    otherwise
        error('Invalid Input')
end

%% Create matrices for storing the association errors
numOfFiles = 30; %30 datasets per geometry
dataNumber = (1:30)'; %Vector of numbers 1 through 30
epsilon = zeros(numOfFiles,1);             %vector to store the location error
if doAlpha == true;  alpha = epsilon;  end %vector to store the orientation error
if doDelta == true;  delta = epsilon;  end %vector to store the size error
if doPsi == true;    psi = epsilon;    end %vector to store the angle error
compTime = epsilon;                        %vector to store the computation time

%% Loop through each dataset
% First, the data and reference files are opened.
% Second, association is performed.
% Third, the errors are computed.
for i=1:numOfFiles %Loop through all the files
    fprintf('*** Dataset %-2i/30 ***\n',i) %print the progress
    
    %% Perform association on the choosen geometry for the i'th dataset
    switch geometry
        case 1 % 2d Line
            data=readmatrix(filePath+string(i)+".ds",'FileType','text');
            reference=readmatrix(filePath+string(i)+".fit",'FileType','text');
            t0=tic; %Start a timer to track the association time
            Line=fitFeature(data,"Line","LeastSquares", "line"); % Associate 2d Line
            t1=toc(t0); %End the timer
            poi=Line.point;
            dir=Line.direction;
        case 2 % 3d Line
            data=readmatrix(filePath+string(i)+".ds",'FileType','text');
            reference=readmatrix(filePath+string(i)+".fit",'FileType','text');
            t0=tic; %Start a timer to track the association time
            Line=fitFeature(data,"Line","LeastSquares", "line"); % Associate 23d Line
            t1=toc(t0); %End the timer
            poi=Line.point;
            dir=Line.direction;
        case 3 % Plane
            data=readmatrix(filePath+string(i)+".ds",'FileType','text');
            reference=readmatrix(filePath+string(i)+".fit",'FileType','text');
            t0=tic; %Start a timer to track the association time
            Plane=fitFeature(data,"Plane","LeastSquares", "plane"); % Associate Plane
            t1=toc(t0); %End the timer
            poi=Plane.point;
            dir=Plane.direction;
        case 4 % 2d Circle
            data=readmatrix(filePath+string(i)+".ds",'FileType','text');
            reference=readmatrix(filePath+string(i)+".fit",'FileType','text');
            t0=tic; %Start a timer to track the association time
            Circle=fitFeature(data,"Circle","LeastSquares", "circle"); % Associate 2d Circle
            t1=toc(t0); %End the timer
            poi=Circle.point;
            dir=Circle.direction;
            dis=Circle.diameter;
        case 5 % 3d circle
            data=readmatrix(filePath+string(i)+".ds",'FileType','text');
            reference=readmatrix(filePath+string(i)+".fit",'FileType','text');
            t0=tic; %Start a timer to track the association time
            Circle=fitFeature(data,"Circle","LeastSquares", "circle"); % Associate 3d Circle
            t1=toc(t0); %End the timer
            poi=Circle.point;
            dir=Circle.direction;
            dis=Circle.diameter;
        case 6 % Sphere
            data=readmatrix(filePath+string(i)+".ds",'FileType','text');
            reference=readmatrix(filePath+string(i)+".fit",'FileType','text');
            t0=tic; %Start a timer to track the association time
            Sphere=fitFeature(data,"Sphere","LeastSquares", "sphere"); % Associate Sphere
            t1=toc(t0); %End the timer
            poi=Sphere.point;
            dis=Sphere.diameter;
        case 7 % Cylinder
            data=readmatrix(filePath+string(i)+".ds",'FileType','text');
            reference=readmatrix(filePath+string(i)+".fit",'FileType','text');
            t0=tic; %Start a timer to track the association time
            Cylinder=fitFeature(data,"Cylinder","LeastSquares", "cylinder"); % Associate Cylinder
            t1=toc(t0); %End the timer
            poi=Cylinder.point;
            dir=Cylinder.direction;
            dis=Cylinder.diameter;
        case 8 % Cone
            data=readmatrix(filePath+string(i)+".ds",'FileType','text');
            reference=readmatrix(filePath+string(i)+".fit",'FileType','text');
            t0=tic; %Start a timer to track the association time
            Cone=fitFeature(data,"Cone","LeastSquares", "cone"); % Associate Cone
            t1=toc(t0); %End the timer
            poi=Cone.point;
            dir=Cone.direction;
            dis=Cone.distance;
            ang=Cone.angle;
    end

    %% Compute the association error
    % Comparisons based on methods in ISO 10360-6:2001
    switch geometry
        case 1 %2d Line
            poiDiff=norm(poi-reference(1:3)');
            dirDiff=2*asin(norm(dir-reference(4:6)')/2);
            if round(dirDiff,2)==round(pi,2) %check if the error is a multiple of pi
                dirDiff=2*asin(norm(-dir-reference(4:6)')/2);
            end
        case 2 %3d Line
            poiDiff=norm(poi-reference(1:3)');
            dirDiff=2*asin(norm(dir-reference(4:6)')/2);
            if round(dirDiff,2)==round(pi,2) %check if the error is a multiple of pi
                dirDiff=2*asin(norm(-dir-reference(4:6)')/2);
            end
        case 3 %Plane
            poiDiff=norm(poi-reference(1:3)');
            dirDiff=2*asin(norm(dir-reference(4:6)')/2);
            if round(dirDiff,2)==round(pi,2) %check if the error is a multiple of pi
                dirDiff=2*asin(norm(-dir-reference(4:6)')/2);
            end
        case 4 %2d Circle
            poiDiff=norm(poi-reference(1:3)');
            dirDiff=2*asin(norm(dir-reference(4:6)')/2);
            if round(dirDiff,2)==round(pi,2) %check if the error is a multiple of pi
                dirDiff=2*asin(norm(-dir-reference(4:6)')/2);
            end
            disDiff=norm(dis-reference(7));
        case 5 %3d Circle
            poiDiff=norm(poi-reference(1:3)');
            dirDiff=2*asin(norm(dir-reference(4:6)')/2);
            if round(dirDiff,2)==round(pi,2) %check if the error is a multiple of pi
                dirDiff=2*asin(norm(-dir-reference(4:6)')/2);
            end
            disDiff=norm(dis-reference(7));
        case 6 %Sphere
            poiDiff=norm(poi-reference(1:3)');
            disDiff=norm(dis-reference(4));
        case 7 %Cylinder
            projPoi=pp2l(poi,mean(data),dir); %project the point onto the axis, closest to the centroid
            poiDiff=norm(projPoi-reference(1:3)');
            dirDiff=2*asin(norm(dir-reference(4:6)')/2);
            if round(dirDiff,2)==round(pi,2) %check if the error is a multiple of pi
                dirDiff=2*asin(norm(-dir-reference(4:6)')/2);
            end
            disDiff=norm(dis-reference(7));
        case 8 %Cone
            projPoi=pp2l(poi,mean(data),dir); %project the point onto the axis, closest to the centroid
            poiDiff=norm(projPoi-reference(1:3)');
            dirDiff=2*asin(norm(dir-reference(4:6)')/2);
            if round(dirDiff,2)==round(pi,2) %check if the error is a multiple of pi
                dirDiff=2*asin(norm(-dir-reference(4:6)')/2);
            end
            disDiff=norm(dis-reference(7));
            angDiff=mod((abs(ang-reference(7))),pi/2);
    end

    %% Save the errors before proceeding to the next dataset
    epsilon(i,1)=poiDiff;
    if doAlpha==true;   alpha(i,1)=dirDiff; end
    if doDelta==true;   delta(i,1)=disDiff; end
    if doPsi==true;     psi(i,1)=angDiff;   end
    compTime(i,1)=t1;
end %end of the for-loop

%% Statistics
epsilon_max = max(epsilon);
epsilon_min = min(epsilon);
epsilon_avg = mean(epsilon);
epsilon_med = median(epsilon);
epsilon_std = std(epsilon);

if doAlpha == true
    alpha_max = max(alpha);
    alpha_min = min(alpha);
    alpha_avg = mean(alpha);
    alpha_med = median(alpha);
    alpha_std = std(alpha);
end

if doDelta==true
    delta_min = min(delta);
    delta_max = max(delta);
    delta_avg = mean(delta);
    delta_med = median(delta);
    delta_std = std(delta);
end

if doPsi == true
    psi_max = max(psi);
    psi_min = min(psi);
    psi_avg = mean(psi);
    psi_med = median(psi);
    psi_std = std(psi);
end

compTime_max = max(compTime);
compTime_min = min(compTime);
compTime_avg = mean(compTime);
compTime_med = median(compTime);
compTime_std = std(compTime);

fprintf("=== EPSILON ===\navg: %-10.6f\tmin: %-10.6f\tmax: %-10.6f\tmed: %-10.6f\tstd: %-10.6f\n\n",epsilon_avg,epsilon_min,epsilon_max,epsilon_med,epsilon_std);
if doDelta==true
    fprintf("=== DELTA ===\navg: %-10.6f\tmin: %-10.6f\tmax: %-10.6f\tmed: %-10.6f\tstd: %-10.6f\n\n",delta_avg,delta_min,delta_max,delta_med,delta_std);
end
if doAlpha==true
    fprintf("=== ALPHA === (radians)\navg: %-10.6f\tmin: %-10.6f\tmax: %-10.6f\tmed: %-10.6f\tstd: %-10.6f\n\n",alpha_avg,alpha_min,alpha_max,alpha_med,alpha_std);
end
if doPsi==true
    fprintf("=== PSI === (radians)\navg: %-10.6f\tmin: %-10.6f\tmax: %-10.6f\tmed: %-10.6f\tstd: %-10.6f\n\n",psi_avg,psi_min,psi_max,psi_med,psi_std);
end
fprintf("=== Computation time === (seconds)\navg: %-10.6f\tmin: %-10.6f\tmax: %-10.6f\tmed: %-10.6f\tstd: %-10.6f\n\n",epsilon_avg,epsilon_min,epsilon_max,epsilon_med,epsilon_std);

%% Create a boxplot to visualize the data
figure();
switch geometry
    case 1
        t=tiledlayout(1,3,'TileSpacing','compact','Padding','tight');
        t.Title.String="Line 2D error and computation time";
        nexttile;
            boxplot(epsilon,'Labels','Location')
            set(gca, 'YScale', 'Log'); grid on;
            title("Location Error"); ylabel('Error (length)');
        nexttile;
            boxplot(alpha,'Labels','Orientation')
            set(gca, 'YScale', 'Log'); grid on;
            title("Orientation Error"); ylabel('Error (radians)');
        nexttile;
            boxplot(compTime,'Labels','Computation time')
            set(gca, 'YScale', 'Log'); grid on;
            title("Computation Time"); ylabel('Time (Seconds)');
    case 2
        t=tiledlayout(1,3,'TileSpacing','compact','Padding','tight');
        t.Title.String="Line 3D error and computation time";
        nexttile;
            boxplot(epsilon,'Labels','Location')
            set(gca, 'YScale', 'Log'); grid on;
            title("Location Error"); ylabel('Error (length)');
        nexttile;
            boxplot(alpha,'Labels','Orientation')
            set(gca, 'YScale', 'Log'); grid on;
            title("Orientation Error"); ylabel('Error (radians)');
        nexttile;
            boxplot(compTime,'Labels','Computation Time')
            set(gca, 'YScale', 'Log'); grid on;
            title("Computation Time"); ylabel('Time (Seconds)');
    case 3
        t=tiledlayout(1,3,'TileSpacing','compact','Padding','tight');
        t.Title.String="Plane error and computation time";
        nexttile;
            boxplot(epsilon,'Labels','Location')
            set(gca, 'YScale', 'Log'); grid on;
            title("Location Error"); ylabel('Error (length)');
        nexttile;
            boxplot(alpha,'Labels','Orientation')
            set(gca, 'YScale', 'Log'); grid on;
            title("Orientation Error"); ylabel('Error (radians)');
        nexttile;
            boxplot(compTime,'Labels','Computation Time')
            set(gca, 'YScale', 'Log'); grid on;
            title("Computation Time"); ylabel('Time (Seconds)');
    case 4
        t=tiledlayout(1,3,'TileSpacing','compact','Padding','tight');
        t.Title.String="Circle 2D error and computation time";
        nexttile;
            boxplot([epsilon,delta],'Labels',["Location","Size"])
            set(gca, 'YScale', 'Log'); grid on;
            title("Location and Size Error"); ylabel('Error (length)');
        nexttile;
            boxplot(alpha,'Labels','Orientation')
            set(gca, 'YScale', 'Log'); grid on;
            title("Orientation Error"); ylabel('Error (radians)');
        nexttile;
            boxplot(compTime,'Labels','Computation Time')
            set(gca, 'YScale', 'Log'); grid on;
            title("Computation Time"); ylabel('Time (Seconds)');
    case 5
        t=tiledlayout(1,3,'TileSpacing','compact','Padding','tight');
        t.Title.String="Circle 3D error and computation time";
        nexttile;
            boxplot([epsilon,delta],'Labels',["Location","Size"])
            set(gca, 'YScale', 'Log'); grid on;
            title("Location and Size Error"); ylabel('Error (length)');
        nexttile;
            boxplot(alpha,'Labels','Orientation')
            set(gca, 'YScale', 'Log'); grid on;
            title("Orientation Error"); ylabel('Error (radians)');
        nexttile;
            boxplot(compTime,'Labels','Computation Time')
            set(gca, 'YScale', 'Log'); grid on;
            title("Computation Time"); ylabel('Time (Seconds)');
    case 6
        t=tiledlayout(1,2,'TileSpacing','compact','Padding','tight');
        t.Title.String="Sphere error and computation time";
        nexttile;
            boxplot([epsilon,delta],'Labels',["Location","Size"])
            set(gca, 'YScale', 'Log'); grid on;
            title("Location and Size Error"); ylabel('Error (length)');
        nexttile;
            boxplot(compTime,'Labels','Computation Time')
            set(gca, 'YScale', 'Log'); grid on;
            title("Computation Time"); ylabel('Time (Seconds)');
    case 7
        t=tiledlayout(1,3,'TileSpacing','compact','Padding','tight');
        t.Title.String="Cylinder error and computation time";
        nexttile;
            boxplot([epsilon,delta],'Labels',["Location","Size"])
            set(gca, 'YScale', 'Log'); grid on;
            title("Location and Size Error"); ylabel('Error (length)');
        nexttile;
            boxplot(alpha,'Labels','Orientation')
            set(gca, 'YScale', 'Log'); grid on;
            title("Orientation Error"); ylabel('Error (radians)');
        nexttile;
            boxplot(compTime,'Labels','Computation Time')
            set(gca, 'YScale', 'Log'); grid on;
            title("Computation Time"); ylabel('Time (Seconds)');
    case 8
        t=tiledlayout(1,3,'TileSpacing','compact','Padding','tight');
        t.Title.String="Cone error and computation time";
        nexttile;
            boxplot([epsilon,delta],'Labels',["Location","Size"])
            set(gca, 'YScale', 'Log'); grid on;
            title("Location and Size Error"); ylabel('Error (length)');
        nexttile;
            boxplot([alpha,psi],'Labels',["Orientation","Angle"])
            set(gca, 'YScale', 'Log'); grid on;
            title("Orientation and Semi-Angle Error"); ylabel('Error (radians)');
        nexttile;
            boxplot(compTime,'Labels','Computation Time')
            set(gca, 'YScale', 'Log'); grid on;
            title("Computation Time"); ylabel('Time (Seconds)');
end