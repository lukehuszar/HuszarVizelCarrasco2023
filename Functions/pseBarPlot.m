function [] = pseBarPlot(PSEs,PSEsSE,btwnSEs,delta,deltaSE,cols)
%{
Function used to make bar plots from Figs 3 and 5 in
manuscript. PSEs (3x1) are plotted as bars with error bars (PSEsSE). 
btwnSEs if for Fig 3, where the SE between cue conditions is shown above
bars. deltas is for Fig 5, where the avg + SE of the delta parameter is
plotted alongside the PSE bars.
%}

[~,~,~,~,~,~,~,~,~,~,~,barDims,boff,boff2] = plottingVars(); % Load plot variables

% Init plot and tweak values
figure('Position',barDims); hold on;
plot([0 4], [0 0], 'LineStyle', '-', 'color', 'k')
xticks([1 2 3]); xticklabels({'first cued', 'both cued', 'second cued'}); xlim([0.5 3.5]);
ylabel('PSE (%)')
set(gca,'FontSize',25);
yticks(-0.3:0.1:0.3); ylim([-0.25 0.25])

% If this is for Fig 5, plot the delta value and shaded SE
if ~isnan(delta)
    plot([0 4], [delta(1) delta(1)], 'LineWidth', 3, 'color', cols(4,:))
    patch([0 4 4 0], [[delta(1) delta(1)] - deltaSE(1) [delta(1) delta(1)] + deltaSE(1)],...
        cols(4,:),'EdgeColor','none','FaceAlpha',.3)
end

% Plot both-cued
h2 = bar(2,(PSEs(3)));
errorbar(2,PSEs(3),...
    PSEsSE(3),...
    'vertical','LineStyle','none','linewidth',2,'capsize',15,'color','k');
h2.FaceColor = [0.3 0.3 0.3];

% Plot first-cued
h1 = bar(1,PSEs(1));
errorbar(1,PSEs(1),...
    PSEsSE(1),...
    'vertical','LineStyle','none','linewidth',2,'capsize',15,'color','k');
h1.FaceColor = cols(2,:); 

% Plot second-cued
h3 = bar(3,(PSEs(2)));
errorbar(3,PSEs(2),...
    PSEsSE(2),...
    'vertical','LineStyle','none','linewidth',2,'capsize',15,'color','k');
h3.FaceColor = cols(1,:);      

% If this is for Fig 3, plot the SE between cue conditions as capless error
% bars.
if ~isnan(btwnSEs)
    % first-cued vs both-cued
    errorbar(1.5, btwnSEs(1,1), btwnSEs(2,1),'LineStyle','none','linewidth',1,'capsize',0,'color','k');
    plot([1.5-boff 1.5+boff],[btwnSEs(1,1) btwnSEs(1,1)],'linestyle','-','color','k','linewidth',1)
    
    % both-cued vs second-cued
    errorbar(2.5, btwnSEs(1,2), btwnSEs(2,2),'LineStyle','none','linewidth',1,'capsize',0,'color','k');
    plot([2.5-boff 2.5+boff],[btwnSEs(1,2) btwnSEs(1,2)],'linestyle','-','color','k','linewidth',1)

    % first-cued vs second-cued
    errorbar(2, btwnSEs(1,3), btwnSEs(2,3), 'LineStyle','none','linewidth',1,'capsize',0,'color','k');
    plot([2-boff2 2+boff2],[btwnSEs(1,3) btwnSEs(1,3)],'linestyle','-','color','k','linewidth',1)
end

