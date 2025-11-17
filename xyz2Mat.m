function matrix = xyz2Mat(X,Y,Z)
    matrix = zeros(length(X)*2,3);
    for i=1:length(X)
        matrix(i,1)=X(1,i);
        matrix(i+length(X),1)=X(2,i);
        matrix(i,2)=Y(1,i);
        matrix(i+length(X),2)=Y(2,i);
        matrix(i,3)=Z(1,i);
        matrix(i+length(X),3)=Z(2,i);
    end
end