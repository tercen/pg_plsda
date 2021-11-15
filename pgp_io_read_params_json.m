function [ exitCode] = pgp_io_read_params_json(jsonFile)
exitCode = 0;

global data
global metaData
global MaxComponents
global AutoScale
global Bagging
global NumberOfBags
global CrossValidation
global Optimization
global Permutations
global OutputFileVis
global OutputFileDat
global QuantitationType


% Default Values
CrossValidation = '10-fold';
AutoScale       = false;
MaxComponents   = 1;
NumberOfBags    = 24;
Bagging         = 'Balance';
Optimization    = 'auto';
Permutations    = 0;
OutputFileVis      = '';
OutputFileDat      = '';
QuantitationType = 'median';


if ~exist(jsonFile, 'file')
    exitCode = -1;
    pgp_util_error_message(exitCode, jsonFile);
    return
end


% Read JSON file into a string
fid = fopen(jsonFile);
raw = fread(fid, inf);
str = char(raw');
fclose(fid);


try
    jsonParams = jsondecode(str);
    
    
    data        = table();
    metaData    = cell(0, 2);
    paramIdx    = 1;
    bValueFound = false;
    
    rowFactor = '';
    colFactor = '';
    
    for i = 1:length(jsonParams)
        param = jsonParams{i};
        isDataObj = isfield(param, 'name' ) && ...
            isfield(param, 'type' ) && ...
            isfield(param, 'data' );
        
        if isDataObj == true
            
            data.(param.name)    = param.data;
            metaData{paramIdx,1} = param.name;
            metaData{paramIdx,2} = param.type;
            
            if strcmpi( param.type, 'value' )
                if bValueFound == false
                    data.value = param.data;
                    bValueFound = true;
                else
                    exitCode = -12;
                    pgp_util_error_message(exitCode);
                end
            end
            
            paramIdx = paramIdx +1;
        else
            param = internal_sfield_to_upper(param);
            
            if isfield(param, 'ROWFACTOR')
                rowFactor = strrep(param.ROWFACTOR, '.', '_');
            end
            
            if isfield(param, 'COLFACTOR')
                colFactor = strrep(param.COLFACTOR, '.', '_');
            end
            
            if isfield(param, 'QUANTITATIONTYPE')
                QuantitationType = param.QUANTITATIONTYPE;
            end
            
            if isfield(param, 'CROSSVALIDATION')
                CrossValidation = param.CROSSVALIDATION;
                
                isValid = ischar(CrossValidation) && ...
                    (strcmpi(CrossValidation, 'LOOCV') || ...
                    strcmpi(CrossValidation, '10-fold') || ...
                    strcmpi(CrossValidation, '20-fold') || ...
                    strcmpi(CrossValidation, 'none'));
                
                if ~isValid
                    exitCode = -11;
                    pgp_util_error_message(exitCode, 'CrossValidation');
                    pgp_util_error_message(-111, sprintf('LOOCV, [10-fold], 20-fold, none'));
                end
            end
            
            if isfield(param, 'AUTOSCALE')
                AutoScale = param.AUTOSCALE;
                
                isValid = ischar(AutoScale) && ...
                    (strcmpi(AutoScale, 'Yes') || ...
                    strcmpi(AutoScale, 'No'));
                
                if ~isValid
                    exitCode = -11;
                    pgp_util_error_message(exitCode, 'AutoScale');
                    pgp_util_error_message(-111, sprintf('Yes or [No]'));
                end
            end
            
            if isfield(param, 'MAXCOMPONENTS')
                MaxComponents = param.MAXCOMPONENTS;
                
                isValid = isnumeric(MaxComponents) && MaxComponents > 0;
                
                if ~isValid
                    exitCode = -11;
                    pgp_util_error_message(exitCode, 'MaxComponents');
                end
            end
            
            
            if isfield(param, 'BAGGING')
                Bagging = param.BAGGING;
                
                isValid = ischar(Bagging) && ...
                    (strcmpi(Bagging, 'None') || ...
                    strcmpi(Bagging, 'Balance') || ...
                    strcmpi(Bagging, 'Bootstrap') || ...
                    strcmpi(Bagging, 'Jackknife'));
                
                if ~isValid
                    exitCode = -11;
                    pgp_util_error_message(exitCode, 'Bagging');
                    pgp_util_error_message(-111, sprintf('None, [Balance], Bootstrap, Jackknife'));
                end
            end
            
            if isfield(param, 'NUMBEROFBAGS')
                NumberOfBags = param.NUMBEROFBAGS;
                
                isValid = isnumeric(NumberOfBags) && NumberOfBags > 0;
                
                if ~isValid
                    exitCode = -11;
                    pgp_util_error_message(exitCode, 'NumberOfBags');
                end
            end
            
            
            if isfield(param, 'OPTIMIZATION')
                Optimization = param.OPTIMIZATION;
                
                isValid = ischar(Optimization) && ...
                    (strcmpi(Optimization, 'auto') || ...
                    strcmpi(Optimization, 'LOOCV') || ...
                    strcmpi(Optimization, '10-fold') || ...
                    strcmpi(Optimization, '20-fold') || ...
                    strcmpi(Optimization, 'none'));
                
                if ~isValid
                    exitCode = -11;
                    pgp_util_error_message(exitCode, 'Optimization');
                    pgp_util_error_message(-111, sprintf('[None], LOOCV, 10-fold, 20-fold, Auto'));
                end
            end
            
            
            if isfield(param, 'PERMUTATIONS')
                Permutations = param.PERMUTATIONS;
                
                isValid = isnumeric(Permutations) && Permutations >= 0;
                
                if ~isValid
                    exitCode = -11;
                    pgp_util_error_message(exitCode, 'Permutations');
                end
            end
            
            
            if isfield(param, 'OUTPUTFILEVIS')
                OutputFileVis = param.OUTPUTFILEVIS;
                
                isValid = ischar(OutputFileVis) && ...
                    ~isempty(OutputFileVis) && ...
                    ~isfolder(OutputFileVis);
                
                if ~isValid
                    exitCode = -11;
                    pgp_util_error_message(exitCode, 'OutputFileVis');
                end
            end
            
            if isfield(param, 'OUTPUTFILEDAT')
                OutputFileDat = param.OUTPUTFILEDAT;
                
                isValid = ischar(OutputFileDat) && ...
                    ~isempty(OutputFileDat) && ...
                    ~isfolder(OutputFileDat);
                
                if ~isValid
                    exitCode = -11;
                    pgp_util_error_message(exitCode, 'OutputFileDat');
                end
            end
        end
    end
    
catch 
    exitCode = -2;
    pgp_util_error_message(exitCode, jsonFile);
end

if exitCode == 0
    if isempty(rowFactor) || isempty(colFactor) || ...
        ~is_table_col(data, rowFactor) || ~is_table_col(data, colFactor)
        exitCode = -13;
        pgp_util_error_message(exitCode);
        return
    end

    nEntries = size(data, 1);
    
    % Do not sort the unique IDs nor uniqueCols
    uniqueIds  = unique(data.(rowFactor), 'stable');
    uniqueCols = unique(data.(colFactor), 'stable');
        
        
    data.rowSeq = zeros( nEntries, 1);
    data.colSeq = zeros( nEntries, 1);

    
    
    for i = 1:nEntries

        data.rowSeq(i) = internal_find_in_array( data.(rowFactor)(i), uniqueIds  );
        data.colSeq(i) = internal_find_in_array( data.(colFactor)(i), uniqueCols  );

    end
    
       
    metaData{paramIdx,1} = 'rowSeq'; 
    metaData{paramIdx,2} = 'rowSeq'; paramIdx = paramIdx + 1;
    metaData{paramIdx,1} = 'colSeq'; 
    metaData{paramIdx,2} = 'colSeq'; paramIdx = paramIdx + 1;

end
end


function s = internal_sfield_to_upper(s)
% upperfnames: converts all the field names in a structure to upper case
% get the structure field names
fnames = fieldnames(s);

for i = 1:length(fnames)
    fname = fnames{i};

    if ~strcmp(fname, upper(fname))

        s.(upper(fname)) = s.(fname);
        s = rmfield(s, fname);
    end
end
end


function idx = internal_find_in_array(str, strList)

    idx = -1;
    for i = 1:length(strList)
        if strcmp( str, strList{i} )
            idx = i;
            break
        end
    end
end


function bIsCol = is_table_col( tbl, colName )
    bIsCol = any(strcmp(colName,tbl.Properties.VariableNames));
end
