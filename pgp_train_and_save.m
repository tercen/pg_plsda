function [exitCode] = pgp_train(X, y, spotID, strLabel)
exitCode = 0;

global MaxComponents
global AutoScale
global Bagging
global NumberOfBags
global CrossValidation
global Optimization
global OutputFileVis
global OutputFileDat
global Permutations
global data

try
    %% initialize cross validation object and pls object
    aCv         = cv;
    aCv.verbose = true;
    switch CrossValidation
        case 'none'
            %
        case 'LOOCV'
            aCv.partition = cvpartition(y, 'leave');
        case '10-fold'
            aCv.partition = cvpartition(y, 'k', 10);
        case '20-fold'
            aCv.partition = cvpartition(y, 'k', 20);
    end
    
    aPls = mgPlsda;
    aPls.features = 1:MaxComponents; % pls components to try
    if isequal(AutoScale, 'Yes') % autoscaling
        aPls.autoscale = true;
    else
        aPls.autoscale = false;
    end
    
    switch Bagging
        case 'None'
            aPls.bagging = 'none';
        case 'Balance'
            aPls.bagging = 'balance';
        case 'Bootstrap'
            aPls.bagging = 'bootstrap';
        case 'Jackknife'
            aPls.bagging = 'jackknife';
    end
    
    aPls.numberOfBags = NumberOfBags;
    
    switch Optimization
        case 'auto'
            if ~isempty(aCv.partition)
                aPls.partition = aCv.partition;
            else
                aPls.partition = cvpartition(y, 'leave');
            end
        case 'LOOCV'
            aPls.partition = cvpartition(y, 'leave');
        case '10-fold'
            aPls.partition = cvpartition(y, 'k', 10);
        case '20-fold'
            aPls.partition = cvpartition(y, 'k', 20);
        case 'none'
            aPls.features = MaxComponents;
    end
catch
    exitCode = -14;
    pgp_util_error_message(exitCode);
    return
end







if exitCode == 0
    % Train the all sample pls model, if requested open Save dialog
    try
        aTrainedPls = aPls.train(X, nominal(y));
    catch err
        exitCode = -5;
        pgp_util_error_message(exitCode, err.message);
        return
    end
end

if exitCode == 0 && ~isempty(aCv.partition)
    % if required perform cross validation
    aCv.model = aPls;
    try
        cvRes = aCv.run(X,nominal(y),strLabel);
    catch err
        exitCode = -3;
        pgp_util_error_message(exitCode, 'Cross-Validation', err.message);
    end
else
    cvRes = cvResults;
end


perMcr = '';
perCv  = '';

if Permutations > 0
    % if required perform permutations
    try
        [perMcr, perCv] = aCv.runPermutations(X, nominal(y), Permutations);
    catch
        exitCode = -3;
        pgp_util_error_message(exitCode, 'Permutation', err.message);
        return
    end
end

% save run data for showResults
% @TODO see how to best save and show this
%     save(fullfile(folder, 'runData.mat'), 'cvRes', 'aTrainedPls', 'perMcr', 'perCv', 'spotID');


if ~isempty(OutputFileVis) % For visualization
    pgp_io_save_results(cvRes, aTrainedPls, perMcr, perCv, spotID);
end

if ~isempty(OutputFileDat) % For visualization
    % output formatting for return to BN
    aHeader{1}    = 'rowSeq';
    aNumeric(:,1) = double(data.rowSeq);
    aHeader{2}    = 'colSeq';
    aNumeric(:,2) = double(data.colSeq);
    
    lIdx = sub2ind(size(X'), data.rowSeq, data.colSeq); % linear index for converting matrix to flat output
    
    for i=1:length(aTrainedPls.uGroup)
        aHeader{2+i}    = ['beta',char(aTrainedPls.uGroup(i))];
        beta = median(aTrainedPls.beta(2:end,i,:),3); % The median beta is returned when balanceBags are applied
        beta = repmat(beta, 1, size(X,1))/std(beta);
        beta = beta(lIdx);
        aNumeric(:, 2+i) = beta;
    end
    nCols = size(aNumeric,2);
    nGroups = length(aTrainedPls.uGroup);
    if ~isempty(aCv.partition)
        for i=1:length(aTrainedPls.uGroup)
            aHeader{nCols+i} = ['y', char(aTrainedPls.uGroup(i))];
            yPred = repmat(cvRes.yPred(:,i)', size(X,2),1);
            aNumeric(:, nCols + i) = yPred(lIdx);
        end
        if nGroups == 2
            aHeader{size(aNumeric,2)+ 1} = 'PamIndex';
            yPred = repmat(cvRes.yPred(:,2)', size(X,2), 1);
            pamIndex = 2 * yPred -1;
            aNumeric(:, size(aNumeric,2)+1) = pamIndex(lIdx);
        end
    end
    
    tbl = table( aNumeric );
    

    if exist(OutputFileDat, 'file')
        delete( OutputFileDat );
    end
    fid = fopen(OutputFileDat, 'w+');
    for qi = 1:length(aHeader)
        fprintf(fid, '%s', aHeader{qi});

        if qi < length(aHeader)
            fprintf(fid, ',');
        end
    end

    fclose(fid);

    
    
    writetable(tbl, OutputFileDat,'WriteRowNames',false, ...
        'QuoteStrings',true, 'WriteMode','Append');
end

end