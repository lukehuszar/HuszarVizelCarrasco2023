function [xl,xr,ptSz,ptSz2,ptwd,lnwd,blk,ftsz,cpsz,elnwd,pfDims,barDims,boff,boff2] = plottingVars()
    xl = [-0.8 0.8];                  % x-axis limits
    xr = linspace(xl(1),xl(2),1e3);   % finely spaced range of contrast values
    ptSz = 150;                       % point size
    ptSz2 = 180;                      % 2nd point size
    ptwd = 2;                         % point outline width
    lnwd = 4;                         % linewidth
    blk = [0 0 0];                    % black color vector
    ftsz = 20;                        % fontsize
    cpsz = 0;                         % error bar capsize
    elnwd = 2.5;                      % error bar line width
    pfDims = [0 0 700 800];           % dimensions for psychometric function plots
    barDims = [0 0 600 800];          % dimensions for bar plots
    boff = 0.18;                      % barplot offset
    boff2 = 0.8;                      % barplot offset 2
end

