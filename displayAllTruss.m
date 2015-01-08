function displayAllTruss(dirName)
%displayAllTruss Display All Results
%Get File List %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dirData = dir(fullfile(dirName,'*.mat'));
dirIndex = [dirData.isdir];
fileList = {dirData(~dirIndex).name};

%Initialization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(fullfile(dirName,fileList{1}));
[func] = feval(strcat(Solution.prob));      % Load Problem
feval(strcat(func,'encode'));               % Set Upper and Lower Limit
oldIndi=0;

%Prepare Figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
scrsz = get(0,'ScreenSize');
figure('Name','BestFitness','Position',[1 scrsz(4)/2 scrsz(3) scrsz(4)/2]);
figure('Name','History','Position',[1 1 scrsz(3) scrsz(4)/2]);

global PRB;     % From Problem 
global NOF;     % From Truss2Dencode

%Load Statistic from last Result %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
noFile=length(fileList);
load(fullfile(dirName,fileList{noFile}))
set(0,'CurrentFigure',2);
StatAll=Running.stat;
displayStat(noFile,StatAll,'Generations Number',PRB.info.Label)
pause(0.0001);

%design space
set(0,'CurrentFigure',1);
xlim([PRB.dv.xMin PRB.dv.xMax])
ylim([PRB.dv.yMin PRB.dv.yMax])

%Loop Display
for j=1:noFile
    
    %Draw Structure when Result is change
    load(fullfile(dirName,fileList{j}));
    if ~isequal(oldIndi,Solution.indi)
        
        %Display Detail
        set(0,'CurrentFigure',1);
        clf(1,'reset');
        hold on;
        daspect([1 1 1]);
        til=sprintf('Best Individual\n');
        title(til,'FontWeight','bold');
        ylabel('y');
        xlabel(sprintf('x\n\nGeneration %d, Fitness %.0f kg\n%s, Population''s size %d',j,Running.stat(j,3),Method.name,Method.NoSolver));
                
        %Transform RAW Data to Truss Structure
        [node, member]=Truss2Ddecode(Solution.indi);
        noMember=length(member(:,1));
        noNode=length(node(:,1));
        
        switch PRB.dv.TypeSection
            case TypeSection.Discrete
                maxA=max(dv.crossSection(:,1));
                minA=min(dv.crossSection(:,1));
            case TypeSection.Continuous
                maxA=PRB.dv.sectionMax;
                minA=PRB.dv.sectionMin;
        end
        
        %Draw Structure
        for i=1:noMember
            lw=1+4*(member(i,3)-minA)/(maxA-minA);
            plot(node(member(i,1:2),1),node(member(i,1:2),2),'-black','LineWidth',lw);
        end
            
        %Draw Node
        plot(node(NOF.FixNode:noNode,1),node(NOF.FixNode:noNode,2),'mO','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','Yellow','MarkerSize',7);

        %Draw Load
        plot(PRB.bc.node(PRB.bc.load(:,1),1),PRB.bc.node(PRB.bc.load(:,1),2),'mV','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','red','MarkerSize',7);

        %Draw Support
        plot(PRB.bc.node(PRB.bc.fix(:,1),1),PRB.bc.node(PRB.bc.fix(:,1),2),'ms','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',7);
        
        %Draw Maker
        set(0,'CurrentFigure',2);
        clf;
        displayStat(noFile,StatAll,'Generations Number','Weight (kg)')
        plot(j,StatAll(j,3),'-h','MarkerEdgeColor','y','MarkerFaceColor','y','MarkerSize',15,'Color','black');
        pause(0.1);
        oldIndi=Solution.indi;
    end
end
end
function displayStat(gen,StatAll,xLabel,yLabel)
cF=[47/255 51/255 59/255]; cP=[255/255 54/255 0/255];
hold on;
plot(1:gen,StatAll(1:gen,1),'-o','LineWidth',1,'MarkerEdgeColor','black','MarkerFaceColor','black','MarkerSize',2,'Color','black');
plot(1:gen,StatAll(1:gen,2),'-v','LineWidth',1,'MarkerEdgeColor',cP,'MarkerFaceColor',cP,'MarkerSize',3,'Color',cP);
plot(1:gen,StatAll(1:gen,3),':x','LineWidth',1,'MarkerEdgeColor',cF,'MarkerFaceColor',cF,'MarkerSize',3,'Color',cF);
legend('Medain','Mode','Min');
xlabel(xLabel);
ylabel(yLabel);
title('Statistic of Population','FontWeight','bold')
end