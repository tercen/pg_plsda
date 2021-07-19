function name = columnName(aName, names)
nFound = sum(~cellfun(@isempty, regexp(names, [aName,'.*','|',aName,'_r\d{1,}'])));
if nFound
    aName = [aName,'_r',num2str(nFound)];
    aName = columnName(aName, names);
end
name = aName;
