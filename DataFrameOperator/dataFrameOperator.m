function [aNumeric, aHeader] = dataFrameOperator(folder)
%PLS-DA Class Prediction 
%Version: 2.5 (MCR R2016A)
%Creator: Rik de Wijn
%Last Modification Date: March 22, 2016
%Support Status: Supported
%Description: Partial Least Squared Discriminant Analysis
%Type: Matlab Operator Step
%Performs partial least squares discriminant analysis. The method has been
%slightly adapted compared to previous versions following some of the
%recommendations in [...]. Multiple group analysis is supported, but
%working with more than 2 groups may not be the main strength of the
%method. 
%The classifier implements a bagging methods for resampling the mode;.
%In particular, for two group classification with unequal group sizes a Random Under Sampling scheme called Balnce is implemented.
%With balance multiple predictors with
%equal group sizes are bagged by drawing a random sample from the larger
%group NumberOfBags times.
%The operator trains a PLS classifier based on the data in the calling
%Bionavigator spreadsheet and known grouping. Training involves determining
%the optimal number of PLS components by (inner) cross validation. The
%classifier may be stored for later use with new data (see
%predict.classification).
%In addition the classifier performance is estimated by (outer) cross validation.
%Here, the optimization of the number of PLS components is repeated for
%each fold of the cross validation using the training set only (double
%cross validation).
%
%INPUT:
%Array data from Bionavigator Spreadsheet with grouping defined using a single DataColor. 
%Using more than a single value per cell results in an error, missing values are not allowed.
%SpotID's have to specified in the BN spreadsheet
%
%PARAMETERS
%1. MaxComponents [10(dft)], the maximum number of PLS-components allowed. 
%2. AutoScale [No(dft), Yes], autoscale spots.
%3. NumberOfBags [24 (dft)]. Number of bags to use when bagging is applied
%4. Bagging. [None, Balance, Bootstrap, Jackknife]
%4. CrossValidation [LOOCV (dft), 10-fold, 20-fold, none]: cross validation type
%5. Optimization [auto (dft), LOOCV, 10-fold, 20-fold, none]. Cross
% validation type for selecting the optimal number of pls components [1:MaxComponents]. With 'auto' the same type of CV as selected with 'CrossValidation'
% is used, unless CrossValidation = 'none' in which case LOOCV is applied.
% With Optimization = 'none', optimization is skipped and MaxComponents is used for building the classifier. 
%6. Permutations [0(dft)], number of label permutations required
%7. SaveClassifer [no(dft), yes], if yes the Operator prompts the user for
%saving the obtained classifier.
%
%OUTPUT (RETURNED TO BIONAVIGATOR):
%Per sample: 
%y<ClassName>, class affinity for each class predicted using the outer
%cross validation, the predicted class is the one with largest affinity.
%pamIndex (2 class prediction only): y predictions converted to the "PamIndex" format.
%Per spot:
%beta(1..N), were N is the number of groups. Relative weights of spots in the class
%prediction rule. Beta(1..N-1) is usually sufficient. These are scaled to unit variance, Therefore do not use these
%weights for predicting new samples, use the complimentary
%predict.classification operator!
%
%OUTPUT (SHOWRESULTS)
%1. Plot of cross validated y predictions in "PamIndex" format (2-group
%classification only)
%2. Diagnostics plot showing the final peptide weights plus the weights
%obtained from the succesive cross validation folds.
%3. Diagnostics plot showing the number of pls components used in the final
%model and in the succesive cross validation folds.
%4. Cumulative distribution plot showing the distribution of error rate and <ClassName> 
%predictive value obtained from label permutations (if any).
%5. Tab delimited text file (.xls, best viewed using MS-Excel) with details on
%classifier performance and cross validated predictions.
global data
global MaxComponents
global AutoScale
global Bagging
global NumberOfBags
global CrossValidation
global Optimization
global Permutations
global SaveClassifier
global ShowResultsMode

warning 'off'
%% input formatting and checking
if length(unique(data.QuantitationType)) ~= 1
    error('PLS-DA cannot handle multiple quantitation types');
end
% predictor matrix
X = flat2mat(data.value, data.rowSeq, data.colSeq)';
if any(isnan(X(:)))
    error('Missing values are not allowed');
end
% response variable
varType     = get(data, 'VarDescription');
varNames    = get(data, 'VarNames');
yName = varNames(contains(varType, 'Color'));
if length(yName) ~= 1 
    error('Grouping must be defined using exactly one data color');
end
yName = char(yName);
y = flat2ColumnAnnotation(data.(yName), data.rowSeq, data.colSeq);
nGroups = length(unique(y));
if nGroups < 2
    error('Grouping must contain at least two different levels');
end
% retrieve spot ID's for later use
bID = strcmp('Spot', varType) & strcmp('ID', varNames);
if sum(bID) ~= 1
    error('Spot ID could not be retrieved')
end
spotID = flat2RowAnnotation(data.ID, data.rowSeq, data.colSeq);
% create sample labels
labelIdx = find(contains(varType, 'Array'));
for i=1:length(labelIdx)
    label(:,i) = nominal(flat2ColumnAnnotation(data.(varNames{labelIdx(i)}), data.rowSeq, data.colSeq));
    % (creating a nominal nicely handles different types of experimental
    % factors)
end
for i=1:size(label,1)
    strLabel{i} =paste(cellstr(label(i,:)), '/');
end
%% initialize cross validation object and pls object
aCv = cv;
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
    otherwise
        error('Invalid value for property ''CrossValidation''');
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
    case 'Balance';
         aPls.bagging = 'balance';
    case 'Bootstrap'
        aPls.bagging = 'bootstrap';
    case 'Jackknife'
        aPls.bagging = 'jackknife';
    otherwise
        error('Invalid value for property ''Bagging''')          
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
    otherwise
        error('Invalid value for property ''Optimization''');
end
%% Train the all sample pls model, if requested open Save dialog
aTrainedPls = aPls.train(X, y);
finalModelFile = [];
if isequal(SaveClassifier, 'Yes')
    finalModel = aTrainedPls;
    [saveName, path] = uiputfile('*.mat', 'Save Classifier As ...');
    if saveName ~= 0
        finalModelFile = fullfile(path, saveName);
        save(finalModelFile, 'finalModel', 'spotID');
    end
end
%% if required perform cross validation
if ~isempty(aCv.partition)
    aCv.model = aPls;
    cvRes = aCv.run(X,y,strLabel);
else
    cvRes = cvResults;
end
%% if required perform permutations
[perMcr, perCv] = aCv.runPermutations(X, y, Permutations);

%% save run data for showResults
save(fullfile(folder, 'runData.mat'), 'cvRes', 'aTrainedPls', 'perMcr', 'perCv');
% text output to file
fname = [datestr(now,30),'CVResults.xls'];
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

%% output formatting for return to BN
aHeader{1} = 'rowSeq';
aNumeric(:,1) = double(data.rowSeq);
aHeader{2} = 'colSeq';
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

