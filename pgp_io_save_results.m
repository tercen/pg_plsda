function pgp_io_save_results(cvRes, aTrainedPls, perMcr, perCv, spotID)


jsonStr = '[';

jsonStr = cat(2, jsonStr, '{');
jsonStr = append_json_entry(jsonStr, 'cvResults', cvRes);
jsonStr = cat(2, jsonStr, '},');


        
        %     
%     finalModelFile = [];
%     if isequal(SaveClassifier, 'Yes')
%         finalModel = aTrainedPls;
%         
%         % @TODO This will be passsed as parameter
%         [saveName, path] = uiputfile('*.mat', 'Save Classifier As ...');
%         if saveName ~= 0
%             finalModelFile = fullfile(path, saveName);
%             save(finalModelFile, 'finalModel', 'spotID');
%         end
%     end
% 
        % @TODO classifier file needs to be passed as parameter
%         if strcmpi( SaveClassifier, 'yes')
            % Save aTrainedPls and spotID
%         end


% cvRes = 
% 
%   cvResults with properties:
% 
%             title: 'Cross Validation Results'
%       sampleNames: {1×24 cell}
%             group: [24×1 nominal]
%                 y: [22×2 double]
%             cPred: [24×1 nominal]
%             yPred: [24×2 double]
%            models: [10×1 mgPlsda]
%     partitionType: 'kfold'
%             folds: 10

%  mgPlsda with properties:
% 
%         features: [1 2 3 4 5]
%        autoscale: 0
%       predmethod: 'nearest'
%        partition: [1×1 cvpartition]
%        optmetric: 'chisqr'
%          bagging: 'balance'
%     numberOfBags: 24
%             beta: [114×2×24 double]
%        scalePars: [2×113 double]
%                n: 5
%             yFit: [24×2 double]
%            group: [24×1 nominal]
%           uGroup: {2×1 cell}
% 
% perMcr =
% 
%     0.2917
%     0.5417
%     0.4583
%     0.7083
%     0.6250
%     0.5417
%     0.7083
%     0.3333
%     0.2917
%     0.6667

%      
%      perCv =
%  % 10 --> n permutation
%   10×1 cvResults array with properties:
% 
%     title
%     sampleNames
%     group
%     y
%     cPred
%     yPred
%     models
%     partitionType
%     folds


fprintf('rowSeq,colSeq,value,treatment,barcode,quantitation_type,ID\n');

for i = 1:nRows
    for j = 1:nCols
        tableEntry = sprintf('%d,%d,%.5f,%s,%d,median_signal,gene%d', ...
                        i, j,  get_gene_val(geneMu(i), geneSd(i)), ...
                        treatment{j}, barcodes(j), i);
       disp(tableEntry)
    end
end


end

function jsonStr = append_json_entry(jsonStr, objName, objStruct)
    jsonStr = cat(2, jsonStr,'"objName":"', objName,'",');
    
    
    fieldNames = cvRes;
    nFields    = length(fieldNames);
    
    for i = 1:nFields
        jsonStr = cat(2, jsonStr,'"',  fieldNames{i} ,'":');
        
        vals = objStruct.(fieldNames);
        
        if min(size(vals)) > 1
            % @TODO TEST
            
            % Add an array
            [dim1, dim2] = size(vals);
            if dim2 > dim1
                vals = vals';
            end

            jsonStr = add_array( jsonStr, vals, i < nFields  );
        else
            jsonStr = add_val(jsonStr, vals, i < nFields);
        end
        
   
        
    end
 
end

function jsonStr = add_array(jsonStr, vals, addComma)
jsonStr = cat(2, jsonStr, '[');

for k = 1:size(vals,1)
    val = vals(k,:);
    if length(val) == 1
        jsonStr = add_val(jsonStr, val, k < size(vals,1) );
    else
        jsonStr = add_array( jsonStr, val, k < size(vals,1)  );
    end
end
jsonStr = cat(2, jsonStr, ']');

if addComma == true
    jsonStr = cat(2, jsonStr, ',');
end
end

function jsonStr = add_val(jsonStr, vals, comma)

    if ischar(vals)
        jsonStr = add_string(jsonStr, vals, comma);
    end

    if isnumeric(vals)
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