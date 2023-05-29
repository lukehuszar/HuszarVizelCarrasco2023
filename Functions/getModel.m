function [outputParams] = getModel(inputParams,modelCombs,modelBool,fixedVals)

% Update values of the free parameters
fixedVals(modelBool) = inputParams;

% Regroup into matrix w/ columns: PSE, slope, lapse, guess
x = reshape(fixedVals,5,3)';

% Get output for each param
deltas  = getModelHelper(x(:,1),modelCombs(1));
alphas  = getModelHelper(x(:,2),modelCombs(2));
betas   = getModelHelper(x(:,3),modelCombs(3));
gammas  = getModelHelper(x(:,4),modelCombs(4));
if modelCombs(5) == 8 % When lapse == guess
    lambdas = gammas;
else
    lambdas = getModelHelper(x(:,5),modelCombs(5));
end

%alphas = alphas + deltas;

% Get output
outputParams = [deltas, alphas, betas, gammas, lambdas]';

% Put back into order
outputParams = outputParams(:);

end

