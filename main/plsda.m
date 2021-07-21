function plsda(arglist)
clc;
    global data
    global metaData
    global MaxComponents
    global AutoScale
    global Bagging
    global NumberOfBags
    global CrossValidation
    global Optimization
    global Permutations
    global SaveClassifier
    global ShowResultsMode

[params, exitCode] = parse_arguments(arglist);

if exitCode == 0
%     pgp_io_read_factor_table(params.infile);
    [ exitCode] = pgp_io_read_params_json(params.infile);
end

if exitCode == 0
    
    [exitCode, X, y, spotID, strLabel] = pgp_data_format();
   
end

if exitCode == 0
    [exitCode] = pgp_train(X, y, spotID, strLabel);
end
    

if exitCode == 0
    %% Train the all sample pls model, if requested open Save dialog
    try
        aTrainedPls = aPls.train(X, nominal(y));
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
        if strcmpi( SaveClassifier, 'yes')
            % Save aTrainedPls and spotID
        end
    catch err
        exitCode = -5;
        pgp_util_error_message(exitCode, err.message);
    end
end
    
if exitCode == 0
    
    % if required perform cross validation
    if ~isempty(aCv.partition)
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
    
    
    % if required perform permutations
    try
        [perMcr, perCv] = aCv.runPermutations(X, nominal(y), Permutations);
    catch
         exitCode = -3;
         pgp_util_error_message(exitCode, 'Permutation', err.message);
    end
    
    % save run data for showResults
    % @TODO see how to best save and show this
%     save(fullfile(folder, 'runData.mat'), 'cvRes', 'aTrainedPls', 'perMcr', 'perCv');


    % text output to file
    % @TODO Will not be saved as such
    fname = [datestr(now,30), 'CVResults.xls'];
    if ~isempty(finalModelFile)
        addInfo = {['The classifier was saved as: ',finalModelFile]};
    else
        addInfo = {'The classifier was not saved'};
    end
    
    fpath = fullfile(folder, fname);
    fid = fopen(fpath, 'w');
    if fid == -1
        error('Unable to open file for writing results')
    end
    try
        cvRes.print(fid, addInfo);
        fclose(fid);
    catch aReportFailure
        fclose(fid);
        error(aReportFailure.message)
    end
    
    
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
end




fprintf('Program finished with error code %d\n', exitCode);

end % END of function pamsoft_grid



function [params, exitCode] = parse_arguments(argline)
    exitCode = 0;
    params   = struct;
    if isempty(argline)
        exitCode = -1000;
        pg_error_message(exitCode);
        return
    end
    
    argStrIdx   = strfind(argline, '--');
    argStrValid = regexp(argline, '--infile=.+', 'ONCE');
    
    if isempty(argStrValid) 
        exitCode = -1000;
        pg_error_message(exitCode);
        return
    end

    % @TODO Create regex validation of the parameter passed to ensure the
    % code below works with the expected format
    
    nArgs     = length(argStrIdx);

    for i = 1:nArgs-1
        arg = argline(argStrIdx(i)+2:argStrIdx(i+1)-1);
        arg = strrep(arg, '-', '');
        
        if contains( arg, '=' ) 
            [argName, argVal] = strtok(arg, '=');
        else
            [argName, argVal] = strtok(arg, ' ');
        end
        
        params.(argName) = strtrim(argVal(2:end));
       
    end
    
    arg = argline(argStrIdx(end)+2:end);
    arg = strrep(arg, '-', '');
    
    if contains( arg, '=' ) 
        [argName, argVal] = strtok(arg, '=');
    else
        [argName, argVal] = strtok(arg, ' ');
    end

    params.(argName) = strtrim(argVal(2:end));
end