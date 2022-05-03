%function showResults(folder)
function showResults(runDataFile)
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
global DiagnosticPlotPath

%runDataFile = fullfile(folder, 'runData.mat');
if exist(runDataFile, 'file');
    runData = load(runDataFile);
else
    return
end

% check parameter
ShowResultsMode = 'Advanced'; 
titleSz = 18;
lblSz   = 16;
axSz    = 13;

switch ShowResultsMode
    case 'Basic'
        bAdvanced = false;
    case 'Advanced'
        bAdvanced = true;
    otherwise
        error('Invalid value for property ''ShowResultsMode''');
end

% open runfolder
% if bAdvanced
%     try
%         eval(['!open "',runDataFile,'"']);
%     catch
%         msgbox('Error opening run folder', 'PLS-DA show results', 'warn');
%     end
% end
% graph output
fig = figure('Color', 'w','Position', [0,0,1400,1500], 'Renderer', 'painters');

%saveas(fig,'file.png')
models = [runData.cvRes.models];


% Get the number of plots beforehand
nPlots = 0;
if length(unique(runData.cvRes.group)) == 2
    nPlots = nPlots + 1;
end

divPlot = 0;

if bAdvanced
    if length(unique(runData.cvRes.group)) == 2
        nPlots = nPlots + 2;
        % One of the figures is composed by two plots, so first line is
        % divided
        divPlot = 1;
    end
    
    if ~isempty(runData.perCv)
        nPlots = nPlots + 1;
    end
end



% basic output
if length(unique(runData.cvRes.group)) == 2
    %predictions
    if bAdvanced
        subplot(4,2,[1 3]);
    end
    pos = get(gca, 'Position');
    pos(2) = 0.1/2 + 0.55;
    pos(4) = 0.7/2;
    set(gca, 'Position', pos)
    runData.cvRes.pamIndex('waterfall');
    %set(gcf, 'Name', 'Predictions');
    
    
    set(gca, 'linewidth', 2, 'box', 'off');
    set(gca, 'xticklabelrotation', 45, 'fontsize', axSz);
    title('Predictions', 'fontsize', titleSz)
    xlabel( 'Sample #', 'FontSize', lblSz);
    ylabel( 'Prediction', 'FontSize', lblSz);
    
end
% %%

% advanced output
if bAdvanced
%     %%
    if length(unique(runData.cvRes.group)) == 2
        %figure
        
        subplot(4,2,[5 7]);
        pos = get(gca, 'Position');
        pos(2) = 0.2/2;
        pos(4) = 0.7/2;
        set(gca, 'Position', pos)
        runData.cvRes.pamIndex('stack');
        %set(gcf, 'Name', 'Predictions');
        title('Predictions', 'FontSize', titleSz);
        set(gca, 'linewidth', 2, 'box', 'off');
        set(gca, 'fontsize', 14);
        ylabel( 'Prediction', 'FontSize', lblSz);
        %diagnostics
%         %%
        %figure
        %clf;
        subplot(4,2,2);
        
        
        pos = get(gca, 'Position');
        pos(2) = 0.1/2 + 0.74;
        pos(4) = 0.65/4;
        set(gca, 'Position', pos)
        
        
        for i =1:length(models)
            cvBeta(:,i) = median(models(i).beta(2:end,1),3);
        end
        [sBeta,idx] = sort(runData.aTrainedPls.beta(2:end,1));
        h = plot(cvBeta(idx,:)); set(h, 'color', [0.8,0.8,0.8]);
        hold on
        plot(sBeta,'k', 'linewidth',2)
        xlabel('peptide #', 'FontSize', lblSz);
        ylabel('beta', 'FontSize', lblSz);
        title('Model stability','fontsize', titleSz)
        set(gca, 'linewidth', 2, 'box', 'off');
    end
%     %%
    
    subplot(4,2,4);
    
    pos = get(gca, 'Position');
    pos(2) = 0.1/2 + 0.5;
    pos(4) = 0.6/4;
    set(gca, 'Position', pos)
    
    hCvN    = plot([models.n],'o-');
    hold on
    hFinalN = plot( [1,length(models)], [runData.aTrainedPls.n, runData.aTrainedPls.n], 'c', 'linewidth', 2);
    set(gca, 'ylim', [0 MaxComponents]);
    xlabel('CV fold #')
    ylabel('Optimal Nr. of Components')
    legend([hCvN, hFinalN], {'CV', 'final model'})
    %set(gcf, 'Name', 'PLS-DA Diagnostics')
    title('PLS-DA Diagnostics', 'FontSize', titleSz)
    set(gca, 'linewidth', 2, 'box', 'off');
    
    % permutation cdf, if any
    %keyboard
    if ~isempty(runData.perCv)
        uGroups = unique(runData.cvRes.group);
        %figure
        subplot(4,2,[6,8]);
        
        
        
        pos = get(gca, 'Position');
        pos(2) = 0.2/2;
        pos(4) = 0.7/2;
        set(gca, 'Position', pos)
        
        h1 = cdfplot(runData.perMcr);
        set(h1, 'color', 'k')
        hold on
        perPredVal = [runData.perCv.predval];
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
        %set(gcf, 'Name', 'Permutation Results')
        title('Permutation Results', 'FontSize', titleSz)
        set(gca, 'box', 'off', 'LineWidth', 2);
    end
end

set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0 0 23*2 18*2]);


%exportgraphics(fig, DiagnosticPlotPath, 'Resolution', 144);

print('-painters','-dsvg', '-r144', DiagnosticPlotPath)


close all;
end
