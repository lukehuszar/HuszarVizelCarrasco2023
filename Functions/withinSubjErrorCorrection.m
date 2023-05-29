function [SE,Zsj] = withinSubjErrorCorrection(Xsj)
% CI from Baguley (2012), error bars from Cousineau & O'Brien (2014)
% Xsj -> dimensions are (# observers x # conditions). 

% Vars:
% J    = number of conditions
% Xsj  = score for subject s in condition j
% Xs   = mean for subject s acrosss all J conditions
% Xdot = grand mean
% Ysj  = transformed score for subject s in condition j

% Define variables
J = size(Xsj,2);
Xs   = mean(Xsj,2);
Xdot = mean(Xsj(:));

% Compute transformed (normalized) variables Y
Ysj  = Xsj - Xs + Xdot;
Yj   = mean(Ysj,1);

% Compute 2nd transformation to Z
Zsj = sqrt((J/(J-1)))*(Ysj-Yj)+Yj;

% Get corrected SE
SE = squeeze(std(Zsj,[],1)./sqrt(size(Xsj,1)));
end

