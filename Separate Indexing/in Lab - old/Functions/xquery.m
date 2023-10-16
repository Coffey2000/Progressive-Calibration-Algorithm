function readData = xquery(FID, CMD)
    readData = query(FID, CMD);
    readData(readData == '"') = [];
    readData = str2num(cell2mat(strsplit(readData(1:end-1), ',').'));
end