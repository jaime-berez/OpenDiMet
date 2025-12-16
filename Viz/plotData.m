function plotData(data,markerColor,icon,size)
    arguments
        data (:,3) double %this is an nx3 matrix of columns representing x,y,z values
        markerColor (:,3) double = [0 0.4470 0.7410] %this is a 3xn matrix representing colors of each point
        icon (1,:) string = "." %string for the marker for each point
        size (1,:) {mustBeNumeric} = 36 %size (points squared) for each marker. Can be a matrix
    end

    % Plot the data points using a scatterplot
    s = scatter3(data(:,1),data(:,2),data(:,3),size,markerColor);
    s.Marker=icon; %set the marker shapes
    axis equal; axis padded; grid on;
end