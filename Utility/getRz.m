function Rz = getRz(direction)
%GETRZ Rotation matrix to align with [0 0 1]
a=direction(1); b=direction(2); c=direction(3);
z = [0,0,1];
% Make scalar logical
if all(round(abs(direction),6) == z)
    Rz = eye(3);
    return
end
% If c is negative, inverse the sign of a
% if c<0
%     a=-a;
% end
Rz = [1-(a^2/(1+c)), -(a*b)/(1+c),   a;...
     -(a*b)/(1+c),    1-(b^2/(1+c)), b;...
     -a,              -b,            c];
end
