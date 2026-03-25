function [lin, linEndPnts, k, kEdge, kLin, cond] = fitLinL2C(data, refDir);
%FITLINL2C performs a constrained (one-sided) L2-norm fit to linear data.
% Inputs:
%   data        : Line coordinate data
%   refDir      : Approximate direction pointing *out* of material
% Outputs:
%   lin         : A line structure with a point and direction normal (along line).
%                 The point corresponds to either the edge centroid or vertex
%                 depending on the rocking condition.
%   linEndPnts  : End points of fitted line extended to bound data, used for plotting.
%   k           : The the outwards-facing convex hull vertex indices.
%   kEdge       : Data indicies of the candidate edge
%   kLin        : Data indices of the edge or vertex that the L1C line goes
%                 through, depnding on the rocking condition.
%   cond        : The rocking condition.

    arguments (Input)
        data (:,2) double {mustBeFinite mustBeReal} % Not including nonNan or nonEmpty for now
        refDir (1,2) double {mustBeFinite mustBeReal mustBeNonNan mustBeNonempty}
    end
    
    % Ref dir is a direction that points OUT of the material
    % Dev notes:
    
    %% 0. Prep
    % 0.00. Translate data centroid to origin, rotate to point refDir (out) in -Y (down)
    % Hull of _out-facing_ surface is now _under_ the data
    centData = mean(data);
    refDir = -refDir/norm(refDir); % Normalize, flip
    R = [refDir(2) refDir(1); -refDir(1) refDir(2)]; % R s/t refDir points -Y
    data = (data - centData)*R;
    
    % 0.01. Find the convex hull and the edges of the hull that face 'out'
    kAll = convhull(data(:,1),data(:,2)); % Indices of data that are verts on conv hull
    kAll = kAll(1:end-1); % Remove last entry which is a repeat of first
    vrts = data(kAll,:); % List of hull verts in clockwise order
    vrts2 = data([kAll(2:end); kAll(1)],:); % Indexed over one, including first point added to end
    cnts = (vrts + vrts2)/2;
    vcts = vrts2 - vrts; % Pointing in clockwise direction
    nrms = [vcts(:,2) -vcts(:,1)]; % Normal to each edge, pointing out
    nrms = nrms./sqrt(nrms(:,1).^2 + nrms(:,2).^2); % Normalize to unit vector
    % Find which verts on conv hull correspond to edges that face out
    thresh = -0.8;
    j = find(nrms(:,2) < thresh);
    % Find indices in data that correspond to out-facing edges from left to right
    kTemp = kAll(j); % Not sorted, does not proceed from left to right
    xVals = data(kTemp,1);
    [~, l] = sort(xVals); % l is indices of kTemp in ascending x order
    kSorted = kTemp(l); % Sorted, but missing index for end point of last edge
    kLast = kAll(mod(find(kAll == kSorted(end)), length(kAll)) + 1); % Mod to loop around to first element if needed
    k = [kSorted; kLast]; % Sorted, includes last vertex
    % Create sorted lists of verts, cents, vects, and norms for n out-facing edge
    vrts = data(k,:); % n+1 verts
    cnts = cnts(j(l),:); % n cents
    vcts = vcts(j(l),:); % n vects
    nrms = nrms(j(l),:); % n norms
    
    %% 1. Consider candidate L through two verts of hull
    % 1.01 Calc total length and centroid of hull
    lens = sqrt(vcts(:,1).^2 + vcts(:,2).^2);
    lenHull = sum(lens); % Total hull length
    cntHull = lens'*cnts/lenHull; % Total hull centroid
    
    % 1.02 Formulate matrix M where hull centroid is on origin
    wgts = ([lens;0] + [0;lens])/6; % Does not match paper (padded w/ zeros)
    vrtsTrnsWtd = (vrts - cntHull).*sqrt(wgts);
    cntsTrnsWtd = (cnts - cntHull).*sqrt((2/3)*lens);
    M = [vrtsTrnsWtd; cntsTrnsWtd];
    
    % 1.03 Perform SVD to attain singular values and vectors
    [~,S,V] = svd(M,0);
    
    % 1.04 Consider each edge to be a candidate L: Using sing vals and vects
    % as coeff in the objective func, for each edge, use its dir to calc an
    % associated objective func value (one for each edge)
    sig1 = S(2,2); sig2 = S(1,1); % Sing values
    a = nrms*V(:,2); b = nrms*V(:,1); % Dot products with sing vectors
    dsts = dot(nrms',-cntsTrnsWtd')'; % Distances (dot product) b/w each line segment _midpoint_ and hull centroid (which is zero)
    objFun = sig1^2*a.^2 + sig2^2*b.^2 + lenHull*dsts.^2; % Eq. 4b (equiv to 4a.)
    [minObjFun,idxObjFun] = min(objFun); % Min value of obj fun
    
    % 1.05 Edge corresonding to min obj func value is a candidate L
    pnt = cnts(idxObjFun,:);
    kLin = k([idxObjFun; idxObjFun + 1]);
    kEdge = kLin;
    dir = nrms(idxObjFun,:);
    dir = [-dir(2) dir(1)]; % Dir is pointing right along line
    cond = "edge";
    
    %% 2. Consider a rocking condition, a plane through point
    % Iterate through the two verts making up the edge
    for idx = idxObjFun:idxObjFun+1
    
        % 2.01 Consider candidate L through one vert
        vert = vrts(idx,:);
    
        % 2.02 Construct matrix M s/t current vert is on origin
        vrtsTrnsWtd = (vrts - vert).*sqrt(wgts);
        cntsTrnsWtd = (cnts - vert).*sqrt((2/3)*lens);
        M = [vrtsTrnsWtd; cntsTrnsWtd];
    
        % 2.03 Solve SVD for singular values and vectors
        [~,S,V] = svd(M,0);
        sig2 = S(2,2); % Only sing val needed
        dirLin = V(:,1)'; % First singular vector is dir along candidate line
        if dirLin(1) < 0 % If pointing in -X
            dirLin = -dirLin; % Flip
        end
        
        % 2.04 Check if L through vert with dirLin is valid (doesnt cut thru material)
        % Dist (dot product) b/w all verts and current vert along candidate L normal
        nrm = [-dirLin(2) dirLin(1)]; % Flip to get normal
        dsts = (nrm*(vrts - vert)')'; % All distances b/w vert and verts.
        [~,idxDistMin]=min(dsts);
        % Note: Will include neg dists if L 'cuts thru' material.
        if (idxDistMin == idx)
            
            % 2.05 Check objFun is global min 
            minObjFunAlt = sig2^2; % Min value is candidate L through vert.
            % Note: First and third terms of objFun are zero. dirLin is first sing 
            % vect. All sing vect are orthogonal. Thus, dot product of first and 
            % second sing is zero, second and second is one. Dist b/w vert and 
            % itself is zero for the candidate L.
            if minObjFunAlt < minObjFun
                minObjFun = minObjFunAlt;
                dir = dirLin; % Set equal to candidate direction
                pnt = vert; % Set equal to candidate vert
                kLin = k(idx);
                cond = "point";
                %disp('***L2C line: Rocking condition on point found***')
            end
        end
    end
    
    % F. Format output
    % F.1 Find edges of data so that ends points of the fit line may be determined
    [minX iMinX] = min(data(:,1)); [maxX iMaxX] = max(data(:,1));
    magLeft = norm(pnt - data(iMinX,:)); 
    magRight = norm(data(iMaxX,:) - pnt); % Dist b/w L2C point and ends of data set
    % F.2 Set end points of L2C plane
    linEndPnts = ([pnt - dir*magLeft;...
        pnt + dir*magRight]...
        )*inv(R) + centData; % Two points on L2C plane spanning entire data set
    % F.3 Set L2C point and dir
    lin.pnt = pnt*inv(R) + centData; % Uses mid point or vertex
    lin.dir = dir*inv(R); % Uses edge direction (along) or L2 dir (along)
    lin.data = data;
end