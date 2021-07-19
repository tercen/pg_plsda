function props = operatorProperties()
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

props = {   'MaxComponents', 10, {'The maximal number of PLS components to use'}; ...
            'AutoScale', {'No', 'Yes'}, {'Autoscale Spot values?'}; ...
            'Bagging', {'None', 'Balance', 'Bootstrap', 'Jackknife'}, {'Type of bagging'}; ...
            'NumberOfBags', 24, {'Number of bags to use when bagging is applied'}; ...
            'CrossValidation',{'LOOCV', '10-fold', '20-fold', 'none'}, {'Cross validation type'}; ...
            'Optimization', {'auto', 'LOOCV', '10-fold', '20-fold','none'}, {'Cross validation type for model optimization'}; ...
            'Permutations', 0, {'Number of label permutations to run'}; ...
            'SaveClassifier', {'No', 'Yes'}, {'Save the classifier to disk?'};
            'ShowResultsMode', {'Advanced', 'Basic'}, {'Set to Basic to suppress advanced output'};
        };
     
            