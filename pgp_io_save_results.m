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
if ~isempty(objName)
    jsonStr = cat(2, jsonStr,'"obj_name":"', objName,'",');
end
jsonStr = cat(2, jsonStr,'"obj_type":"', class(objData),'",');

if isobject(objData) 
    if length(objData) == 1
        jsonStr = cat(2, jsonStr,'"obj_data":');
        jsonStr = add_object( jsonStr, '', objData, false );
        
    else
        % ARRAY of objects
        % Give it a name  for identification later
        jsonStr = cat(2, jsonStr,'"', class(objData), '_array":[');
        for i = 1:length(objData)

            jsonStr = add_object( jsonStr, 'obj_data', objData(i),  i < length(objData) );
        end
        
        jsonStr = cat(2, jsonStr,']');
    end
else
    vals     = objData;
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
        % Scalar value
        jsonStr = add_val(jsonStr, vals, false);
    end
end

end





% Add a MATLAB Object (structure only, so far)
function jsonStr = add_object( jsonStr, objName, objData, addComma )
jsonStr = cat(2, jsonStr, '{');
if ~isempty(objName)
    jsonStr = cat(2, jsonStr,'"obj_name":"', objName,'",');
end

fieldNames = fieldnames(objData);
nFields    = length(fieldNames);

for i = 1:nFields
    jsonStr = cat(2, jsonStr,'"',  fieldNames{i} ,'_datatype":"', class( objData.(fieldNames{i}) ), '",');
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
            jsonStr = add_object(jsonStr, class(vals), vals, i < nFields);
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

jsonStr = cat(2, jsonStr, '}');

if addComma == true
    jsonStr = cat(2, jsonStr, ',');
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

if ischar(vals) || strcmpi(class(vals), 'nominal')
    jsonStr = add_string(jsonStr, char(vals), comma);
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

if floor(val) == val %Integer number (not necessarily the int class)
    jsonStr = cat(2, jsonStr, sprintf('%d',val));
else
    jsonStr = cat(2, jsonStr, sprintf('%.16f',val));
end

if addComma == true
    jsonStr = cat(2, jsonStr, ',');
end

end


function strOut = json_prettyprint(strIn)

nChar   = length(strIn);

strOut  = repmat('', nChar*10, 1);
outK    = 1;

isArray = 0;
nTabs   = 0;
for i = 1:nChar
    
    if strIn(i) == '['
        isArray = 1;
    end
    
    if strIn(i) == ']'
        isArray = 0;
    end
    
    if strIn(i) == '{'
        
        strOut(outK) = '{'; outK = outK + 1;
        strOut(outK) = newline; outK = outK + 1;
        nTabs = nTabs + 1;
    elseif strIn(i) == '}'
        strOut(outK) = newline; outK = outK + 1;
        strOut(outK) = '}'; outK = outK + 1;
        nTabs = nTabs - 1;
    elseif strIn(i) == ','
        if isArray
            strOut(outK) = ','; outK = outK + 1;
        else
            strOut(outK) = ','; outK = outK + 1;
            strOut(outK) = newline; outK = outK + 1;
            
        end
    else
        if outK > 1 && strcmp(strOut(outK-1),newline) == 1
            for w = 1:nTabs
                for j = 1:4
                    strOut(outK) = ' '; outK = outK + 1;
                end
            end
        end
        
        strOut(outK) = strIn(i); outK = outK + 1;
    end
    
end

strOut = strOut(1:(outK-1));

end