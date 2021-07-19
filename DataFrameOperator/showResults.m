function showResults(folder)
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

runDataFile = fullfile(folder, 'runData.mat');
if exist(runDataFile, 'file');
    runData = load(runDataFile);
else
    return
end

% check parameter
switch ShowResultsMode
    case 'Basic'
        bAdvanced = false;
    case 'Advanced'
        bAdvanced = true;
    otherwise
        error('Invalid value for property ''ShowResultsMode''');
end

% open runfolder
if bAdvanced
    try
        eval(['!open "',folder,'"']);
    catch
        msgbox('Error opening run folder', 'PLS-DA show results', 'warn');
    end
end
% graph output
figure
models = [runData.cvRes.models];
% basic output

if length(unique(runData.cvRes.group)) == 2
    %predictions
    runData.cvRes.pamIndex('waterfall');
    set(gcf, 'Name', 'Predictions');
end
% advanced output
if bAdvanced
    if length(unique(runData.cvRes.group)) == 2
        figure
        runData.cvRes.pamIndex('stack');
        set(gcf, 'Name', 'Predictions');
        %diagnostics
        figure
        subplot(2,1,1)
        for i =1:length(models)
            cvBeta(:,i) = median(models(i).beta(2:end,1),3);
        end
        [sBeta,idx] = sort(runData.aTrainedPls.beta(2:end,1));
        h = plot(cvBeta(idx,:)); set(h, 'color', [0.8,0.8,0.8]);
        hold on
        plot(sBeta,'k', 'linewidth',2)
        xlabel('peptide #');
        ylabel('beta');
        title('Model stability','fontsize', 14)
    end
    
    subplot(2,1,2)
    hCvN    = plot([models.n],'o-');
    hold on
    hFinalN = plot( [1,length(models)], [runData.aTrainedPls.n, runData.aTrainedPls.n], 'c', 'linewidth', 2);
    set(gca, 'ylim', [0 MaxComponents]);
    xlabel('CV fold #')
    ylabel('Optimal Nr. of Components')
    legend([hCvN, hFinalN], {'CV', 'final model'})
    set(gcf, 'Name', 'PLS-DA Diagnostics')
    
    % permutation cdf, if any
    %keyboard
    if ~isempty(runData.perCv)
        uGroups = unique(runData.cvRes.group);
        figure
        h1 = cdfplot(runData.perMcr);
        set(h1, 'color', 'k')
        hold on
        perPredVal = [runData.perCvRes.predval];
        cStr = 'brgmcy';j = 0;
        h = nan(length(uGroups),1);
        for i=1:length(uGroups)
            j = j+1;
            if j>length(uGroups)
                j = 1;
            end
            h(i) = cdfplot(perPredVal(i,:));
            set(h(i), 'color', cStr(j))
        end
        legEntries = cellfun(@(x) [x, ' PV'], cellstr(uGroups),'uniform', false );
        [~, catDim] = max(size(legEntries));
        legend( [h1;h], cat(catDim,{'MCR'}, legEntries) );
        xlabel('rate')
        set(gcf, 'Name', 'Permutation Results')
    end
end