function [k, verts, dirs, cents, areas] = findOutwardsHull(data, refDir)
% FINDOUTWARDSHULL finds the facets of the convex hull of planar data that
% face out of the material
% Inputs:
%   data    : Plane coordinate data
%   refDir  : Approximate direction pointing *out* of material
% Outputs:
%   k       : The the outwards-facing convex hull triangulation matrix.
%             Can be used with trisurf().
%   verts   : 3x3xn matrix where each page is a set of three verticies that
%             make up n hull facets.
%   dirs    : nx3 direction normals of n facets.
%   cents   : nx3 centroids of n facets.
%   areas   : nx1 areas of n facets.
arguments (Input)
    data (:,3) double {mustBeFinite mustBeReal} % Not including nonNan or nonEmpty for now
    refDir (1,3) double {mustBeFinite mustBeReal mustBeNonNan mustBeNonempty}
end

% refDir is pointing out of material

% 00. Find convex hull - Slowest operation for large data sets
% k is nx3 matrix where the three elements in a row are the indices of the
% three x,y,z points in data that make up each facet
kAll = convhull(data(:,1),data(:,2),data(:,3));

% Method A - Matrix math (marginally faster for VERY large data sets)
% 01. Find the three vertices and normal direction of each facet
k1D = reshape(kAll',[],1); % Array of row indicies
verts = reshape(data(k1D,:)',3,3,[]); 
verts = permute(verts, [2 1 3]); % 3x3xn matrix where each page is the 3 vertices of a facet
% (?) How do I know that this produces dirs consistently pointing _out_?
dirs = cross(verts(2,:,:) - verts(1,:,:), verts(3,:,:) - verts(1,:,:)); % Normal dir of each facet
dirs = squeeze(dirs)'; % Removes dimension of 1
dirs = dirs./vecnorm(dirs, 2, 2); % Normalize (2-norm) across direction 2

% 02. Find which facets face 'out of the material'
thresh = 0.8; % Same direction: dot(dirF,dir) = 1, opp. dir = -1,
refDir = refDir/norm(refDir); % Normalize
idxOut = dot(dirs, repmat(refDir,[length(dirs), 1]),2) > thresh; % nx1 logical
k = kAll(idxOut,:); % mx3 matrix analagous to k but for out-facing facets
verts = verts(:,:,idxOut); % 3x3xm where each page is set of three verts of each facet
dirs = dirs(idxOut,:); % 3xm where each row is dir of each facet

% 03. Find the facing-out facet centroids, areas
cents = squeeze(mean(verts,1))'; % Mean of each page of vertices is facet centroid
s1 = squeeze(verts(2,:,:) - verts(1,:,:))'; % nx3 matrix of vectors of side 1 of facet
s2 = squeeze(verts(3,:,:) - verts(1,:,:))'; % nx3 matrix of vectors of side 2 of facet
areas = 0.5*vecnorm(cross(s1, s2,2),2,2); % Shakarji, 2014 has superior method insenstive to small angles

% % Method B - Slower, but not that slow (~0.06 sec for 15,000,000 points)
% tic
% x = data(:,1); y = data(:,2); z = data(:,3);
% 
% fctVrts = [];
% fctCnts = [];
% fctAreas = [];
% fctIdx = [];
% for i = 1:size(k, 1)
%     % Get the vertices of the current facet (3 sets of x,y,z points)
%     vrts = [x(k(i, :)), y(k(i, :)), z(k(i, :))];
%     v1 = vrts(1,:); v2 = vrts(2,:); v3 = vrts(3,:);
%     s1 = v2-v1; s2 = v3-v1; % Two sides of facet triangle
%     % Get the normal direction of facet
%     dir = cross(s1, s2);
%     % Determine if facet points in dir similar to plane dir (+Z)
%     thresh = 0.9; % Same direction: dot(dirF,dir) = 1, opp. dir = -1,
%     if dot(dir, refDir) > thresh % This facet points in approx +Z
%         % Calculate the area using the cross product method
%         fctVrts = cat(3,fctVrts,vrts);
%         cnt = mean(vrts);
%         fctCnts = [fctCnts; cnt];
%         area = 0.5*norm(cross(s1, s2));
%         fctAreas = [fctAreas area];
%         fctIdx = [fctIdx i];
%     end
% end
% 
% % 4. Find the facet nearest the convex hull centroid
% % Find the weighted average (by area) of facet centroids
% avgCnt = sum(fctCnts.*fctAreas')/sum(fctAreas);
% % Find distance from each facet cnt to overall cnt
% distVcts = fctCnts - avgCnt;
% % 5. Calculate the norm of each row in distVct
% dists = vecnorm(distVcts, 2, 2);
% 
% [m idx] = min(dists);
% 
% L1C = fctVrts(:,:,idx)
% toc

end