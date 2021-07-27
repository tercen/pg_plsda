function pgp_io_save_results(cvRes, aTrainedPls, perMcr, perCv, spotID)
% @TODO Clean up this code
global OutputFileVis;


jsonStr = '[';



jsonStr = cat(2, jsonStr, '{');
jsonStr = append_json_entry(jsonStr, 'cvResults', cvRes);
jsonStr = cat(2, jsonStr, '},');

jsonStr = cat(2, jsonStr, '{');
jsonStr = append_json_entry(jsonStr, 'aTrainedPls', aTrainedPls);
jsonStr = cat(2, jsonStr, '},');

jsonStr = cat(2, jsonStr, '{');
jsonStr = append_json_entry(jsonStr, 'spotID', spotID);
jsonStr = cat(2, jsonStr, '},');

jsonStr = cat(2, jsonStr, '{');
jsonStr = append_json_entry(jsonStr, 'perMcr', perMcr);
jsonStr = cat(2, jsonStr, '},');

jsonStr = cat(2, jsonStr, '{');
jsonStr = append_json_entry(jsonStr, 'perCv', perCv);
jsonStr = cat(2, jsonStr, '}');



jsonStr = cat(2, jsonStr, ']');

% jsonencode(jsonStr)


% jsonTxt = jsonencode(jsonStr);
%

[dirPath, ~, ~] = fileparts(OutputFileVis);

if ~exist(dirPath, 'dir')
    mkdir(dirPath);
end

fid = fopen(OutputFileVis,'w+');

if fid >= 0
    fprintf(fid, json_prettyprint(jsonStr));
    fclose(fid);
end

end

function jsonStr = append_json_entry(jsonStr, objName, objData)
jsonStr = cat(2, jsonStr,'"objName":"', objName,'",');

if isobject(objData)
    
    if length(objData) == 1
        jsonStr = add_object( jsonStr, objData );
    else
        jsonStr = cat(2, jsonStr,'"', class(objData), '_array":[');
        for i = 1:length(objData)
            
            jsonStr = cat(2, jsonStr, '{');
            jsonStr = add_object( jsonStr, objData(i) );
            jsonStr = cat(2, jsonStr, '}');
            
            if  i < length(objData)
                jsonStr = cat(2, jsonStr, ',');
            end
        end
        jsonStr = cat(2, jsonStr,']');
    end
else
    vals = objData;
    
    jsonStr = cat(2, jsonStr,'"data":');
    
    
    if ~ischar(vals) && max(size(vals)) > 1
        
        % Add an array
        [dim1, dim2] = size(vals);
        if dim2 > dim1
            vals = vals';
        end
        
        jsonStr = add_array( jsonStr, vals, false  );
    elseif isempty(vals)
        jsonStr = cat(2, jsonStr,'[]');
    else
        
        jsonStr = add_val(jsonStr, vals, false);
    end
end

end

function jsonStr = add_object( jsonStr, objData )
fieldNames = fieldnames(objData);
nFields    = length(fieldNames);

for i = 1:nFields
    
    jsonStr = cat(2, jsonStr,'"',  fieldNames{i} ,'":');
    
    vals = objData.(fieldNames{i});
    
    if ~ischar(vals) && max(size(vals)) > 1
        
        % Add an array
        [dim1, dim2] = size(vals);
        if dim2 > dim1
            vals = vals';
        end
        
        jsonStr = add_array( jsonStr, vals, i < nFields  );
    else
        if isobject(vals)
            jsonStr = cat(2, jsonStr, '{');
            jsonStr = append_json_entry(jsonStr, class(vals), vals);
            jsonStr = cat(2, jsonStr, '}');
            
            if  i < nFields
                jsonStr = cat(2, jsonStr, ',');
            end
        elseif isempty(vals)
            jsonStr = cat(2, jsonStr,'[]');
            if  i < nFields
                jsonStr = cat(2, jsonStr, ',');
            end
        else
            jsonStr = add_val(jsonStr, vals, i < nFields);
        end
    end
end
end

function jsonStr = add_array(jsonStr, vals, addComma)
jsonStr = cat(2, jsonStr, '[');

for k = 1:size(vals,1)
    val = vals(k,:);
    if ischar(val) || length(val) == 1
        jsonStr = add_val(jsonStr, val, k < size(vals,1) );
    else
        
        [dim1, dim2] = size(val);
        if dim2 > dim1
            val = val';
        end
        jsonStr = add_array( jsonStr, val, k < size(vals,1)  );
    end
end
jsonStr = cat(2, jsonStr, ']');

if addComma == true
    jsonStr = cat(2, jsonStr, ',');
end
end

function jsonStr = add_val(jsonStr, vals, comma)
if iscell(vals) && length(vals) == 1 && ischar(vals{1})
    vals = vals{1};
end

if ischar(vals)
    jsonStr = add_string(jsonStr, vals, comma);
end

if isnumeric(vals) || islogical(vals)
    jsonStr = add_numeric(jsonStr, vals, comma);
end


end

function jsonStr = add_string(jsonStr, str, addComma)
jsonStr = cat(2, jsonStr, '"');
jsonStr = cat(2, jsonStr, str);
jsonStr = cat(2, jsonStr, '"');

if addComma == true
    jsonStr = cat(2, jsonStr, ',');
end

end


function jsonStr = add_numeric(jsonStr, val, addComma)

if floor(val) == val
    jsonStr = cat(2, jsonStr, sprintf('%d',val));
else
    jsonStr = cat(2, jsonStr, sprintf('%.16f',val));
end



if addComma == true
    jsonStr = cat(2, jsonStr, ',');
end

end


function strOut =json_prettyprint(strIn)

nChar   = length(strIn);

isArray = 0;
strOut = '';
nTabs  = 0;
for i = 1:nChar
    
    if strIn(i) == '['
        isArray = 1;
    end
    
    if strIn(i) == ']'
        isArray = 0;
    end
    
    if strIn(i) == '{'
        
        strOut(end+1) = '{';
        strOut(end+1) = newline;
        nTabs = nTabs + 1;
    elseif strIn(i) == '}'
        strOut(end+1) = newline;
        strOut(end+1) = '}';
        
        nTabs = nTabs - 1;
    elseif strIn(i) == ','
        if isArray
            strOut(end+1) = ',';
        else
            strOut(end+1) = ',';
            strOut(end+1) = newline;
            
        end
    else
        
        strOut(end+1) = strIn(i);
    end
    
end

% strOut = strrep(strIn, ',', ',\n');
% add a return character after curly brackets:
% strOut = strrep(strOut, '@', newline);

end