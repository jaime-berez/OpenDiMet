function [direction, residual, resnorm] = Flatness(feature)
%FLATNESS Function to calculate the direction for a plane fit for
%flatness evaluation.

    if isa(feature, "Plane")
        data = feature.data;
        point = feature.point;
        dGuess = feature.direction;

        [xD,yD,zD] = separateData(data);
    
        % Format objective function
        fcn = @(q) q(1)*(xD-point(1))+q(2)*(yD-point(2))+q(3)*(zD-point(3)); %my function
        %fcn = @(q) (zD)-q(1)*(xD)-q(2)*(yD)-q(3); %Function from Cai et al, 2009
    
        % Perform optimization algorithm
    
        % OPTION 1: USE lsqnonlin()
        %options = optimoptions(@lsqnonlin,'Algorithm','levenberg-marquardt','StepTolerance',1e-14,'FunctionTolerance',1e-14,'Display','off');
        %[answ,resnorm,residual] = lsqnonlin(fcn,dGuess,[],[],options);
    
        % OPTION 2: Use the custom LM algorithm
        [answ,resnorm,residual] = LM.solve(fcn,dGuess,5000,1e-10);
        
        direction= answ/norm(answ);

    else
        error("Flatness:UnsupportedGeometry", ...
            "Flatness is only implemented for Plane. Got feature of type '%s'", class(feature))
    end
end