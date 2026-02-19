classdef fitType < int32

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
