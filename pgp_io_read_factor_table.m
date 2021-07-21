function [dataTable, metaData, exitCode] = pgp_io_read_factor_table(filepath)
%
% filepath='/media/thiago/EXTRALINUX/Upwork/code/pg_plsda/data/FGFR example.txt.csv';
exitCode = 0;
dataTable = [];
metaData = [];
if ~exist(filepath, 'file')
    exitCode = -1;
    pgp_util_error_message(exitCode, filepath);
    return
end
try
    warning 'off';
    dataTable = readtable(filepath, 'VariableNamingRule', 'modify');
    warning 'on';
    
    nEntries = size(dataTable, 1);
    dataTable.QuantitationType = repmat({'median'}, nEntries, 1);
    
    
    uniqueIds  = unique(dataTable.ID);
    uniqueCols = unique(dataTable.Cell_line);
    

    
    dataTable.rowSeq = zeros( nEntries, 1);
    dataTable.colSeq = zeros( nEntries, 1);

    for i = 1:nEntries

        dataTable.rowSeq(i) = find_in_array( dataTable.ID(i), uniqueIds  );
        dataTable.colSeq(i) = find_in_array( dataTable.Cell_line(i), uniqueCols  );

    end

    dataTable.value = dataTable.LFC;
    
    %%
    clc
    fprintf('[');
    for i = 1:size(dataTable,1)
        fprintf('"%s"', dataTable.Response{i});
        
        if i < size(dataTable,1)
            fprintf(', ');
        end
        
        if mod(i, 100) == 0
            fprintf('\n');
        end
    end
    fprintf(']');
    
%     dataTable.color = dataTable.Response;
%%
    % @FIXME Automate the metadata information
    metaData = cell(6, 2);
    metaData{1,1} = 'rowSeq'; metaData{1,2} = 'rowSeq';
    metaData{2,1} = 'colSeq'; metaData{2,2} = 'colSeq';
    metaData{3,1} = 'LFC'; metaData{3,2} = 'value';
    metaData{4,1} = 'Response'; metaData{4,2} = 'color';
    metaData{5,1} = 'Cell_line'; metaData{5,2} = 'array';
    metaData{6,1} = 'ID'; metaData{6,2} = 'Spot';
    


catch
    
    exitCode = -2;
    pgp_util_error_message(exitCode, filepath);
    return
end

end

function idx = find_in_array(str, strList)

    idx = -1;
    for i = 1:length(strList)
        if strcmp( str, strList{i} )
            idx = i;
            break
        end
    end
end

% 
% A direct link on the crosstab projection
% 

% 
% the factor on the rows is "ID"
% 
% the factors on the columns are "Response" and "Cell.line"
% 
% an the color factor is "Response"
% 
% the value (or y axis) is LFC
