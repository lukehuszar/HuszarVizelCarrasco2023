%% INITIALIZE

% clear everything
close all; clear all; clc;

% Add directories to path
addpath(genpath('Data\'));       % Observer raw data and summary dat dir
addpath('Functions\');  % Plotting, modeling & analysis helpers dir
addpath('3rd party toolboxes\'); 
addpath('3rd party toolboxes\cbrewer\'); % color library for plots
addpath(genpath('3rd party toolboxes\VBA-toolbox-master\')); % BMS toolbox

% Set some default figure/display values
set(groot,'defaultFigureColor','w')
set(0,'defaultLineLineWidth',2)
set(0,'defaultAxesFontSize', 12);
set(0, 'DefaultTextFontSize', 10);
set(0, 'DefaultAxesLineWidth',3);
set(0, 'DefaultAxesBox', 'off');
set(groot, 'defaultAxesTickDir', 'out');
set(groot,  'defaultAxesTickDirMode', 'manual');
set(0,'defaultfigureposition', [0 0 1000 1000])

% Color sets to use for plots
cols = cbrewer('qual', 'Set1', 4);
cols2 = cbrewer('qual', 'Set1', 10);

PF = @(x,lvls) x(3) + (1 - x(3) - x(4)).*.5.*erfc(-x(2).*(lvls-x(1))./sqrt(2)); % Cumulative normal function for plotting fits

% A list of the anonymized labels for the 8 observers 
subNames = {'1', '2', '3', '4', '5', '6', '7', '8'}; 

%% Reformat and concat data - NOT REQUIRED
% Function which loads individual observer data, reformats and concats into
% single file. Also exports matrices needed for reported ANOVA/t-tests in
% R.
% The filesares already saved to the Data folder, so this
% doesn't need to be run.
reformatData(subNames);

%% Load main data file
load('appSTMData.mat')

%% FIGURE 3 psychometric function plot (left)
currApp = squeeze(mean(pcf_ord_ALL,1));              % Get mean p(choose first)
currAppSE = withinSubjErrorCorrection(pcf_ord_ALL);  % Get SE of p(choose first) with correction

% Define collectors for cumulative normal fits to mean data
currPFs = nan(3,1e3);                        
currPSEs = nan(1,3);

% Loop through and fit cumulative normal functions to each condition, and
% get PSE
% Fitting the mean in this way is purely for visualization - no statistical
% analysis is done on these fits to the mean data
for sc = 1:3
    cp = fitCumNormalPF(ordC, currApp(sc,:), ones(1,7), [-0.3 0 0.3]);
    currPFs(sc,:) = PF(cp,linspace(-0.8,0.8,1e3));
    currPSEs(sc) = cp(end);
end

% Plot
pfPlot(ordC,currApp,currAppSE,currPFs,currPSEs,cols);

%% FIGURE 3 bar plot (right)
currPSEs = squeeze(mean(params_ord_ALL(:,:,end),1));                       % Get mean PSEs from free fits
currPSEsSE = withinSubjErrorCorrection(squeeze(params_ord_ALL(:,:,end)));  % Get SE of PSEs from free fits
% Mean and SE for first- vs. both-cued PSE
bvf = squeeze(mean(params_ord_ALL(:,1,end)-params_ord_ALL(:,3,end),1));    
bvfSE = withinSubjErrorCorrection(params_ord_ALL(:,1,end)-params_ord_ALL(:,3,end));
% Mean and SE for second- vs. both-cued PSE
bvs = squeeze(mean(params_ord_ALL(:,3,end)-params_ord_ALL(:,2,end),1));
bvsSE = withinSubjErrorCorrection(params_ord_ALL(:,3,end)-params_ord_ALL(:,2,end));
% Mean and SE for first- vs. second-cued PSE
fvs = squeeze(mean(params_ord_ALL(:,1,end)-params_ord_ALL(:,2,end),1));
fvsSE = withinSubjErrorCorrection(params_ord_ALL(:,1,end)-params_ord_ALL(:,2,end));

btwnSEs = [bvf, bvs, fvs; bvfSE, fvsSE, fvsSE]; % Put into a matrix for input to fcn
pseBarPlot(currPSEs,currPSEsSE,btwnSEs,nan,nan,cols); % Plot

%% Run model comparison - NOT REQUIRED
% These functions run the model comparison analysis detailed in the
% manuscript. However, the data files they generate are already saved in
% the data folder, so if you only want to see the plots/data, only execute
% the load function in the following cell

% Model comparison: individual-level
modelComparisonIndividual(subNames,pcf_ord_ALL,ordC);

% Model comparison: group-level
[groupModelRanking,groupModelEPs,posteriorBIC,outBIC,memberPreferenceInds] = modelComparisonGroup(subNames);

%% Load model comparison results
load('modelComparisonGroup.mat','groupModelRanking','groupModelEPs','posteriorBIC','outBIC','memberPreferenceInds');

%% FIGURE 4 in manuscript: model EP from BMS
bmsPlots(subNames,outBIC);

%% FIGURE 5 (LEFT): Best model fit to mean figs
%{
In the model comparison analysis, there is no group-level (mean or meta)
fit - all the analysis is carried out on fits to individual observers.
Here, we provide a visualization of the best-fitting model compared to the 
group average. We do this by taking the best-fitting individual model (a
member of the Persistence family), fitting it to a pooled meta-observer
(all 8 observers grouped together) via 'modelComparisonIndividual', and
then displaying the model output alongside the average p(choose first) data
across observers. This is purely for visualizing the model behavior in a
single, easy to digest plot - we don't use this meta-observer fit for any
analysis.
%}

% Get model output
load('modelComparison_subjALL', 'paramVals')         % Load model comparison fits to pooled meta-subj
xr = linspace(-0.8,0.8,1000);                        % Finely spaced contrast values
bestModel = memberPreferenceInds(1);                 % Define best-fitting model index from sorted vector
currParams = reshape(paramVals(bestModel,:)',5,3)';  % Get param values for best-fitting model
% Define the model anon functions so we can get model output for plotting
pseConst = @(beta,gamma,lambda) ((sqrt(2).*erfcinv((0.5-gamma)./(0.5.*(1-gamma-lambda)))) ./ beta);
PFd = @(x,lvls) x(:,4) + (1 - x(:,4) - x(:,5)).*.5.*erfc(-x(:,3).*(lvls-x(:,2)+x(:,1)-pseConst(x(:,3),x(:,4),x(:,5)))./sqrt(2));
modelPFs = PFd(currParams,repmat(xr,3,1));           % Get model output

% Get average p(choode first) with SE
currApp = squeeze(mean(pcf_ord_ALL,1));
currAppSE = withinSubjErrorCorrection(pcf_ord_ALL);
% Get PSEs by fitting (all free) cumulative normal functions and
% interpolating
currPSEs = nan(1,3);
for sc = 1:3
    cp = fitCumNormalPF(ordC, currApp(sc,:), ones(1,7), [-0.3 0 0.3]);
    currPSEs(sc) = cp(end);
end

% Plot.
% Lines = model output
% Points = group average p(choose first)
pfPlot(ordC,currApp,currAppSE,modelPFs,currPSEs,cols);

%% FIGURE 5 (RIGHT): xPSE and delta
%{
Bar plot of mean + SE of PSE estimates (xPSE) from *each individuals best-fitting
model* (i.e., regardless of what is best at the group level). These are the
PSE estimates without delta (without the preference for the 2nd sitmulus).
The mean + SE delta value is plotted as the horizontal line + shading. xPSE
- delta = 'observed PSE'.
%}

% Define collectors for xPSE and delta
currPSEsI = nan(numel(subNames),3);  
currDeltasI = nan(numel(subNames),3);
% Loop through
for ii = 1:numel(subNames)
   cp = load(['modelComparison_subj' subNames{ii}], 'paramVals', 'bestBICNum');
   currParams = reshape(cp.paramVals(cp.bestBICNum,:),5,3)'; % Get best-fitting model parameters
   currPSEsI(ii,:) = currParams(:,2);                        % Store xPSE values
   currDeltasI(ii,:) = currParams(:,1);                      % Store delta value
end

currPSEsSE = withinSubjErrorCorrection(currPSEsI);      % SE for xPSE
currPSEs = mean(currPSEsI);                             % mean for xPSE
currDeltasSE = std(currDeltasI)./sqrt(numel(subNames)); % SE for delta
currDeltas = mean(currDeltasI);                         % mean for delta

% Plot
pseBarPlot(currPSEs,currPSEsSE,nan,currDeltas,currDeltasSE,cols)