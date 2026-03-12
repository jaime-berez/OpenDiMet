function data = readData(path)
    % READDATA Read coordinate data from a file.
    %
    %   Syntax
    %     data = readData(path)
    %
    %   Description
    %     Reads coordinate data from a file and returns the numeric matrix
    %     containing the data. The file must contain at least three columns,
    %     corresponding to x, y, and z coordinates.
    %
    %     The function automatically selects the appropriate reading method
    %     based on the file extension.
    %
    %   Input Arguments
    %     path
    %         1x1 string - Path to the input data file.
    %         
    %   Output Arguments
    %     data
    %         NxM double
    %         Numeric matrix containing the coordinate data read from the file.
    %         The matrix must contain at least three columns.
    %
    %   Supported File Types
    %     .csv, .txt, .dat, .tsv, .ds
    %         Read using readmatrix with text file parsing.
    %     .xlsx
    %         Read using readmatrix with Excel file parsing.
    %
    %   Example
    %     data = readData("points.csv");
    %     % Use the data for feature fitting
    %     feat = fitFeature(data,"Plane","LeastSquares");

    arguments
        path (1,1) string {mustBeNonempty}
    end

    if ~isfile(path)
        error('readData:FileNotFound', 'File not found: %s', path);
    end
    [~,~,extension] = fileparts(path);

    switch lower(extension)
        case {'.csv', '.txt', '.dat', '.tsv', '.ds'}
            data = readmatrix(path, FileType = "text");
        case '.xlsx'
            data = readmatrix(path);
        otherwise
            data = readmatrix(path, FileType = "text");
    end

    if size(data,2) < 3
        error('readData:TooFewColumns', 'Need atleast 3 columns for coordinate data.');
    end

    if ~isfloat(data) || any(isnan(data(:))) || ~isreal(data)
        error('readData:InvalidData', 'Data must be a real, finite matrix without NaN values.');
    end
end
