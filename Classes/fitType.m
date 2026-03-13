classdef fitType < int32
    % FITTYPE Enumeration of feature fitting criteria.
    %
    %   Syntax
    %     fitCriterion = fitType.LeastSquares
    %     fitCriterion = fitType.MinimumTotalDistance
    %     fitCriterion = fitType.ConstrainedLeastSquares
    %     fitCriterion = fitType.ConstrainedMinimumTotalDistance
    %     fitCriterion = fitType.MiniMax
    %     fitCriterion = fitType.MinimumCircumscribed
    %     fitCriterion = fitType.MaximumInscribed
    %     fitCriterion = fitType.WeightedLeastSquares
    %
    %   Enumeration Members
    %     LeastSquares - L2 fit that minimizes the sum of squared residuals
    %     MinimumTotalDistance - L1 fit that minimizes the sum of absolute residuals
    %     ConstrainedLeastSquares - One-sided constrained L2 fit using a reference direction
    %     ConstrainedMinimumTotalDistance - One-sided constrained L1 fit using a reference direction
    %     MiniMax - Minimum-zone or Chebyshev fit that minimizes the maximum residual
    %     MinimumCircumscribed - Smallest enclosing associated feature
    %     MaximumInscribed - Largest inscribed associated feature
    %     WeightedLeastSquares - Least-squares fit with weighted data points
    %
    %   Example
    %     fitCriterion = fitType.LeastSquares;

    enumeration
        LeastSquares (1)
        MinimumTotalDistance (2)
        ConstrainedLeastSquares (3)
        ConstrainedMinimumTotalDistance (4)
        MiniMax (5)
        MinimumCircumscribed (6)
        MaximumInscribed (7)
        WeightedLeastSquares (8)
    end

    methods
        function geomList = supportedGeometries(fitCriterion)
            % SUPPORTEDGEOMETRIES Return the geometries supported by a fitting criterion.
            %
            %   Syntax
            %     geomList = supportedGeometries(fitCriterion)
            %
            %   Input Arguments
            %     fitCriterion - Fitting criterion
            %       fitType enumeration
            %
            %   Output Arguments
            %     geomList - Supported geometry names
            %       string array
            %
            %   Example
            %     geomList = fitType.LeastSquares.supportedGeometries();

            switch fitCriterion
                case fitType.LeastSquares
                    geomList = ["Line","Plane","Circle","Sphere","Cylinder","Cone"];
                case fitType.MinimumTotalDistance
                    geomList = ["Line","Plane","Circle","Sphere","Cylinder","Cone"];
                case fitType.ConstrainedLeastSquares
                    geomList = ["Line","Plane"];
                case fitType.ConstrainedMinimumTotalDistance
                    geomList = ["Line","Plane"];
                case fitType.MiniMax
                    geomList = ["Line","Plane","Circle","Sphere","Cylinder","Cone"];
                case fitType.MinimumCircumscribed
                    geomList = ["Circle","Sphere","Cylinder"];
                case fitType.MaximumInscribed
                    geomList = ["Circle","Sphere","Cylinder"];
                case fitType.WeightedLeastSquares
                    geomList = ["Line","Plane","Circle","Sphere","Cylinder","Cone"];
                otherwise
                    geomList = string.empty;
            end
        end
    end

    methods (Static)

        function tf = isImplemented(fitCriterion, geomName)
            % ISIMPLEMENTED Determine whether a fitting criterion is implemented for a geometry.
            %
            %   Syntax
            %     tf = fitType.isImplemented(fitCriterion, geomName)
            %
            %   Input Arguments
            %     fitCriterion - Fitting criterion
            %       fitType enumeration
            %     geomName - Geometry name
            %       string scalar | character vector
            %
            %   Output Arguments
            %     tf - True if the fitting criterion is implemented for the geometry
            %       logical scalar
            %
            %   Example
            %     tf = fitType.isImplemented(fitType.ConstrainedLeastSquares, "Plane");
            
            switch fitCriterion
                case fitType.LeastSquares
                    tf = ismember(geomName, ["Line","Plane","Circle","Sphere","Cylinder","Cone"]);
                case fitType.MinimumTotalDistance
                    tf = false;
                case fitType.ConstrainedLeastSquares
                    tf = ismember(geomName, ["Line","Plane"]);
                case fitType.ConstrainedMinimumTotalDistance
                    tf = ismember(geomName, ["Line","Plane"]);
                case fitType.MiniMax
                    tf = false;
                case fitType.MinimumCircumscribed
                    tf = false;
                case fitType.MaximumInscribed
                    tf = false;
                case fitType.WeightedLeastSquares
                    tf = false;
                otherwise
                    tf = false;
            end
        end

        function fitList = implemented()
            % IMPLEMENTED Return the list of fitting criteria currently implemented.
            %
            %   Syntax
            %     fitList = fitType.implemented()
            %
            %   Output Arguments
            %     fitList - Implemented fitting criteria
            %       fitType array
            %
            %   Example
            %     fitList = fitType.implemented();

            fitList = [ ...
                fitType.LeastSquares, ...
                fitType.ConstrainedLeastSquares, ...
                fitType.ConstrainedMinimumTotalDistance];
        end

        function fitList = unimplemented()
            % UNIMPLEMENTED Return the list of fitting criteria not yet implemented.
            %
            %   Syntax
            %     fitList = fitType.unimplemented()
            %
            %   Output Arguments
            %     fitList - Unimplemented fitting criteria
            %       fitType array
            %
            %   Example
            %     fitList = fitType.unimplemented();
            
            fitList = [ ...
                fitType.MinimumTotalDistance, ...
                fitType.MiniMax, ...
                fitType.MinimumCircumscribed, ...
                fitType.MaximumInscribed, ...
                fitType.WeightedLeastSquares];
        end
    end
end
