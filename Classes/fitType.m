classdef fitType < int32

    % FITTYPE Enumeration for different feature assoication methods.
    % Fit type:
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
        function geomList = supportedGeometries(ft)
            switch ft
                case fitType.LeastSquares
                    geomList = ["Line","Plane","Circle","Sphere","Cylinder","Cone"];
                case fitType.MiniMax
                    geomList = ["Line","Plane","Circle","Sphere","Cylinder","Cone"];
                case fitType.MinimumCircumscribed
                    geomList = ["Cirlce","Sphere","Cylinder"];
                case fitType.MaximumInscribed
                    geomList = ["Cirlce","Sphere","Cylinder"];
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
            fitList = [fitType.LeastSquares];
        end

        function fitList = unimplemented()
            fitList = [fitType.MiniMax,...
                       fitType.MinimumCircumscribed,...
                       fitType.MaximumInscribed,...
                       fitType.MinimumTotalDistance,...
                       fitType.WeightedLeastSquares];
        end
    end
end
