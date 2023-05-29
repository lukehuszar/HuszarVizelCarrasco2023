function [] = bmsPlots(subNames,outBIC)
%{
Function for producing figure 4 in the manuscript
%}

%% Plotting vars
ac = [0.5 0.5 0.5]; % Bar face color
bw = 0.8; % Bar width
lnwd = 1; % Linewidth
figure('Position',[0 0 1600 700]); hold on;

%% Subplot 1: EP by model family 
subplot(1,2,1); hold on;
plot([0 4], [0 0], 'LineStyle', '-', 'color', 'k')
xticks([1 2 3 4]); xticklabels({'persistence', 'decay', 'free', 'fixed'}); xlim([0.5 4.5]);
ylabel('exceedance probabilitiy (EP)')
set(gca,'FontSize',25);
yticks(0:0.25:1); ylim([0 1])

% Persistence
h1 = bar(1,outBIC.families.ep(1),bw);
h1.FaceColor = ac;
h1.LineWidth = lnwd;

% Decay
h3 = bar(2,outBIC.families.ep(2),bw);
h3.FaceColor = ac;
h3.LineWidth = lnwd;

% Free 
h5 = bar(3,outBIC.families.ep(3),bw);
h5.FaceColor = ac;
h5.LineWidth = lnwd;

% Fixed
h7 = bar(4,outBIC.families.ep(4),bw);
h7.FaceColor = ac;
h7.LineWidth = lnwd;

%% Subplot 2: model family posteriors pr observer
subplot(1,2,2); hold on;
base = [0 0; 1 0; 1 1; 0 1]+0.5;
xticks([1 2 3 4]); xticklabels({'persistence', 'decay', 'free', 'fixed'}); xlim([0.48 4.52]);
ylabel('observers')
set(gca,'FontSize',25);
yticks(1:8);
ylim([0.48 8.52]);
cp = base;
for ii = 1:numel(subNames)
    for mm = 1:4
      patch('Faces',[1 2 3 4], 'Vertices', cp, 'FaceColor', 1-(zeros(1,3)+outBIC.families.r(mm,ii)),'edgecolor','w','linewidth',2); 
      cp(:,1) = cp(:,1)+1;
    end
    cp(:,2) = cp(:,2) + 1;
    cp(:,1) = base(:,1);
end

end