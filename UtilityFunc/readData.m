function data = readData(path)
%READDATA Function to read coordinate data from a file. The function takes
%file path as input, reads the file, and returns a data object as an
%output.

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
