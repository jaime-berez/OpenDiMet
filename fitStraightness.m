function [diameter,residual,resnorm] = fitStraightness(data,poi,dir)
arguments
    data (:,3) {mustBeNumeric}
    poi (1,3) {mustBeNumeric} = mean(data)
    dir (1,3) {mustBeNumeric} = [1 1 1]/norm([1 1 1])
        %dGuess means direction guess
end

[xD,yD,zD] = separateData(data);

%% Format the objective function
    % u = @(q) q(6)*(yD-q(2))-q(5)*(zD-q(3)); % u = (C(yi-y)-B(zi-z))/sqrt(A^2+B^2+C^2)
    % v = @(q) q(4)*(zD-q(3))-q(6)*(xD-q(1)); % v = (A(zi-z)-C(xi-x))/sqrt(A^2+B^2+C^2)
    % w = @(q) q(5)*(xD-q(1))-q(4)*(yD-q(2)); % w = (B(xi-x)-A(yi-y))/sqrt(A^2+B^2+C^2)
    % aNorm = @(q) sqrt(q(4)^2+q(5)^2+q(6)^2); % aNorm = sqrt(A^2+B^2+C^2)
    % f = @(q) sqrt((u(q).^2+v(q).^2+w(q).^2)/(aNorm(q)^2)); %f=sqrt((u^2+v^2+w^2)/aNorm^2)
    % fcn = @(q) f(q)-q(7); %This is the optimization equation used
    
    u = dir(3)*(yD-poi(2))-dir(2)*(zD-poi(3));
    v = dir(1)*(zD-poi(3))-dir(3)*(xD-poi(1));
    w = dir(2)*(xD-poi(1))-dir(1)*(yD-poi(2));
    aNorm = sqrt(dir(1)^2+dir(2)^2+dir(3)^2);
    f = sqrt(u.^2+v.^2+w.^2);
    fcn = @(q) f-q;
%% Guess the "radius" of the cylinder containing all the points of the line
    Rz = getRz(dir);
    data1 = data-poi;
    data2 = data1*Rz;
    rad = guess2dRad(data2);

%% Perform association
    [answ,residual,resnorm]=LM.solve(fcn,rad,5000,1e-20);
    diameter = 2*answ;

