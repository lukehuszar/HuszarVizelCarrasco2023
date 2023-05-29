function [paramVals, gof, rsq, paramNames] = fitCumNormalPF(stimLevels, nChooseFirst, outOfNum, pseGuess)
%{
Uses fmincon to estimate the best fitting parameters for a 4-parameter
cumulative normal psychometric function. Parameters = alpha (location),
beta (slope), gamma (lower asymptote), lambda (upper asymptote). All
parameters are free to vary, and free to vary between cue conditions.

The function is fit to the # of trials where the first stimulus was chosen
as higher contrast (nChooseFirst) out of the total # of trials per
condition (outOfNum) across the 7 contrast levels (stimLevels) - by
minimizing the negative log-likelihood (NLL).

Returns the best-fitting parameters; the NLL of the fit (gof) and
R-squared (rsq); a vector of strings of parameter names (paramNames).
%}

% Functions for normalizing/un-normalizing parmaeters between 0 and 1 for
% use in fmincon
normParams = @(x) (x-x(1,:))./(x(3,:)-x(1,:));
unnormParams = @(x,upper,lower) (x.*upper) + lower;

% Make sure the input vectors have the dimensions we want
stimLevels = stimLevels(:);
outOfNum = outOfNum(:);
nChooseFirst = nChooseFirst(:);

% Setting the search bounds for fmincon [lower bound, starting point, upper
% bound]. Liberal bounds were used.
alphaLims = pseGuess;
betaLims = [1 6 20];
gammaLims = [0 0 0.5];
lambdaLims = [0 0 0.5];
paramLimsU = ([alphaLims' betaLims' gammaLims' lambdaLims']);          % Concat bounds in matrix (unnormalized)
paramLims = normParams([alphaLims' betaLims' gammaLims' lambdaLims']); % Normalized matrix of bounds


PF = @(x,lvls) x(3) + (1 - x(3) - x(4)).*.5.*erfc(-x(2).*(lvls-x(1))./sqrt(2)); % The cumulative normal function
objFcn = @(x) -sum(log(PF(x,stimLevels)).*nChooseFirst +...                     % Objective function for fmincon - computes NLL
        log(1-PF(x,stimLevels)).*(outOfNum-nChooseFirst));
objFcnWrap = @(x) objFcn(unnormParams(x,(paramLimsU(3,:)-paramLimsU(1,:)),paramLimsU(1,:))); % A wrapper for the objective function which normalizes parameter inputs

% fmincon options
opts = optimoptions('fmincon');
opts.Display = 'notify';
opts.MaxIter = 1e4;
opts.MaxFunEvals = 1e4;
 
% fit with fmincon
[paramVals,NLL] = fmincon(objFcnWrap, paramLims(2,:), [], [], [], [],... 
    paramLims(1,:), paramLims(3,:),[],opts);                   
paramVals = unnormParams(paramVals,(paramLimsU(3,:)-paramLimsU(1,:)),paramLimsU(1,:)); % unnorm params to original values

% Get the output for the best-fitting params
contrastRange = linspace(min(stimLevels),max(stimLevels),1e6);  % define a finely-spaced range of contrast value
currFit = PF(paramVals,contrastRange);                          % get output from cum norm function
[~, PSEInd] = min(abs(0.5 - currFit));                          % get the PSE index (contrast level at 50% p(choose first))
currPSE = (contrastRange(PSEInd));                              % get PSE value
paramVals = [paramVals currPSE];                                % add PSE to end of param vector
gof = NLL;                                                      % GOF is NLL


paramNames = {'alpha', 'beta', 'gamma', 'lambda', 'pse'};     % for output

% Get R-squared for fits too
appC = (nChooseFirst./outOfNum);
fitC = PF(paramVals,stimLevels);
sstot = sum((appC-mean(appC)).^2);
ssres = sum((appC-fitC).^2);
rsq = 1-(ssres/sstot);


