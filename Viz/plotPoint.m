function plotPoint(pnt)
    % PLOTPOINT Plot a single point in 3D space.
    %
    %   Syntax
    %     plotPoint(pnt)
    %
    %   Description
    %     Plots a single 3D point using a black 'x' marker. The function is a
    %     lightweight helper for visualizing feature points such as centroids,
    %     apex points, or reference locations in geometric plots.
    %
    %   Input Arguments
    %     pnt
    %         1x3 double
    %         Coordinates of the point to be plotted.
    %
    %   Output
    %     This function produces a 3D plot marker at the specified location.
    %
    %   Example
    %     p = [1 2 3];
    %     plotPoint(p);
    plot3(pnt(1),pnt(2),pnt(3),'kx');
end