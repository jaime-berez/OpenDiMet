function Rz = getRz(dir)
%GETRZ Rotation matrix to align with [0 0 1]
a=dir(1); b=dir(2); c=dir(3);
z = [0,0,1];
% Make scalar logical
if all(round(abs(dir),6) == z)
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
