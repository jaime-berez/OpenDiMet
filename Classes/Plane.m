classdef Plane < Feature
    % PLANE Fit and represent a plane from 3D coordinate data.
    %
    %   Syntax
    %     obj = Plane(name, data, fitCriterion)
    %     obj = Plane(name, data, fitCriterion, Name = Value)
    %
    %   Input Arguments
    %     name - Feature name
    %       string scalar | character vector
    %     data - Measured 3D point coordinates
    %       Nx3 double matrix
    %     fitCriterion - Fitting criterion
    %       fitType enumeration
    %
    %   Name-Value Arguments
    %     MaxIter - Maximum number of LM iterations
    %       positive scalar double
    %     StepTol - Step-size convergence tolerance
    %       positive scalar double
    %     GradTol - Gradient convergence tolerance
    %       positive scalar double
    %     SSETol - Sum-of-squared-errors convergence tolerance
    %       positive scalar double
    %     Lambda - Initial damping parameter for LM
    %       positive scalar double
    %     DampingCoeff - LM damping update coefficient
    %       positive scalar double
    %     SuppressOutput - Flag to suppress optimizer output
    %       logical scalar
    %     sourceFile - Source file associated with the data
    %       string scalar
    %     refDir - 1x3 double - Reference direction used to constrain the plane
    %       orientation
    %       Specifies a direction pointing outward from the material
    %       surface and is required for constrained plane fitting methods.
    %
    %   Output Arguments
    %     obj - Plane feature object
    %       Plane scalar
    %
    %   Properties
    %     pnt - 1x3 double, point on the fitted plane
    %     dir - 1x3 double, unit normal vector of the fitted plane
    %     fitInfo - Structure containing fitting method information
    %
    %   Example
    %     P = Plane("Plane 1", data, fitType.LeastSquares);
    %     P.plot();

    properties (GetAccess = public, SetAccess = private)
        pnt (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dir (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        fitInfo struct = struct()
    end

    methods
        function obj = Plane(name, data, fitCriterion, opts)
            % Constructor for the Plane class
            arguments
                name (1,1) string {mustBeTextScalar}
                data (:,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
                fitCriterion (1,1) fitType

                opts.MaxIter       (1,1) double {mustBeFinite, mustBePositive} = 5000
                opts.StepTol       (1,1) double {mustBeFinite, mustBePositive} = 1e-9
                opts.GradTol       (1,1) double {mustBeFinite, mustBePositive} = 1e-11
                opts.SSETol        (1,1) double {mustBeFinite, mustBePositive} = 1e-19
                opts.Lambda        (1,1) double {mustBeFinite, mustBePositive} = 1e-4
                opts.DampingCoeff  (1,1) double {mustBeFinite, mustBePositive} = 2
                opts.SuppressOutput(1,1) logical = true
                opts.sourceFile (1,1) string = ""
                opts.refDir double = []
            end

            obj@Feature(name, data, fitCriterion, opts.sourceFile);
            obj.validateAssociation();

            opts.refDir = Plane.validateRefDir(fitCriterion, opts.refDir);

            fitResult = Plane.fitData(data, fitCriterion, opts);
            
            obj.pnt = fitResult.pnt;
            obj.dir = fitResult.dir;
            obj.sigma = fitResult.sigma;
            obj.fitInfo = fitResult.fitInfo;
        end

        function varargout = plot(obj, opts)
            % PLOT Plot plane coordinate data and fitted plane surface.
            %
            %   Syntax
            %     plot(obj)
            %     plot(obj, Name = Value)
            %     h = plot(obj)
            %     h = plot(obj, Name = Value)
            %
            %   Input Arguments
            %     obj - Plane feature object
            %       Plane scalar
            %
            %   Name-Value Arguments
            %     dataColor - Color of plotted data points
            %       RGB triplet | color name | short color code
            %     dataLabel - Legend label for data points
            %       string scalar
            %     dataMarker - Marker symbol for data points
            %       string scalar
            %     dataMarkerSize - Marker size for data points
            %       positive scalar double
            %     fitColor - Face color of fitted plane
            %       RGB triplet | color name | short color code
            %     fitLabel - Legend label for fitted plane
            %       string scalar
            %     fitFaceAlpha - Face transparency of fitted plane
            %       scalar double in the range [0, 1]
            %     fitEdgeColor - Edge color of fitted plane
            %       RGB triplet | color name | short color code | "none"
            %     ax - Target axes for plotting
            %       matlab.graphics.axis.Axes object
            %
            %   Output Arguments
            %     h - Patch handle for fitted plane surface
            %       Patch object
            %
            %   Example
            %     P.plot();
            %     P.plot(fitColor = [0 1 0], fitFaceAlpha = 0.3);

            arguments
                obj
                opts.dataColor = [0 0.4470 0.7410]
                opts.dataLabel (1,1) string = obj.name + " Data"
                opts.dataMarker (1,1) string = "o"
                opts.dataMarkerSize (1,1) double {mustBeFinite,mustBePositive} = 30

                opts.fitColor = [0 1 0]
                opts.fitLabel (1,1) string = obj.name + " Fit"
                opts.fitFaceAlpha (1,1) double {mustBeFinite, ...
                    mustBeGreaterThanOrEqual(opts.fitFaceAlpha,0), ...
                    mustBeLessThanOrEqual(opts.fitFaceAlpha,1)} = 0.4
                opts.fitEdgeColor = "k"    % "none" or color
                opts.showTitle (1,1) logical = true

                opts.ax = []
            end

            ax = opts.ax;
            if isempty(ax) || ~isvalid(ax)
                ax = gca;
            end

            % Parse styling
            dataColor = Feature.parseColor(opts.dataColor);
            fitColor  = Feature.parseColor(opts.fitColor);

            if string(opts.fitEdgeColor) == "none"
                edgeColor = "none";
            else
                edgeColor = Feature.parseColor(opts.fitEdgeColor);
            end

            % Geometry
            data = obj.data;
            pnt  = obj.pnt;
            dir  = obj.dir;
            %cla(ax);
            hold(ax,'on'); grid(ax,'on');
            axis(ax,'equal'); axis(ax,'padded'); view(ax,3);
            xlabel(ax,'x'); ylabel(ax,'y'); zlabel(ax,'z');
            if opts.showTitle
                title(ax, opts.fitLabel);
            end

            % Plot coordinate data
            % plot3(ax, data(:,1), data(:,2), data(:,3), char(opts.dataMarker), ...
            %     'Color', dataColor, 'MarkerSize', opts.dataMarkerSize, 'DisplayName', opts.dataLabel)
            plotData(data, markerColor = dataColor, markerStyle = char(opts.dataMarker), ...
                markerSize = opts.dataMarkerSize, dataLabel = opts.dataLabel, ax = ax);

            % Plot centroid
            plot3(ax, pnt(1), pnt(2), pnt(3), 'xk', 'HandleVisibility', 'off');

            [V, F] = genPlaneSurf(data, pnt, dir);  % scalingFactor optional

            h = patch(ax, 'Vertices', V, 'Faces', F, ...
                'FaceColor', fitColor, ...
                'EdgeColor', 'none', ...
                'FaceAlpha', opts.fitFaceAlpha, ...
                'DisplayName', opts.fitLabel);

            if string(opts.fitEdgeColor) ~= "none"
                Vclosed = [V; V(1,:)];
                plot3(ax, Vclosed(:,1), Vclosed(:,2), Vclosed(:,3), ...
                    'Color', edgeColor, 'LineWidth', 1.0, 'HandleVisibility', 'off');
            end

            legend(ax, "show", 'FontSize', 12);
            hold(ax, "off");
            if nargout > 0
                varargout{1} = h;
            end
        end

        function showFitInfo(obj)
            % SHOWFITINFO Display stored fitting information for the Plane object.
            %
            %   Syntax
            %     showFitInfo(obj)
            %
            %   Input Arguments
            %     obj - Plane feature object
            %       Plane scalar
            %
            %   Example
            %     P.showFitInfo();

            if isempty(obj.fitInfo)
                disp('No optimization information available for this object.');
                return;
            end

            if isfield(obj.fitInfo, 'history')
                T = array2table(obj.fitInfo.history, 'VariableNames', obj.fitInfo.labels);
                fprintf('--- Levenberg–Marquardt Optimization Summary ---\n');
                fprintf('Iterations: %d\nFinal SSE: %.4e\n\n', ...
                        obj.fitInfo.iter, obj.fitInfo.final_cost);
                disp(T);
            else
                fprintf('--- Analytical Fit Information ---\n');
                fprintf('Method: %s\n', obj.fitInfo.method);
                fprintf('Description: %s\n', obj.fitInfo.description);
            end
        end

        function disp(obj)
            % DISP Display a formatted summary of the Plane feature object.
            %
            %   Syntax
            %     disp(obj)
            %
            %   Input Arguments
            %     obj - Plane feature object
            %       Plane scalar
            %
            %   Example
            %     disp(P);

            name = string(obj.name);
            ft   = obj.fitType;
            data = obj.data;

            pnt  = obj.pnt(:).';
            dir  = obj.dir(:).';
            sig  = obj.sigma;

            dataClass = class(data);
            dataSize  = size(data);

            fprintf('%s Object\n', class(obj));
            fprintf('  Name:      %s\n', name);
            fprintf('  FitCrit: %s\n', char(ft));
            fprintf('  Point:     [%.4f  %.4f  %.4f]\n', pnt);
            fprintf('  Direction: [%.4f  %.4f  %.4f]\n', dir);
            fprintf('  Sigma:     %.4f\n', sig);
            fprintf('  Data Size: [%s]\n', [num2str(dataSize(1)), ' x ', num2str(dataSize(2))]);
        end

        function reverseDir(obj)
            % REVERSEDIR Reverse the orientation of the fitted plane normal vector.
            %
            %   Syntax
            %     reverseDir(obj)
            %
            %   Input Arguments
            %     obj - Plane feature object
            %       Plane scalar
            %
            %   Example
            %     P.reverseDir();
            obj.dir = -obj.dir;
        end
    end

    methods (Static, Access = private)
        function refDir = validateRefDir(fitCriterion, refDir)
            % VALIDATEREFDIR Validate and normalize the reference direction for constrained plane fits.
            %
            %   Syntax
            %     refDir = Plane.validateRefDir(fitCriterion, refDir)
            %
            %   Input Arguments
            %     fitCriterion - Fitting criterion
            %       fitType enumeration
            %     refDir - Reference direction for constrained fitting
            %       1x3 double vector | []
            %
            %   Output Arguments
            %     refDir - Validated and normalized reference direction
            %       1x3 double vector | []
            %
            %   Example
            %     refDir = Plane.validateRefDir(fitType.ConstrainedLeastSquares, [0 0 1]);

            isConstrained = any(fitCriterion == [ ...
                fitType.ConstrainedLeastSquares, ...
                fitType.ConstrainedMinimumTotalDistance]);
    
            if isConstrained
                if isempty(refDir)
                    error("Plane:MissingRefDir", ...
                        "refDir must be provided for constrained plane fits.");
                end
    
                if ~isnumeric(refDir) || ~isequal(size(refDir), [1 3]) || ...
                        any(~isfinite(refDir)) || any(isnan(refDir))
                    error("Plane:InvalidRefDir", ...
                        "refDir must be a finite 1x3 vector.");
                end
    
                if norm(refDir) <= eps
                    error("Plane:ZeroRefDir", ...
                        "refDir must be a nonzero vector.");
                end
    
                refDir = refDir / norm(refDir);
            else
                if ~isempty(refDir)
                    if ~isnumeric(refDir) || ~isequal(size(refDir), [1 3]) || ...
                            any(~isfinite(refDir)) || any(isnan(refDir)) || norm(refDir) <= eps
                        error("Plane:InvalidRefDir", ...
                            "If provided, RefDir must be a finite nonzero 1x3 vector.");
                    end
                    refDir = refDir / norm(refDir);
                end
            end
        end

        function fitResult = fitLeastSquares(data, ~)
            % FITLEASTSQUARES Fit a plane using unconstrained least-squares association.
            %
            %   Syntax
            %     fitResult = Plane.fitLeastSquares(data, opts)
            %
            %   Input Arguments
            %     data - Measured 3D point coordinates
            %       Nx3 double matrix
            %     opts - Options structure
            %       struct
            %
            %   Output Arguments
            %     fitResult - Standardized plane fit result
            %       struct
            %
            %   Example
            %     fitResult = Plane.fitLeastSquares(data, struct());

            cent = mean(data, 1);
            dataT = data - cent;

            A = dataT.' * dataT;
            [eigVec, eigValMat] = eig(A);

            eigVals = diag(eigValMat);
            [~, idx] = min(eigVals);

            dir = eigVec(:, idx).';
            dir = dir / norm(dir);
            dir = Plane.normalizeNormal(dir);

            residuals = dataT * dir.';
            sigma = std(residuals);

            fitInfo = struct( ...
                'method', "SVD", ...
                'criterion', "LeastSquares", ...
                'description', "Least-squares plane fit using eigen-decomposition of centered data.", ...
                'residualType', "signed orthogonal point-to-plane distance");

            fitResult = struct( ...
                'pnt', cent, ...
                'dir', dir, ...
                'sigma', sigma, ...
                'residuals', residuals, ...
                'fitInfo', fitInfo);
        end

        function fitResult = fitConstrainedMinimumTotalDistance(data, opts)
            % FITCONSTRAINEDMINIMUMTOTALDISTANCE Fit a one-sided constrained L1 plane.
            %
            %   Syntax
            %     fitResult = Plane.fitConstrainedMinimumTotalDistance(data, opts)
            %
            %   Input Arguments
            %     data - Measured 3D point coordinates
            %       Nx3 double matrix
            %     opts - Options structure containing refDir
            %       struct
            %
            %   Output Arguments
            %     fitResult - Standardized plane fit result
            %       struct
            %
            %   Example
            %     fitResult = Plane.fitConstrainedMinimumTotalDistance(data, opts);

            refDir = opts.refDir;
         
            % 01. Find the convex hull and the facets of the hull that face 'out'
            [k, verts, dirs, cents, areas] = findOutwardsHull(data, refDir); 
        
            % 02. Choose the facet nearest the total centroid
            cntHull = sum(cents.*areas)/sum(areas); % Centroid of entire out-facing hull surface
            distVcts = cents - cntHull;
            distNrms = dot(dirs, distVcts, 2); % Shortest dist between plane and cntHull
            [~, idxMin] = min(vecnorm(distNrms,2,2));
            kFacet = k(idxMin,:)';
        
            % 03. Build L1C plane object
            pnt = cents(idxMin,:);
            dir = dirs(idxMin,:);
            [X, Y, Z] = calcPlaneBoundingPnts(data, pnt, dir, 1); 
            plaCorners = [[X; X(1)], [Y; Y(1)], [Z; Z(1)]]; 
              
            residuals = (data - pnt) * dir.';
            sigma = std(residuals);
        
            fitInfo = struct( ...
                'method', "ConvexHullFacetSelection", ...
                'criterion', "ConstrainedMinimumTotalDistance", ...
                'description', "One-sided constrained L1 plane fit using outward convex hull facet selection.", ...
                'refDir', refDir, ...
                'kFacet', kFacet, ...
                'hullTriangulation', k, ...
                'residualType', "signed orthogonal point-to-plane distance");
        
            fitResult = struct( ...
                'pnt', pnt, ...
                'dir', dir, ...
                'sigma', sigma, ...
                'residuals', residuals, ...
                'fitInfo', fitInfo);
        end

        function fitResult = fitConstrainedLeastSquares(data, opts)
            % FITCONSTRAINEDLEASTSQUARES Fit a one-sided constrained L2 plane.
            %
            %   Syntax
            %     fitResult = Plane.fitConstrainedLeastSquares(data, opts)
            %
            %   Input Arguments
            %     data - Measured 3D point coordinates
            %       Nx3 double matrix
            %     opts - Options structure containing refDir
            %       struct
            %
            %   Output Arguments
            %     fitResult - Standardized plane fit result
            %       struct
            %
            %   Example
            %     fitResult = Plane.fitConstrainedLeastSquares(data, opts);
            
                refDir = opts.refDir;
            
                % Dev notes:
                % refDir is opposite of Shakarji's convention
                % Not sure edges of facet have to be checked seperately from vertices
                % May want to re-org how foundOutwardsHull organizes 3x3xN vertices list
            
                % 0. Prep
                % 0.00. Translate data centroid to origin, rotate to point refDir in -Z
                % Hull of _out-facing_ surface is now _under_ the data
                refDir = refDir/norm(refDir); % Normalize
                R = rotMatA2Z(-refDir);
                centData = mean(data);
                data0 = (data - centData)*R;
            
                % 1. Find the facet of hull that minimizes L2 norm
            
                % 1.01 Calculate total areas and centroid of hull
                [k, verts, dirs, cents, areas] = findOutwardsHull(data0, [0 0 -1]); % Assumes out facing down
                centHull = sum(cents.*areas)/sum(areas); % Centroid of out-facing hull
                areaHull = sum(areas); % Area of out-facing hull
                areasExp = repmat(areas,1,3); % Expand to [A1 A2... An; A1 A2... An; A1 A2 An]
                areasExp = reshape(areasExp',[],1); % Reshape to [A1 A1 A1 A2 A2 A2... An An An]
            
                % 1.02 Formulate M where hull centroid is on origin
                vertsList = reshape(pagetranspose(verts),3,[])'; % (n*3)x3 list of all verts
                vertsTrnsWtd = (vertsList-centHull).*sqrt((1/12)*areasExp); % Weight by area via Simpson's rule
                centsTrnsWtd = (cents-centHull).*sqrt((3/4)*areas); % Weight by area via Simpson's rule
                M = [vertsTrnsWtd; centsTrnsWtd]; % Matrix for SVD (order in rows does not matter)
            
                % 1.03 Solve SVD for candidate sing vals and vects (obj fun coeff)
                [~,S,V] = svd(M,0); % S always returned in dec order along diag, V is three col vectors
            
                % 1.04 Consider each facet to be a candidate P: Using sing vals and vects
                % as coeff in the objective func, for each facet, use its dir to calc an
                % associated objective func value (one for each facet)
                sig1 = S(1,1); sig2 = S(2,2); sig3 = S(3,3); % Coeff for objective function
                a = dirs*V(:,1); b = dirs*V(:,2); c = dirs*V(:,3); % Dot product of each facet dir with sing vect
                dists = dot(dirs, cents - centHull, 2); % Dists b/w each facet cents and hull cent
                objFun = sig1^2*a.^2 + sig2^2*b.^2 + sig3^2*c.^2 + areaHull*dists.^2; % dirs comps and dists get squared (+/- unimportant)
                [minObjFun, idxObjFun] = min(objFun); % Minimal obj func value corresponding
            
                % 1.05 Facet corresonding to min obj func value is a candidate P
                pnt = cents(idxObjFun,:);
                dir = dirs(idxObjFun,:);
                vertsL2C = verts(:,:,idxObjFun); %#ok<NASGU>
                kPla = k(idxObjFun,:)'; % 3x1 list of indices in data corresponding to facet verts
                kFacet = kPla;
                cond = "facet";
            
                % 2. Rocking condition on point: Consider P through one of three verts of
                % facet. Calc a sing vector with all hull verts translated s/t candidate vert
                % is on the origin. The appropraite sing vect is then the candidate P dir.
                % If candidate P is still oustide of material and obj fun is improved, accept.
            
                % Iterate through three vertices of facet
                for idx = kFacet'
            
                    % 2.01 Consider candidate P through a vert of prior found facet
                    vert = data0(idx,:); % Current vert, will be each of the three verts of prior facet found
            
                    % 2.02 Formulate M where candidate vert on origin
                    vertsTrnsWtd = (vertsList-vert).*sqrt((1/12)*areasExp);
                    centsTrnsWtd = (cents-vert).*sqrt((3/4)*areas);
                    M = [vertsTrnsWtd; centsTrnsWtd]; % Matrix for SVD
            
                    % 2.03 Solve SVD for sing vals and vects
                    [~,S,V] = svd(M,0);
                    dirPla = V(:,3)'; % Direction normal for candidate L2C plane through vert
                    if dirPla(3) < 0 % If points down
                        dirPla = -1*dirPla; % Switch to point up (required s/t minimization finds vert below ALL data)
                    end
            
                    % 2.04 Check if P with dirPla through vert is valid
                    distsVerts = (vertsList - vert)*dirPla'; % Dists b/w all verts and candidate vert
                    [distMin, idxDistMin] = min(distsVerts); %#ok<ASGLU> % Choose min dist
                    % Note: Min dist s/b zero for a valid point. There will be neg dists if
                    % candidate P cuts 'through' material.
                    % Note: Some verts may be repeated on the list
                    if (isequal(vertsList(idxDistMin,:), vert)) % If the min dist corresponds to the current vert (no neg vals)
            
                        % 2.05 Calc obj fun value for this vert
                        sig3 = S(3,3);
                        minObjFunAlt = sig3^2;
                        % Note: First, second, and fourth terms of objFun are zero. dirPla
                        % is third singVvect. All sing vect are orthogonal. Thus, dot
                        % product of first and second sing vect with third are zero, third
                        % with third is one. Dist b/w vert and itself is zero for the candiate P.
            
                        if(minObjFunAlt < minObjFun) % If obj func value is lower than facet obj func value
                            disp("***L2C plane: Rocking condition on POINT found***")
                            cond = "point";
                            minObjFun = minObjFunAlt;
            
                            % 2.06 Vertex and sing vector define L2C plane
                            dir = -1*dirPla;
                            pnt = vert;
                            kPla = idx;
                        else
                        end
                    else
                    end
                end
            
                % 3. Rocking condition on edge: Consider P through one of three edges of
                % facet. Calc a sing vector with all hull verts translated s/t candidate vert
                % is on the origin. The appropraite sing vect is then the candidate P dir.
                % If candidate P is still oustide of material and obj fun is improved, accept.
            
                % Iterate through three edges of facet
                for idx = 1:3
            
                    % 3.01 Consider candidate P through an edge of prior found facet
                    kVert1 = kFacet(idx); % First vert of edge
                    kVert2 = kFacet(mod(idx,3) + 1); % Second. Loop around to first when vert1 is third
                    vert1 = data0(kVert1,:); % Current vert
                    vert2 = data0(kVert2,:); % Next vert
                    vect = [vert2 - vert1];
                    cent = mean([vert1; vert2]);
                    dirEdge = vert2 - vert1;
            
                    % 3.01 Rotate data s/t edge points in +Z, project points onto X-Y plane
                    R2 = rotMatA2Z(dirEdge);
                    refDir2D = refDir*R*R2; % Ref dir will now have a near zero z component
                    data2D = data0*R2;
                    data2D = data2D(:,1:2); % Both verts of edge will now be coincident
                    data2D(kVert2,:) = mean(data2D); % Set second vert to centroid (inside hull, won't affect L2C line calc)
            
                    % 3.02 Find L2C in 2D
                    [lin, ~, ~, ~, kLin, cond2D] = fitLinL2C(data2D, refDir2D(1:2));
            
                    % 3.03 Determine if L2C line is through point that is edge projected
                    % onto X-Y plane
                    if((cond2D == "point") && (kLin == kVert1))
                        % Determine direction of candidate P that is through edge
                        % Don't assume direction is left or right along line, compare with the
                        % reference direction and rotate s/t norm points out of material
                        dirPla2D = [lin.dir(2) -lin.dir(1) 0];
                        % if dot(refDir2D, dirPla2D) < 0 % If they are opposite (points into material)
                        %     dirPla2D = -1*dirPla2D; % Flip (to point out of material)
                        % end
                        dirPla = dirPla2D*inv(R2); % Rotate back
            
                        % 3.03 Check if obj fun is at global min
                            % Formulate M where candidate edge cent (or vert) is on origin
                            vertsTrnsWtd = (vertsList-cent).*sqrt((1/12)*areasExp);
                            centsTrnsWtd = (cents-cent).*sqrt((3/4)*areas);
                            M = [vertsTrnsWtd; centsTrnsWtd]; % Matrix for SVD
                            % Solve SVD for sing vals... vects will not be used since L2C line dir
                            % rotated back into current coords will be used for andidate instead
                            [~,S,V] = svd(M,0);
            
                            % % 2.04 Check if P with dirPla through vert is valid
                            % distsVerts = (vertsList - vert)*dirPla'; % Dists b/w all verts and candidate vert
                            % [distMin idxDistMin] = min(distsVerts); % Choose min dist
                            % % Note: Min dist s/b zero for a valid point. There will be neg dists if
                            % % candidate P cuts 'through' material.
                            % % Note: Some verts may be repeated on the list
            
                            % 2.05 Calc obj fun value for this vert
                            sig1 = S(1,1); sig2 = S(2,2); sig3 = S(3,3);
                            a = dirPla*V(:,1); b = dirPla*V(:,2); c = dirPla*V(:,3);
                            minObjFunAlt = sig1^2*a^2 + sig2^2*b^2 + sig3^2*c^2;
            
                        if (minObjFunAlt < minObjFun)
                            disp('***L2C plane: Rocking condnition on EDGE found.***')
                            cond = "edge";
                            minObjFun = minObjFunAlt;
                            pnt = cent; % Centroid of current edge being considered
                            dir = cross([lin.dir 0]*inv(R2), vect/norm(vect)); % Cross of edge vect and dir along L2C line is direction normal out of material
                            kPla = [kVert1; kVert2];
                        end
                    end
                end
            
                % F. Format output by undoing first rotation and tranlsation
                pla.pnt = pnt*inv(R) + centData;
                pla.dir = dir*inv(R);
                pla.data = data;
                [X, Y, Z] = calcPlaneBoundingPnts(data,pla.pnt,pla.dir,1); 
                plaCorners = [[X; X(1)], [Y; Y(1)], [Z; Z(1)]]; 
            
                residuals = (data - pla.pnt) * pla.dir.';
                sigma = std(residuals);
            
                fitInfo = struct( ...
                    'method', "ConvexHullRockingSVD", ...
                    'criterion', "ConstrainedLeastSquares", ...
                    'description', "One-sided constrained L2 plane fit using outward hull facet selection with facet/edge/point rocking checks.", ...
                    'refDir', opts.refDir, ...
                    'kFacet', kFacet, ...
                    'kPla', kPla, ...
                    'condition', cond, ...
                    'hullTriangulation', k, ...
                    'residualType', "signed orthogonal point-to-plane distance");
            
                fitResult = struct( ...
                    'pnt', pla.pnt, ...
                    'dir', pla.dir, ...
                    'sigma', sigma, ...
                    'residuals', residuals, ...
                    'fitInfo', fitInfo);
            end

        function fitResult = fitData(data, fitCriterion, opts)
            % FITDATA Dispatch plane fitting to the method associated with the selected fit criterion.
            %
            %   Syntax
            %     fitResult = Plane.fitData(data, fitCriterion, opts)
            %
            %   Input Arguments
            %     data - Measured 3D point coordinates
            %       Nx3 double matrix
            %     fitCriterion - Fitting criterion
            %       fitType enumeration
            %     opts - Options structure
            %       struct
            %
            %   Output Arguments
            %     fitResult - Standardized plane fit result
            %       struct
            %
            %   Example
            %     fitResult = Plane.fitData(data, fitType.LeastSquares, opts);

            switch fitCriterion
                case fitType.LeastSquares
                    fitResult = Plane.fitLeastSquares(data, opts);

                case fitType.ConstrainedLeastSquares
                    fitResult = Plane.fitConstrainedLeastSquares(data, opts);

                case fitType.ConstrainedMinimumTotalDistance
                    fitResult = Plane.fitConstrainedMinimumTotalDistance(data, opts);

                otherwise
                    error("Plane:UnsupportedFitType", ...
                        "Fit criterion %s is not implemented for Plane.", string(fitCriterion));
            end
        end

        function dir = normalizeNormal(dir)
            % NORMALIZENORMAL Normalize a plane normal vector.
            %
            %   Syntax
            %     dir = Plane.normalizeNormal(dir)
            %
            %   Input Arguments
            %     dir - Plane normal vector
            %       1x3 double vector
            %
            %   Output Arguments
            %     dir - Unit normal vector
            %       1x3 double vector
            %
            %   Example
            %     dir = Plane.normalizeNormal([1 2 3]);
            
            dir = dir / norm(dir);
        end
    end
end

