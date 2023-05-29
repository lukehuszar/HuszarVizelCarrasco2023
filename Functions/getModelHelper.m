function [outputParams] = getModelHelper(x,modelNum)

neutPSE = 0;

switch modelNum
    case 1
        outputParams = [x(1) x(2) x(3)]';          % All free
    case 2
        outputParams = [x(1) x(3)-x(1) x(3)]';          % mirrored shift
    case 3
        outputParams = [x(1) x(2) x(2)]';          % second = both cued; decay pred
    case 4
        outputParams = [x(3) x(3) x(3)]';          % Fixed across conds      
    case 5
        outputParams = [x(1) x(2) neutPSE]';       % All free - neut PSE fixed
    case 6
        outputParams = [x(1) -x(1) neutPSE]';          % mirrored shift
    case 7
        outputParams = [neutPSE x(2) x(2)]';    % second = both cued; decay pred
    case 8
        outputParams = [neutPSE neutPSE neutPSE]'; % null - pses fixed
end
        
end

