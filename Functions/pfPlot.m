function [] = pfPlot(ordC,pointDat,pointDatSE,lineDat,PSEs,cols)
%{
Function used to make psychometric function plots from Figs 3 and 5 in
manuscript. All data is 3 (cue conditions) x 7 (contrast levels). pointDat
will be plotted as unconnected points, lineDat will be plotted as
continuous lines.
%}

[xl,xr,ptSz,ptSz2,ptwd,lnwd,blk,ftsz,cpsz,elnwd,pfDims] = plottingVars(); % Get plot variables

% Init plot and tweak visual params
figure('Position',pfDims); hold on;
xlabel('first - second log contrast')
ylabel('p(choose first)')
xticks(ordC)
set(gca,'LineWidth',3)
ylim( [0 1])
xlim(xl)
line(xl, [0.5 0.5], 'LineStyle', ':', 'Color', 'k')
yticks(0:0.25:1)
set(gca, 'FontSize', ftsz)
set(gcf,'color','w')

% Plot PSE dashed vertical lines
plot([PSEs(3) PSEs(3)], [0 0.5], 'LineStyle', '--', 'color', 'k', 'LineWidth', 1.5);
plot([PSEs(1) PSEs(1)], [0 0.5], 'LineStyle', '--', 'color', cols(2,:), 'LineWidth', 1.5);
plot([PSEs(2) PSEs(2)], [0 0.5], 'LineStyle', '--', 'color', cols(1,:), 'LineWidth', 1.5);
 
% Plot both-cued
LH_scatter(PSEs(3),0,'none',ptSz2,'s',ptwd,'k')
plot(xr, lineDat(3,:),'-','color','k','Linewidth',lnwd);
errorbar((ordC),pointDat(3,:),pointDatSE(1,:),'color','k','linestyle','none','capsize',cpsz,'linewidth',elnwd)
LH_scatter((ordC),pointDat(3,:),'w',ptSz,'o',ptwd,blk);

% Plot first-cued
LH_scatter(PSEs(1),0,'none',ptSz2,'s',ptwd,cols(2,:));
plot(xr, lineDat(1,:),'-','color',cols(2,:),'Linewidth',lnwd);
errorbar((ordC),pointDat(1,:),pointDatSE(1,:),'color',cols(2,:),'linestyle','none','capsize',cpsz,'linewidth',elnwd);
LH_scatter((ordC),pointDat(1,:),'w',ptSz,'o',ptwd,cols(2,:));

% Plot second-cued
LH_scatter(PSEs(2),0,'none',ptSz2,'s',ptwd,cols(1,:));
plot(xr, lineDat(2,:),'-','color',cols(1,:),'Linewidth',lnwd);
errorbar((ordC),pointDat(2,:),pointDatSE(1,:),'color',cols(1,:),'linestyle','none','capsize',cpsz,'linewidth',elnwd);
LH_scatter((ordC),pointDat(2,:),'w',ptSz,'o',ptwd,cols(1,:));  

end

