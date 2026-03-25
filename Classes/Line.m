classdef Line < Feature
    % LINE Fit and represent a straight line from 3D coordinate data.
    %
    %   Syntax
    %     obj = Line(name, data, fitCriterion)
    %     obj = Line(name, data, fitCriterion, Name = Value)
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
    %     obj - Line feature object
    %       Line scalar
    %
    %   Properties
    %     pnt - 1x3 double, point on the fitted line
    %     dir - 1x3 double, unit direction vector of the fitted line
    %     fitInfo - Structure containing fitting method information
    %
    %   Example
    %     L = Line("Line 1", data, fitType.LeastSquares);
    %     L.plot();

    properties (GetAccess = public, SetAccess = private)
        pnt (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        dir (1,3) double {mustBeFinite, mustBeReal, mustBeNonNan, mustBeNonempty}
        fitInfo struct = struct()
    end

    methods
        function obj = Line(name, data, fitCriterion, opts)
            % Constructor for the Line Class
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
        
            opts.refDir = Line.validateRefDir(fitCriterion, opts.refDir);
        
            fitResult = Line.fitData(data, fitCriterion, opts);
        
            obj.pnt = fitResult.pnt;
            obj.dir = fitResult.dir;
            obj.sigma = fitResult.sigma;
            obj.fitInfo = fitResult.fitInfo;
        end

        function varargout = plot(obj, opts)
            % PLOT Plot line coordinate data and fitted line segment.
            %
            %   Syntax
            %     plot(obj)
            %     plot(obj, Name = Value)
            %     h = plot(obj)
            %     h = plot(obj, Name = Value)
            %
            %   Input Arguments
            %     obj - Line feature object
            %       Line scalar
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
            %     fitColor - Color of fitted line
            %       RGB triplet | color name | short color code
            %     fitLabel - Legend label for fitted line
            %       string scalar
            %     lineStyle - Line style for fitted line
            %       string scalar
            %     lineWidth - Line width for fitted line
            %       positive scalar double
            %     ax - Target axes for plotting
            %       matlab.graphics.axis.Axes object
            %
            %   Output Arguments
            %     h - Handle to plotted fitted line
            %         Line object (returned only if requested)
            %
            %   Example
            %     L.plot();
            %     L.plot(fitColor = [0 1 0], lineStyle = "--");

            arguments
                obj
                opts.dataColor = [0 0.4470 0.7410]
                opts.dataLabel (1,1) string = obj.name + " Data"
                opts.dataMarker (1,1) string = "o"
                opts.dataMarkerSize (1,1) double {mustBeFinite,mustBePositive} = 30
                opts.fitColor = [0 1 0]
                opts.fitLabel (1,1) string = obj.name + " Fit"
                opts.lineStyle (1,1) string = "dashdot"
                opts.lineWidth (1,1) double {mustBeFinite,mustBePositive} = 2
                opts.showTitle (1,1) logical = true

                opts.ax = []
            end

            ax = opts.ax;
            if isempty(ax) || ~isvalid(ax)
                ax = gca;
            end

            % Parse styling via feature helpers
            dataColor = obj.parseColor(opts.dataColor);
            fitColor  = obj.parseColor(opts.fitColor);
            fitLS     = obj.parseLineStyle(opts.lineStyle);

            % Geometry
            data = obj.data;
            pnt  = obj.pnt;
            dir  = obj.dir;
            %cla(ax); 
            hold(ax,'on'); axis(ax,'equal'); axis(ax,'padded'); grid(ax,'on'); view(ax,3);

            % Plot the raw data
            % plot3(ax, data(:,1), data(:,2), data(:,3), char(opts.dataMarker), 'Color', dataColor, ...
            %     'MarkerSize', opts.dataMarkerSize, 'DisplayName', opts.dataLabel);
            plotData(data, markerColor = dataColor, markerStyle = char(opts.dataMarker), markerSize = opts.dataMarkerSize, ...
                dataLabel = opts.dataLabel, ax = ax);

            % Plot the centroid point
            plot3(ax, pnt(1), pnt(2), pnt(3), 'xk', 'HandleVisibility', 'off');

            % Calculate the length of the line segment
            len = calcLineLength(data, pnt, dir, 1);

            % Compute the end points of the line
            [pStart, pEnd] = calcFeatExtent(pnt, dir, len, 0.5, 1);

            % Plot the line
            h = plot3(ax, [pStart(1) pEnd(1)], [pStart(2) pEnd(2)], [pStart(3) pEnd(3)], ...
                'LineStyle', fitLS, 'Color', fitColor, 'LineWidth', opts.lineWidth, ...
                'DisplayName', opts.fitLabel);
            if opts.showTitle
                title(ax, opts.fitLabel);
            end
            xlabel(ax,'x'); ylabel(ax,'y'); zlabel(ax,'z');
            legend(ax, "show", 'FontSize', 12);
            hold(ax, "off");
            if nargout > 0
                varargout{1} = h;
            end
        end

        function showFitInfo(obj)
            % SHOWFITINFO Display stored fitting information for the Line object.
            %
            %   Syntax
            %     showFitInfo(obj)
            %
            %   Input Arguments
            %     obj - Line feature object
            %       Line scalar
            %
            %   Example
            %     L.showFitInfo();

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
            % DISP Display a formatted summary of the Line feature object.
            %
            %   Syntax
            %     disp(obj)
            %
            %   Input Arguments
            %     obj - Line feature object
            %       Line scalar
            %
            %   Example
            %     disp(L);

            name = string(obj.name);
            ft   = obj.fitType;
            data = obj.data;

            pnt = obj.pnt;
            dir = obj.dir;
            sig = obj.sigma;

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
            % REVERSEDIR Reverse the orientation of the fitted line direction vector.
            %
            %   Syntax
            %     reverseDir(obj)
            %
            %   Input Arguments
            %     obj - Line feature object
            %       Line scalar
            %
            %   Example
            %     L.reverseDir();
            
            obj.dir = -obj.dir;
        end
    end

    methods (Static, Access = private)
        function refDir = validateRefDir(~, refDir)
            % VALIDATEREFDIR Validate and normalize the reference direction for constrained line fits.
            %
            %   Syntax
            %     refDir = Line.validateRefDir(fitCriterion, refDir)
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
            %     refDir = Line.validateRefDir(fitType.ConstrainedLeastSquares, [0 0 1]);

            if isempty(refDir)
                return
            end
        
            if ~isnumeric(refDir) || ~isequal(size(refDir), [1 3]) || ...
                    any(~isfinite(refDir)) || norm(refDir) <= eps
                error("Line:InvalidRefDir", ...
                    "refDir must be a finite nonzero 1x3 vector.");
            end
        
            refDir = refDir / norm(refDir);
        end

        function fitResult = fitLeastSquares(data, ~)
            % FITLEASTSQUARES Fit a line using unconstrained least-squares association.
            %
            %   Syntax
            %     fitResult = Line.fitLeastSquares(data, opts)
            %
            %   Input Arguments
            %     data - Measured 3D point coordinates
            %       Nx3 double matrix
            %     opts - Options structure
            %       struct
            %
            %   Output Arguments
            %     fitResult - Standardized line fit result
            %       struct
            %
            %   Example
            %     fitResult = Line.fitLeastSquares(data, struct());

            pnt = mean(data);
            dataT = data - pnt;
        
            A = dataT.' * dataT;
            [eigVec, eigValMat] = eig(A);
        
            eigVals = diag(eigValMat);
            [~, idx] = max(eigVals);
        
            dir = eigVec(:, idx).';
            dir = dir / norm(dir);
        
            proj = dataT * dir';
            residuals = vecnorm(dataT - proj * dir, 2, 2);
            sigma = std(residuals);
        
            fitInfo = struct( ...
                'method',"SVD", ...
                'criterion',"LeastSquares", ...
                'description',"Least-squares line fit using eigen-decomposition.");
        
            fitResult = struct( ...
                'pnt', pnt, ...
                'dir', dir, ...
                'sigma', sigma, ...
                'residuals', residuals, ...
                'fitInfo', fitInfo);
        end

        function fitResult = fitConstrainedMinimumTotalDistance(data, opts)
            % FITCONSTRAINEDMINIMUMTOTALDISTANCE Fit a one-sided constrained L1 line.
            %
            %   Syntax
            %     fitResult = Line.fitConstrainedMinimumTotalDistance(data, opts)
            %
            %   Input Arguments
            %     data - Measured 3D point coordinates
            %       Nx3 double matrix
            %     opts - Options structure containing refDir
            %       struct
            %
            %   Output Arguments
            %     fitResult - Standardized line fit result
            %       struct
            %
            %   Example
            %     fitResult = Line.fitConstrainedMinimumTotalDistance(data, opts);
            [cent, e1, e2, e3, data2D] = Line.buildPlanar2DFrame(data);

            if isempty(opts.refDir)
                error("Line:MissingRefDir", ...
                    "refDir must be provided for constrained line fits.");
            end
            refDir = opts.refDir;
            % Project refDir into the fitted plane, then into 2D coordinates
            refDirPlane = refDir - dot(refDir, e3) * e3;
            if norm(refDirPlane) <= 1e-12
                error("Line:DegenerateRefDir", ...
                    "refDir is nearly normal to the data plane. Its in-plane projection is too small for constrained line fitting.");
            end
            refDirPlane = refDirPlane / norm(refDirPlane);
            refDir2D = [dot(refDirPlane, e1), dot(refDirPlane, e2)];
        
            % 0.01. Find the convex hull and the edges of the hull that face 'out'
            kAll = convhull(data2D(:,1), data2D(:,2));
            kAll = kAll(1:end-1); % Remove repeated first/last vertex
        
            vrts  = data2D(kAll,:);
            vrts2 = data2D([kAll(2:end); kAll(1)],:);
            cnts  = (vrts + vrts2)/2;
            vcts  = vrts2 - vrts;
            nrms  = [vcts(:,2), -vcts(:,1)];
            nrms  = nrms ./ vecnorm(nrms, 2, 2);
        
            % Find which hull edges face outward
            thresh = 0.8;
            refDir2D = refDir2D / norm(refDir2D);
            j = find(nrms * refDir2D' > thresh);
        
            if isempty(j)
                error("Line:NoOutwardHullEdges", ...
                    "No outward-facing hull edges were found for the supplied refDir.");
            end
        
            % Find indices in data corresponding to outward-facing edges from left to right
            kTemp = kAll(j);
            xVals = data2D(kTemp,1);
            [~, l] = sort(xVals);
            kSorted = kTemp(l);
        
            posLast = find(kAll == kSorted(end), 1, 'first');
            kLast = kAll(mod(posLast, length(kAll)) + 1);
            k = [kSorted; kLast];
        
            % Create sorted lists for outward-facing chain
            vrts  = data2D(k,:);
            cnts  = cnts(j(l),:);
            vcts  = vcts(j(l),:);
            lens  = vecnorm(vcts, 2, 2);
            nrms  = nrms(j(l),:);
        
            % 02. Choose the edge nearest the total centroid
            cntHull  = sum(cnts .* lens, 1) / sum(lens);
            distVcts = cnts - cntHull;
            distNrms = dot(nrms, distVcts, 2);
            [~, idxMin] = min(abs(distNrms));
            kEdge = k([idxMin, idxMin+1]);
        
            % 03. Build L1C line object in 2D
            lin.pnt = cnts(idxMin,:);
            lin.dir = vcts(idxMin,:);
            lin.dir = lin.dir / norm(lin.dir);
            lin.data = data2D;
        
            % Rotate data to find extreme points for plotting span
            R2 = [-refDir2D(2), -refDir2D(1); refDir2D(1), -refDir2D(2)];
            data0 = data2D * R2;
            [~, iMinX] = min(data0(:,1));
            [~, iMaxX] = max(data0(:,1));
        
            magLeft  = norm(lin.pnt * R2 - data0(iMinX,:));
            magRight = norm(data0(iMaxX,:) - lin.pnt);
        
            linEndPnts = ([lin.pnt * R2 - lin.dir * magLeft; ...
                           lin.pnt + lin.dir * magRight]) / R2; %#ok<NASGU>
        
            % Lift 2D fit back to 3D
            pnt = cent + lin.pnt(1) * e1 + lin.pnt(2) * e2;
            dir = lin.dir(1) * e1 + lin.dir(2) * e2;
            dir = dir / norm(dir);
        
            % Compute 3D orthogonal residuals
            dataCtr = data - pnt;
            proj = dataCtr * dir';
            residuals = vecnorm(dataCtr - proj * dir, 2, 2);
            sigma = std(residuals);
        
            fitInfo = struct( ...
                'method', "ConvexHullEdgeSelection", ...
                'criterion', "ConstrainedMinimumTotalDistance", ...
                'description', "Planar constrained L1 line fit using outward convex hull edge selection in a local 2D frame.", ...
                'refDir', refDir, ...
                'refDir2D', refDir2D, ...
                'planeCentroid', cent, ...
                'planeBasisE1', e1, ...
                'planeBasisE2', e2, ...
                'planeNormal', e3, ...
                'hullIndices', k, ...
                'supportIndices', kEdge, ...
                'residualType', "orthogonal point-to-line distance");
        
            fitResult = struct( ...
                'pnt', pnt, ...
                'dir', dir, ...
                'sigma', sigma, ...
                'residuals', residuals, ...
                'fitInfo', fitInfo);
        end

        function fitResult = fitConstrainedLeastSquares(data, opts)
            % FITCONSTRAINEDLEASTSQUARES Fit a one-sided constrained L2 line.
            %
            %   Syntax
            %     fitResult = Line.fitConstrainedLeastSquares(data, opts)
            %
            %   Input Arguments
            %     data - Measured 3D point coordinates
            %       Nx3 double matrix
            %     opts - Options structure containing refDir
            %       struct
            %
            %   Output Arguments
            %     fitResult - Standardized line fit result
            %       struct
            %
            %   Example
            %     fitResult = Line.fitConstrainedLeastSquares(data, opts);
            [cent, e1, e2, e3, data2D] = Line.buildPlanar2DFrame(data);
            if isempty(opts.refDir)
                error("Line:MissingRefDir", ...
                    "refDir must be provided for constrained line fits.");
            end
            refDir = opts.refDir;
            % Project refDir into the fitted plane, then into 2D coordinates
            refDirPlane = refDir - dot(refDir, e3) * e3;
            if norm(refDirPlane) <= 1e-12
                error("Line:DegenerateRefDir", ...
                    "refDir is nearly normal to the data plane. Its in-plane projection is too small for constrained line fitting.");
            end
            refDirPlane = refDirPlane / norm(refDirPlane);
            refDir2D = [dot(refDirPlane, e1), dot(refDirPlane, e2)];
            
            % 0. Prep
            % 0.00. Translate data centroid to origin, rotate to point refDir (out) in -Y (down)
            % Hull of _out-facing_ surface is now _under_ the data
            centData = mean(data2D);
            refDir2D = -refDir2D/norm(refDir2D); % Normalize, flip
            R = [refDir2D(2) refDir2D(1); -refDir2D(1) refDir2D(2)]; % R s/t refDir points -Y
            data2D = (data2D - centData)*R;
            
            % 0.01. Find the convex hull and the edges of the hull that face 'out'
            kAll = convhull(data2D(:,1),data2D(:,2)); % Indices of data that are verts on conv hull
            kAll = kAll(1:end-1); % Remove last entry which is a repeat of first
            vrts = data2D(kAll,:); % List of hull verts in clockwise order
            vrts2 = data2D([kAll(2:end); kAll(1)],:); % Indexed over one, including first point added to end
            cnts = (vrts + vrts2)/2;
            vcts = vrts2 - vrts; % Pointing in clockwise direction
            nrms = [vcts(:,2) -vcts(:,1)]; % Normal to each edge, pointing out
            nrms = nrms./sqrt(nrms(:,1).^2 + nrms(:,2).^2); % Normalize to unit vector
            % Find which verts on conv hull correspond to edges that face out
            thresh = -0.8;
            j = find(nrms(:,2) < thresh);
            % Find indices in data that correspond to out-facing edges from left to right
            kTemp = kAll(j); % Not sorted, does not proceed from left to right
            xVals = data2D(kTemp,1);
            [~, l] = sort(xVals); % l is indices of kTemp in ascending x order
            kSorted = kTemp(l); % Sorted, but missing index for end point of last edge
            kLast = kAll(mod(find(kAll == kSorted(end), 1, 'first'), length(kAll)) + 1); % Mod to loop around to first element if needed
            k = [kSorted; kLast]; % Sorted, includes last vertex
            % Create sorted lists of verts, cents, vects, and norms for n out-facing edge
            vrts = data2D(k,:); % n+1 verts
            cnts = cnts(j(l),:); % n cents
            vcts = vcts(j(l),:); % n vects
            nrms = nrms(j(l),:); % n norms
            
            % 1. Consider candidate L through two verts of hull
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
            pnt2D = cnts(idxObjFun,:);
            kLin = k([idxObjFun; idxObjFun + 1]);
            kEdge = kLin;
            dir2D = nrms(idxObjFun,:);
            dir2D = [-dir2D(2) dir2D(1)]; % Dir is pointing right along line
            cond = "edge";
            
            % 2. Consider a rocking condition, a plane through point
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
                        dir2D = dirLin; % Set equal to candidate direction
                        pnt2D = vert; % Set equal to candidate vert
                        kLin = k(idx);
                        cond = "point";
                        %disp('***L2C line: Rocking condition on point found***')
                    end
                end
            end
            
            % F. Format output
            % F.1 Find edges of data so that ends points of the fit line may be determined
            [~, iMinX] = min(data2D(:,1)); [~, iMaxX] = max(data2D(:,1));
            magLeft = norm(pnt2D - data2D(iMinX,:)); 
            magRight = norm(data2D(iMaxX,:) - pnt2D); % Dist b/w L2C point and ends of data set
            % F.2 Set end points of L2C plane
            linEndPnts = ([pnt2D - dir2D*magLeft;...
                pnt2D + dir2D*magRight]...
                )/R + centData; % Two points on L2C plane spanning entire data set
            % F.3 Set L2C point and dir
            lin.pnt = pnt2D/R + centData; % Uses mid point or vertex
            lin.dir = dir2D/R; % Uses edge direction (along) or L2 dir (along)
            lin.data = data2D;
        
            % Lift local 2D fit back to 3D
            pnt = cent + lin.pnt(1)*e1 + lin.pnt(2)*e2;
            dir = lin.dir(1)*e1 + lin.dir(2)*e2;
            dir = dir / norm(dir);
            
            dataCtr = data - pnt;
            proj = dataCtr * dir';
            residuals = vecnorm(dataCtr - proj * dir, 2, 2);
            sigma = std(residuals);
            
            fitInfo = struct( ...
                'method', "ConvexHullRockingSVD", ...
                'criterion', "ConstrainedLeastSquares", ...
                'description', "Planar constrained L2 line fit using outward hull edge selection with edge/point rocking checks.", ...
                'refDir', refDir, ...
                'refDir2D', refDir2D, ...
                'planeCentroid', cent, ...
                'planeBasisE1', e1, ...
                'planeBasisE2', e2, ...
                'planeNormal', e3, ...
                'hullIndices', k, ...
                'supportIndices', kLin, ...
                'candidateEdge', kEdge, ...
                'condition', cond, ...
                'residualType', "orthogonal point-to-line distance");
            
            fitResult = struct( ...
                'pnt', pnt, ...
                'dir', dir, ...
                'sigma', sigma, ...
                'residuals', residuals, ...
                'fitInfo', fitInfo);
        end

        function [cent, e1, e2, e3, data2D] = buildPlanar2DFrame(data)
            % BUILDPLANAR2DFRAME Construct a local planar 2D coordinate frame from 3D line data.
            %
            %   Syntax
            %     [cent, e1, e2, e3, data2D] = Line.buildPlanar2DFrame(data)
            %
            %   Input Arguments
            %     data - Measured 3D point coordinates
            %       Nx3 double matrix
            %
            %   Output Arguments
            %     cent - Centroid of the input data
            %       1x3 double vector
            %     e1 - First in-plane basis direction
            %       1x3 double unit vector
            %     e2 - Second in-plane basis direction
            %       1x3 double unit vector
            %     e3 - Plane normal direction
            %       1x3 double unit vector
            %     data2D - Coordinates of the data expressed in the local planar frame
            %       Nx2 double matrix
            %
            %   Example
            %     [cent, e1, e2, e3, data2D] = Line.buildPlanar2DFrame(data);
            
            % Centroid
            cent = mean(data, 1);
            data0 = data - cent;
        
            % PCA/SVD basis
            [~, S, V] = svd(data0, 0);
        
            singVals = diag(S);
            if numel(singVals) < 3
                error("Line:InsufficientRank", ...
                    "At least three coordinates are required to determine a planar frame.");
            end
        
            % e1, e2 span the best-fit plane; e3 is plane normal
            e1 = V(:,1).';
            e2 = V(:,2).';
            e3 = V(:,3).';
        
            % Planarity check: third singular value must be tiny
            % compared with in-plane spread
            planarTol = 1e-8;
            scale = max(singVals(1:2));
            if scale <= eps
                error("Line:DegenerateData", ...
                    "Input data has insufficient spread to define a constrained line fit.");
            end
        
            if singVals(3) / scale > planarTol
                error("Line:NonPlanarConstrainedFit", ...
                    "Constrained line fits currently support only planar datasets. The input data is not sufficiently planar.");
            end
        
            % 2D coordinates in the fitted plane
            data2D = [data0 * e1.', data0 * e2.'];
        end

        function fitResult = fitData(data, fitCriterion, opts)
            % FITDATA Dispatch line fitting to the method associated with the selected fit criterion.
            %
            %   Syntax
            %     fitResult = Line.fitData(data, fitCriterion, opts)
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
            %     fitResult - Standardized line fit result
            %       struct
            %
            %   Example
            %     fitResult = Line.fitData(data, fitType.LeastSquares, opts);
        
            switch fitCriterion
                case fitType.LeastSquares
                    fitResult = Line.fitLeastSquares(data, opts);
        
                case fitType.ConstrainedLeastSquares
                    fitResult = Line.fitConstrainedLeastSquares(data, opts);
        
                case fitType.ConstrainedMinimumTotalDistance
                    fitResult = Line.fitConstrainedMinimumTotalDistance(data, opts);
        
                otherwise
                    error("Line:UnsupportedFitType", ...
                        "Fit criterion %s is not implemented for Line.", string(fitCriterion));
            end
        end
    end
end
