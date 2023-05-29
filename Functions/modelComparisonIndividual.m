function [] = modelComparisonIndividual(subNames,pcf_ord_ALL,ordC)
%{
Function for running the per-observer model comparison detailed in the manuscript.
16 nested variants of 4 model families (persistence, decay, free, fixed) are
fit to each observer and ranked based on performance. The models are also
fit to a pooled meta-subject, purely for visualization in FIGURE 5.

All relevant information is saved in a file in the Data folder. These files
are used by the 'modelComparisonGroup'  function for the group-level
model selection process.
%}

%% Define the model and objective function
trialsPerCond = 96; % Needed as constant in objective fcn

% pseConst computes the constant that must be subtracted from the alpha
% parameter to yield the PSE (contrast value at 50% prob to choose first
% stim) - i.e., the constant that converts alpha to xPSE, as described in
% the manuscript and supplemental material.
pseConst = @(beta,gamma,lambda) ((sqrt(2).*erfcinv((0.5-gamma)./(0.5.*(1-gamma-lambda)))) ./ beta);
% PF is the anon function for the model - a modified cumulative normal
% psychometric function. The function takes in x, a matrix of parameters,
% where the rows are the 3 cue conditions and the columns are the 5
% parameters that can be free to vary (delta, alpha/xPSE, beta, gamma,
% lambda); and lvls, which is a vector of contrast levels.
PF = @(x,lvls) x(:,4) + (1 - x(:,4) - x(:,5)).*.5.*erfc(-x(:,3).*(lvls-x(:,2)+x(:,1)-pseConst(x(:,3),x(:,4),x(:,5)))./sqrt(2));
% The objective function used by fmincon - outputs NLL
objFcn = @(x,nChooseFirst) (sum(-sum(log(PF(reshape(x,5,3)',ordC)).*nChooseFirst +...
    log(1-PF(reshape(x,5,3)',ordC)).*(trialsPerCond-nChooseFirst))));

%% Set parameter bounds for fmincon

% [lower bound, start, upper bound] for each parameter
dLim = [-0.4 0 0];   % delta
aLim = [-0.5 0 0.5]; % xPSE/alpha
bLim = [0.5 5 20];   % beta
gLim = [0 0 0.5];    % gamma and lambda

% Allow for different bounds per cue condition. Here, we keep all the
% limits equal since they're liberal and we don't want to bake in any
% assumptions about differences between conditions.
% First cued
alphaLims_F  = aLim;
betaLims_F   = bLim;
deltaLims_F  = dLim;
gammaLims_F  = gLim;
lambdaLims_F = gLim;
% Second cued
alphaLims_S  = aLim;
betaLims_S   = bLim;
deltaLims_S  = dLim;
gammaLims_S  = gLim;
lambdaLims_S = gLim;
% Both cued
alphaLims_B  = aLim;
betaLims_B   = bLim;
deltaLims_B  = dLim;
gammaLims_B  = gLim;
lambdaLims_B = gLim;

% Put all the parameter limits into a matrix for ease of use
paramLims = [...
    deltaLims_F;alphaLims_F;betaLims_F;gammaLims_F;lambdaLims_F;...
    deltaLims_S;alphaLims_S;betaLims_S;gammaLims_S;lambdaLims_S;...
    deltaLims_B;alphaLims_B;betaLims_B;gammaLims_B;lambdaLims_B;...
    ];

% Save the starting values in a vector to use as fixed values for
% parameters that are not allowed to vary (e.g., delta is fixed to 0 if it
% can't vary)
fixedVals = paramLims(:,3);

% Normalize the parameter bounds matrix.
% Parameters are normalized before they are input to fmincon (between 0 and
% 1) to aid with optimization. The normalization is reversed on the output
% of the solver.
bndsN = paramLims;
addVecN = bndsN(:,1); bndsNormN = bndsN - addVecN; 
multVecN = bndsNormN(:,end); bndsNormN = bndsNormN ./ multVecN;
unnormParams = @(addVec, multVec, params) (params' .* multVec') + addVec'; % Function for reversing normalization
startN = bndsNormN(:,2);   % Normalized starting points vector
lowestN = bndsNormN(:,1);  % Normalized lower bounds vector
highestN = bndsNormN(:,3); % Normalized upper bounds vector

%% Define parameter behavior
%{ 
The behavior of a parameter - the conditions where it is free to vary vs
the conditions where it is fixed to some value - is determined by the
boolean vectors defined below. These vectors have 3 values corresponding
to the 3 cue conditions (order = first-, second-, both-cued). 

A value of 1 means the parameter is free to vary for that condition, a value of 0
means the parameter is fixed for that condition. The actual parameter
values are determined later on by the 'getModel' function.

Most of these are used exclusively for the xPSE parameter, because this is
where our hypotheses come into play. Details on how these booleans apply to
each parameter:
- beta, gamma and lambda:
  (1) free to vary across all conditions (modelBool1; 3 values)
  (2) fixed across conditions to a single value (modelBool2)
  because we have no hypotheses or expectations of how these params may differ between conditions if they do
- delta:
  (1) free to vary as one value across conditions (modelBool2)
  (2) fixed to one value across conditions (0; modelBool6)
- xPSE:
   here, keep in mind that delta can account for
   upward/downward shifts that are uniform across cue conditions
  (1) FREE MODEL: first- and second-cued PSE are both free to vary,
      both-cued fixed to 0
  (2) PERSISTENCE MODEL: first-cued PSE free to vary, second-cued fixed to
      negation of first-cued PSE (mirrored shift), both-cued fixed to 0
  (3) DECAY MODEL: first-cued PSE fixed to 0, second-cued PSE free to vary,
      both-cued PSE fixed to second-cued PSE value
  (4) FIXED MODEL: all PSE parameters are fixed to 0
%}
modelBool1 = logical([1;1;1]);  % The param is free to vary within each condition (beta,gamma,lambda)
modelBool2 = logical([0;0;1]);  % The param is free to vary but is the same across conditions (delta, beta,gamma,lambda)
modelBool3 = logical([1;1;0]);  % Free model (xPSE)
modelBool4 = logical([1;0;0]);  % persistence model (xPSE)
modelBool5 = logical([0;1;0]);  % decay model (xPSE)
modelBool6 = logical([0;0;0]);  % The parameter is always fixed - (xPSE and delta)
modelBools  = [modelBool1 modelBool2 modelBool3 modelBool2 modelBool3 modelBool4 modelBool5 modelBool6]; % Concat them all into matrix 

% Possible model combinations for each of 5 params, as described above
dvec = [4 8]; % Delta
pvec = 5:8;   % PSE
bvec = [1 4]; % Beta
gvec = [1 4]; % Gamma
lvec = [1 4]; % Lambda

% Generate a matrix containing all possible combinations (nested variants)
% of modelBools indeces for our 5 parameters. The matrix is 5 (# of params)
% x 64 (total number of nested variants. The values within are used to
% index 'modelBools', to obtain boolean a representation of each model
% variant while fitting.
modelCombs = combvec(dvec,pvec,bvec,gvec,lvec);

% Total number of models
nmodels = size(modelCombs,2);

%% Specify options, functions and collectors for fitting
% fmincon options
opts = optimoptions('fmincon');
opts.Display = 'notify';
opts.MaxIter = 1e6;
opts.MaxFunEvals = 1e6;

% GOF functions - specifically, AIC and BIC, which take the negative
% log-likelihood (NLL; output by objective function) and convert it to metrics
% that penalize model complexity (# of free params, k) based on the total # 
% of trials (N) BIC is more conservative, and is what was used in the manuscript. 
AICF = @(NLL,k,N) 2*NLL + 2*k + ((2*k^2 + 2*k)/(N-k-1)); % This is corrected AIC
BICF = @(NLL,k,N) 2*NLL + k*log(N);
totalTrialNum = 2016; % Needed for computing AIC and BIC (input as N)

% Collectors for fit info across observers
bestAICNum_ALL = nan(1,numel(subNames));       % Index of best model by AIC
bestBICNum_ALL = nan(1,numel(subNames));       % Index of best model by BIC

disp(' ')
disp(' ')

%% Loop through observers
for ii = 1:numel(subNames) + 1

    % We fit a pooled meta-subj at the end of the loop - used purely
    % for visualization in Figure 5 (no analysis done). 
    if ii > numel(subNames)
        % Get pooled appearance judgement responses
        appO = squeeze(mean(pcf_ord_ALL,1));   
        outOfNumA = trialsPerCond*numel(subNames);
        nChooseFirst = squeeze(mean(pcf_ord_ALL.*outOfNumA,1));
        % Redefine objective funvtion with new values
        objFcn = @(x,nChooseFirst) sum(-sum(log(PF(reshape(x,5,3)',ordC)).*nChooseFirst +...
            log(1-PF(reshape(x,5,3)',ordC)).*(outOfNumA-nChooseFirst)));  
        subj = 'ALL';
    else
        % Select this observer's p(choose first) data
        appO = squeeze(pcf_ord_ALL(ii,:,:));
        nChooseFirst = appO.*trialsPerCond; % Convert proportion back to count for likelihood fcn 
        subj = subNames{ii};
    end
    
    disp(['%%%% Starting model comparison: Subj ' subj ' %%%%'])

    % Define observer-level collectors for GOF and parameter values
    paramVals = nan(nmodels,size(paramLims,1));  
    AIC = nan(1,nmodels);
    BIC = nan(1,nmodels);
    % Also collect NLL and R-squared because they're nice to have
    NLL = nan(1,nmodels); 
    RSQ = nan(1,nmodels);
    
    % Loop through models
    for imodel = 1:nmodels 
        currModelComb = modelCombs(:,imodel);         % Select the current model column
        currModelBool = modelBools(:,currModelComb)'; % Obtain the boolean representation of the current model
        currModelBool = currModelBool(:);             % Flatten it to 1D to for use in objective function 
        nparamsFree = sum(currModelBool);             % Number of free params for AIC/BIC calculation
        
        % Define the objective function of the current model. The
        % parameters, x, are un-normalized, then input to 'getModel' fcn.
        modelFunc = @(x) objFcn(getModel(unnormParams(addVecN(currModelBool),multVecN(currModelBool),x),...
            currModelComb,currModelBool,fixedVals),nChooseFirst);
        
        % Run the solver
        [currParams,NLL(imodel)] = fmincon(modelFunc, startN(currModelBool), [], [], [], [],...
            lowestN(currModelBool), highestN(currModelBool),[],opts);

        % Un-normalize parameters and store
        paramVals(imodel,:) = getModel(unnormParams(addVecN(currModelBool),multVecN(currModelBool),currParams),...
            currModelComb,currModelBool,fixedVals);
        
        % Get GOF
        AIC(imodel) = AICF(NLL(imodel),nparamsFree,totalTrialNum); 
        BIC(imodel) = BICF(NLL(imodel),nparamsFree,totalTrialNum);
        fitcurr = PF(reshape(paramVals(imodel,:),5,3)',ordC);
        RSQ(imodel) = 1-(sum((fitcurr(:)-appO(:)).^2)./...
            sum((appO(:)-mean(appO(:))).^2));
    end
    
    % Relative (delta) AIC and BIC.
    % Lower score = better, best model = 0
    dAIC = AIC - min(AIC);
    dBIC = BIC - min(BIC);
    
    % Get the index of the best model (column # of modelCombs)
    bestAICNum = (find(dAIC == 0));
    bestBICNum = (find(dBIC == 0));
    
    % Store the best model index across observers
    bestAICNum_ALL(ii) = bestAICNum;
    bestBICNum_ALL(ii) = bestBICNum;
 
    % Save this observer's fit data
    save(['Data\model comparison results\modelComparison_subj' subj], 'paramVals', 'NLL', 'AIC', 'BIC','dAIC','dBIC','bestAICNum','bestBICNum','RSQ')

end

% Save other important variables not contained in individual observer files 
save('Data\model comparison results\auxModelComparisonVars','modelCombs','modelBools','paramLims','bestBICNum_ALL','bestAICNum_ALL')
