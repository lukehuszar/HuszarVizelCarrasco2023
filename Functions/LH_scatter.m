function [] = LH_scatter(xdata,ydata,fillColor,pointSize,pointType,pointWidth,edgeColor,visibility)

if nargin < 8
    visibility = 'on';
end
if nargin < 7
    edgeColor = 'k';
end
if nargin < 6
    pointWidth = 1;
end
if nargin < 5
    pointType = 'o';
end
if nargin < 4
    pointSize = 50;
end
if nargin < 3
    fillColor = [0.7 0.7 0.7];
end
    

scatter(xdata,ydata,pointSize,pointType,'MarkerFaceColor',fillColor,'MarkerEdgeColor',edgeColor,'LineWidth',pointWidth,'HandleVisibility',visibility)

end

