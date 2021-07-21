function [exitCode] = pgp_train(X, y, spotID, strLabel)
exitCode = 0;

global MaxComponents
global AutoScale
global Bagging
global NumberOfBags
global CrossValidation
global Optimization
global OutputFile
global Permutations


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


if ~isempty(OutputFile)
    pgp_io_save_results(cvRes, aTrainedPls, perMcr, perCv, spotID);
    
end

end