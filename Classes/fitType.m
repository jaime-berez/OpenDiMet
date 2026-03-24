classdef fitType < int32
    % FITTYPE Enumeration of feature fitting criteria.
    %
    %   Syntax
    %     fitCriterion = fitType.LeastSquares
    %     fitCriterion = fitType.MiniMax
    %     fitCriterion = fitType.MinimumCircumscribed
    %     fitCriterion = fitType.MaximumInscribed
    %     fitCriterion = fitType.MinimumTotalDistance
    %     fitCriterion = fitType.WeightedLeastSquares
    %
    %   Enumeration Members
    %     LeastSquares - Gaussian or L2 fit that minimizes the sum of squared residuals
    %     MiniMax - Minimum-zone or Chebyshev fit that minimizes the maximum residual
    %     MinimumCircumscribed - Smallest enclosing associated feature
    %     MaximumInscribed - Largest inscribed associated feature
    %     MinimumTotalDistance - L1 fit that minimizes the sum of absolute residuals
    %     WeightedLeastSquares - Least-squares fit with weighted data points
    %
    %   Example
    %     fitCriterion = fitType.LeastSquares;

    enumeration
        LeastSquares (1)
        MiniMax (2)
        MinimumCircumscribed (3)
        MaximumInscribed (4)
        MinimumTotalDistance (5)
        WeightedLeastSquares (6)
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
                case fitType.MiniMax
                    geomList = ["Line","Plane","Circle","Sphere","Cylinder","Cone"];
                case fitType.MinimumCircumscribed
                    geomList = ["Cirlce","Sphere","Cylinder"];
                case fitType.MaximumInscribed
                    geomList = ["Circle","Sphere","Cylinder"];
                case fitType.MinimumTotalDistance
                    geomList = ["Line","Plane","Circle","Sphere","Cylinder","Cone"];
                case fitType.WeightedLeastSquares
                    geomList = ["Line","Plane","Circle","Sphere","Cylinder","Cone"];
                otherwise
                    geomList = string.empty;
            end
        end
    end

    methods (Static)
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

            fitList = [fitType.LeastSquares];
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
            
            fitList = [fitType.MiniMax,...
                       fitType.MinimumCircumscribed,...
                       fitType.MaximumInscribed,...
                       fitType.MinimumTotalDistance,...
                       fitType.WeightedLeastSquares];
        end
    end
end
