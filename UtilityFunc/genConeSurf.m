function [V, F] = genConeSurf(pnt, dir, smallR, bigR, height, nTheta)
    % GENCONESURF Generate a triangulated cone or cone-frustum surface mesh.
    %
    %   Syntax
    %     [V, F] = genConeSurf(pnt, dir, smallR, bigR, height)
    %     [V, F] = genConeSurf(pnt, dir, smallR, bigR, height, nTheta)
    %
    %   Input Arguments
    %     pnt - Point at the cone center (mid-height) on the axis
    %       1x3 double vector
    %     dir - Cone axis direction
    %       1x3 double vector
    %     smallR - Radius at the end located at z = -height/2 in the local frame
    %       nonnegative scalar double
    %     bigR - Radius at the end located at z = +height/2 in the local frame
    %       nonnegative scalar double
    %     height - Cone height along the axis
    %       nonnegative scalar double
    %     nTheta - Number of circumferential samples used to discretize the surface
    %       positive scalar double
    %
    %   Output Arguments
    %     V - Vertex coordinates of the cone surface mesh
    %       Nx3 double matrix
    %     F - Triangle face connectivity of the cone surface mesh
    %       Mx3 double matrix
    %
    %   Example
    %     [V, F] = genConeSurf(pnt, dir, smallR, bigR, height);
    %     [V, F] = genConeSurf(pnt, dir, smallR, bigR, height, 50);

    arguments
        pnt    (1,3) double {mustBeFinite,mustBeReal}
        dir    (1,3) double {mustBeFinite,mustBeReal}
        smallR (1,1) double {mustBeFinite,mustBeReal,mustBeNonnegative}
        bigR   (1,1) double {mustBeFinite,mustBeReal,mustBeNonnegative}
        height (1,1) double {mustBeFinite,mustBeReal,mustBeNonnegative}
        nTheta (1,1) double {mustBeFinite,mustBeReal,mustBePositive} = 27
    end
    
    % Normalize direction
    dir = dir / norm(dir);
    
    nTheta = max(3, round(nTheta));
    
    % Canonical cone along +Z centered at origin
    
    theta = linspace(0,2*pi,nTheta+1);
    theta(end) = [];
    
    zBot = -height/2;
    zTop =  height/2;
    
    if smallR > 0
        xb = smallR*cos(theta);
        yb = smallR*sin(theta);
        Vbot = [xb(:) yb(:) zBot*ones(nTheta,1)];
    else
        Vbot = [0 0 zBot];   % apex
    end
    
    if bigR > 0
        xt = bigR*cos(theta);
        yt = bigR*sin(theta);
        Vtop = [xt(:) yt(:) zTop*ones(nTheta,1)];
    else
        Vtop = [0 0 zTop];   % apex
    end
    
    % Triangulate side surface  
    if smallR>0 && bigR>0
        % Frustum
        Vlocal = [Vbot; Vtop];
        F = zeros(2*nTheta,3);
    
        for i = 1:nTheta
            i2 = i+1;
            if i==nTheta, i2=1; end
    
            b1 = i;
            b2 = i2;
            t1 = i+nTheta;
            t2 = i2+nTheta;
    
            F(2*i-1,:) = [b1 b2 t2];
            F(2*i  ,:) = [b1 t2 t1];
        end
    
    elseif smallR==0
        % Apex bottom
        Vlocal = [Vbot; Vtop];
        F = zeros(nTheta,3);
    
        for i = 1:nTheta
            i2 = i+1;
            if i==nTheta, i2=1; end
    
            F(i,:) = [1 i2+1 i+1];
        end
    
    elseif bigR==0
        % Apex top
        Vlocal = [Vbot; Vtop];
        apex = nTheta+1;
        F = zeros(nTheta,3);
    
        for i = 1:nTheta
            i2 = i+1;
            if i==nTheta, i2=1; end
    
            F(i,:) = [i i2 apex];
        end
    
    else
        error("Degenerate cone (both radii zero)")
    end
    
    % Rotate and translate    
    R = rotMatA2BR([0 0 1], dir);
    V = (Vlocal*R.') + pnt;
end