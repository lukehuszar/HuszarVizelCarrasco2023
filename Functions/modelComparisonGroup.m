function [groupModelRanking,groupModelEPs,posteriorBIC,outBIC,memberPreferenceInds] = modelComparisonGroup(subNames)
%{
Function for running the group-level model comparison detailed in the manuscript.
BIC across observers for each of 64 models is input to the VBA toolbox
(Dauzineau & Rigoux 2014). The function returns a string of the model
families, ordered by preference (groupModelRanking), and a vector of the
corresponding exceedance probabilities (groupModelEPs). The function also
returns the output of VBA's 'VBA_groupBMC' function: posteriorBIC and
outBIC. This information is also saved so the function doesn't need to be
run again if MATLAB is closed.
%}

%% Load necessary variable(s)
load('Data\model comparison results\auxModelComparisonVars','modelCombs')
nmodels = size(modelCombs,2);

%% Get the indeces for all members of each model family
m1i = find(modelCombs(2,:) == 6);     % Persistence model
m2i = find(modelCombs(2,:) == 7);     % Decay model
m3i = find(modelCombs(2,:) == 5);     % Free model
m4i = find(modelCombs(2,:) == 8);     % Fixed model
options.families = {m1i,m2i,m3i,m4i}; % Add families to options for VBA
options.DisplayWin = 0;               % Don't display
options.verbose = 0;                  % Don't print

%% Get BIC scores across all observers
allBIC = nan(nmodels,numel(subNames));   % BIC across all models and observers
alldBIC = nan(nmodels,numel(subNames));  % deltaBIC across all models and observers
% Loop through and collect
for ii = 1:numel(subNames)
    load(['Data\model comparison results\modelComparison_subj' subNames{ii} '.mat'],'BIC','dBIC');
    allBIC(:,ii) = BIC;
    alldBIC(:,ii) = dBIC;
end

%% Run RFX Bayesian model comparison for group studies using BIC
[posteriorBIC,outBIC] = VBA_groupBMC(-alldBIC,options);

%% Get model preference
% Preference by model family
modelNames = {'Persistence', 'Decay', 'Free', 'Fixed'};
[groupModelEPs,inds] = sort(outBIC.families.ep,'descend'); % Sort by EP. Higher EP = more preferred model.
groupModelRanking = modelNames(inds);

% Preference by individual member models
% Sorts models by performance independent of family. We use this to plot
% the best performing model later on.
[~,memberPreferenceInds] = sort(outBIC.ep,'descend'); % Sort by EP. Higher EP = more preferred model.

% Save so we don't have to re-run this script every time
save('Data\model comparison results\modelComparisonGroup.mat','groupModelRanking','groupModelEPs','posteriorBIC','outBIC','memberPreferenceInds');

end