function TrussSymmetry2Drun(gen,indi,Method,statistic)
global PRB;         %FROM PROBLEM
global NOF;         %FROM ENCODE

global isSave;      %FROM VIEW
global save_folder; %FROM START
global showDetail;

dv = PRB.dv;
bc = PRB.bc;

noFixNode = NOF.FixNode;
global lineX; global lineY;

% Draw Structure
set(0,'CurrentFigure',3);
clf
hold on
daspect([1 1 1]);
xlabel('x');ylabel('y');
title('Design Space','FontWeight','bold');

% Design space
xlim([dv.xMin dv.xMax]);
ylim([dv.yMin dv.yMax]);

for i=1:length(lineX)
    plot([lineX(i) lineX(i)],[dv.yMin dv.yMax],'--black','LineWidth',1);
end
for i=1:length(lineY)
    plot([dv.xMin dv.xMax],[lineY(i) lineY(i)],'--black','LineWidth',1);
end

%load
plot(bc.node(bc.load(:,1),1),bc.node(bc.load(:,1),2),'mV','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','red','MarkerSize',7);
%support
plot(bc.node(bc.fix(:,1),1),bc.node(bc.fix(:,1),2),'ms','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',7);

% pause
[node, member]=TrussSymmetry2Ddecode(indi);
noMember=length(member(:,1));
switch PRB.dv.TypeSection
    case TypeSection.Discrete
        maxA=max(dv.crossSection(:,1));
        minA=min(dv.crossSection(:,1));
    case TypeSection.Continuous
        maxA=PRB.dv.sectionMax;
        minA=PRB.dv.sectionMin;
end


for i=1:noMember
    lw=1+4*(member(i,3)-minA)/(maxA-minA);
    plot(node(member(i,1:2),1),node(member(i,1:2),2),'-black','LineWidth',lw);
end
noNode=length(node(:,1));
plot(node(noFixNode:noNode,1),node(noFixNode:noNode,2),'mO','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','Yellow','MarkerSize',7);
%load
plot(bc.node(bc.load(:,1),1),bc.node(bc.load(:,1),2),'mV','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','red','MarkerSize',7);
%support
plot(bc.node(bc.fix(:,1),1),bc.node(bc.fix(:,1),2),'ms','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',7);
til=sprintf('Best Individual\n');
title(til,'FontWeight','bold')
xlabel(sprintf('x\n\nGeneration %d, Fitness %.0f %s\n%s, Population''s size %d',gen,statistic.hisFitness(gen),PRB.info.Label,Method.name,Method.NoSolver));

% pause
showDetail=1;
feval('TrussSymmetry2D',indi);
pause(0.0001);
showDetail=0;

if isSave==1
name=sprintf('gen-%3.0f.png',gen);
fullFileName=fullfile(cd,save_folder,name);
saveas(3,fullFileName, 'png')
end
end