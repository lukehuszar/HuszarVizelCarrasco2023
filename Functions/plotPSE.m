function [] = plotPSE(testCuedCurve, stdCuedCurve, neutCuedCurve,...
    testCuedApp, stdCuedApp, neutCuedApp,...
    testCuedPSE, stdCuedPSE, neutCuedPSE,...
    cols, testC, lbl, ptType, lnType)

logRange = log10(logspace(log10(0.01), log10(1), numel(testCuedCurve)));
contrastRange = 10.^(logRange);
ptSz = 75;

plot([testCuedPSE testCuedPSE], [0 0.5], 'LineStyle', '--', 'LineWidth', 1.5, 'color', cols(2,:))
plot(contrastRange, testCuedCurve,'-','color',cols(2,:),'Linewidth',4,'LineStyle',lnType);
LH_scatter(testC,testCuedApp,cols(2,:),ptSz,ptType);
scatter(testCuedPSE, 0, 100, cols(2,:),'*','LineWidth',1.5)

plot([stdCuedPSE stdCuedPSE], [0 0.5], 'LineStyle', '--', 'LineWidth', 1.5, 'color', cols(1,:))
plot(contrastRange, stdCuedCurve,'-','color',cols(1,:),'Linewidth',4,'LineStyle',lnType);
LH_scatter(testC,stdCuedApp,cols(1,:),ptSz,ptType);
scatter(stdCuedPSE, 0, 100, cols(1,:),'*','LineWidth',1.5)

plot([neutCuedPSE neutCuedPSE], [0 0.5], 'LineStyle', '--', 'LineWidth', 1.5, 'color', 'k')
plot(contrastRange, neutCuedCurve,'-','color','k','Linewidth',4,'LineStyle',lnType);
LH_scatter(testC,neutCuedApp,'k',ptSz,ptType);
scatter(neutCuedPSE, 0, 100, 'k','*','LineWidth',1.5)

c
title(lbl)


end

