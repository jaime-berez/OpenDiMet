function [X,Y,Z] = mat2xyz(matrix)
    len = length(matrix)/2;
    X=zeros(2,len); Y=zeros(2,len); Z=zeros(2,len);
    for i=1:length(X)
        X(1,i)=matrix(i,1);
        X(2,i)=matrix(i+length(X),1);
        Y(1,i)=matrix(i,2);
        Y(2,i)=matrix(i+length(X),2);
        Z(1,i)=matrix(i,3);
        Z(2,i)=matrix(i+length(X),3);
    end
end