function [Xmat, Ymat, Zmat] = mat2xyz(dataMat)

    nCols = length(dataMat) / 2;

    Xmat = zeros(2, nCols);
    Ymat = zeros(2, nCols);
    Zmat = zeros(2, nCols);

    for idx = 1:nCols
        Xmat(1,idx) = dataMat(idx,1);
        Xmat(2,idx) = dataMat(idx+nCols,1);

        Ymat(1,idx) = dataMat(idx,2);
        Ymat(2,idx) = dataMat(idx+nCols,2);

        Zmat(1,idx) = dataMat(idx,3);
        Zmat(2,idx) = dataMat(idx+nCols,3);
    end
end
