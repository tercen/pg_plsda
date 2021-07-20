function pgp_io_save_cv_results(cvRes, aTrainedPls, perMcr, perCv)


jsonStr = '[';

jsonStr = cat(2, jsonStr, '{');
jsonStr = append_json_entry(jsonStr, 'rowSeq', 'rowSeq', 1:nRows)
jsonStr = cat(2, jsonStr, '},');

jsonStr = cat(2, jsonStr, '{');
jsonStr = append_json_entry(jsonStr, 'colSeq', 'colSeq', 1:nCols)
jsonStr = cat(2, jsonStr, '},');


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

function jsonStr = append_json_entry(jsonStr, name, type, values)
    jsonStr = cat(2, jsonStr,'"name":"', name,'",');
    jsonStr = cat(2, jsonStr,'"type":"', type,'",');

    jsonStr = cat(2, jsonStr,'"value":[');
    
    for i = 1:length(values)
        if iscell(values)
            val = values{i};
        else
            val = values(i);
        end
        
        if ischar(val)
            jsonStr = cat(2, jsonStr,'"', val, '"');
        elseif is_int(val)
            jsonStr = cat(2, jsonStr, sprintf('%d', val));
        else
            jsonStr = cat(2, jsonStr, sprintf('%.5f', val));
        end
        
        if i < length(values)
            jsonStr = cat(2, jsonStr, ',');
        else
            jsonStr = cat(2, jsonStr, ']');
        end
    end
%     jsonStr = '"value":"rowSeq",';
end