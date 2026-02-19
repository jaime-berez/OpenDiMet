function matOut = xyz2Mat(Xcoords, Ycoords, Zcoords)

    numPts = length(Xcoords);
    matOut = zeros(numPts*2, 3);

    for i = 1:numPts
        matOut(i,1)           = Xcoords(1,i);
        matOut(i+numPts,1)    = Xcoords(2,i);

        matOut(i,2)           = Ycoords(1,i);
        matOut(i+numPts,2)    = Ycoords(2,i);

        matOut(i,3)           = Zcoords(1,i);
        matOut(i+numPts,3)    = Zcoords(2,i);
    end
end
