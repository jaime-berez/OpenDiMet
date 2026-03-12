classdef MaterialSide
    % MATERIALSIDE Enumeration for specifying material side designation.
    %
    %   Syntax
    %     ms = MaterialSide.Unspecified
    %     ms = MaterialSide.External
    %     ms = MaterialSide.Internal
    %
    %   Enumeration Members
    %     Unspecified - Material side not specified
    %     External - External material boundary (e.g., shaft or outside surface)
    %     Internal - Internal material boundary (e.g., hole or inside surface)
    %
    %   Example
    %     ms = MaterialSide.External;
    
    enumeration
        Unspecified 
        External      % shaft/outside material boundary
        Internal      % hole/inside material boundary
    end
end