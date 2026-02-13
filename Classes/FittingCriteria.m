classdef FittingCriteria < int32
    % ASSOCIATIONCRITERIA Enumeration for different feature assoication methods.
    % Association Citeria:
    % LeastSquares          : Also known as Gaussian Fit/L2 fit. Minimizes the sum of
    %                         the squares of the residuals.
    % MiniMax               : Also known as Minimum Zone fit/L inifinity fit/Chebyshev
    %                         fit. Minimizes the size of the worst-case (largest) value residual.
    % MinimumCircumscribed  : Finds the smallest possible shape that can
    %                         completely enclose all the measured coordinate points.
    % MaximumInscribed      : Finds the largest possible shape that can fit
    %                         inside all the measured coordinate points.
    % MinimumTotalDistance  : Also known as L1 fit. Minmizes the sum of the
    %                         absolute values of the residuals.
    % WeightedLeastSquares  : This is an ordinary least squares algorithms
    %                         but the measured coordinate points are weighted based on uncertainty.


    enumeration        
        LeastSquares (1)
        MiniMax (2)
        MinimumCircumscribed (3)
        MaximumInscribed (4)
        MinimumTotalDistance (5)
        WeightedLeastSquares (6)
    end

    methods
        function list = supportedGeometries(geometry)   
            % Function to list the supported geometries for each association
            % criterion.   
            switch geometry
                case FittingCriteria.LeastSquares
                    list = ["Line", "Plane", "Circle", "Sphere", "Cylinder", "Cone"];
                case FittingCriteria.MiniMax
                    list = ["Line", "Plane", "Circle", "Sphere", "Cylinder", "Cone"];
                case FittingCriteria.MinimumCircumscribed
                    list = ["Cirlce", "Sphere", "Cylinder"];
                case FittingCriteria.MaximumInscribed
                    list = ["Cirlce", "Sphere", "Cylinder"];
                case FittingCriteria.MinimumTotalDistance
                    list = ["Line", "Plane", "Circle", "Sphere", "Cylinder", "Cone"];
                case FittingCriteria.WeightedLeastSquares
                    list = ["Line", "Plane", "Circle", "Sphere", "Cylinder", "Cone"];
                otherwise
                    list = string.empty;
            end
        end
    end

    methods (Static)
        function list = implemented()
            % Function with the list of implemented association criteria.
            list = [FittingCriteria.LeastSquares];
        end

        function list = unimplemented()
            % Function with the list of unimplemented association criteria.
            list = [FittingCriteria.MiniMax,
                FittingCriteria.MinimumCircumscribed,
                FittingCriteria.MaximumInscribed,
                FittingCriteria.MinimumTotalDistance,
                FittingCriteria.WeightedLeastSquares];
        end
    end
end
