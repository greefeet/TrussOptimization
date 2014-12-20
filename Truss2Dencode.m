function [a b] = Truss2Dencode
%Truss2Dencode Declare Varaibles and Set Upper and Lower Limit

%Encode VERSION 2.0 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Applied Delaunay Triangulation : Determinate and Indeterminate Structure

%     DesignVariable = [FixNodeSet FreeNodeSet]
% a is LowerBoundary = [a1 a2]
% b is UpperBoundary = [b1 b2]

%  FixNodeSet = [CrossSectionSet IndeterminateSet]
%          a1 = [lowerCrossSectionSet lowerIndeterminateSet]
%          b1 = [upperCrossSectionSet upperIndeterminateSet]

% FreeNodeSet = [NodeSet CrossSectionSet IndeterminateSet]
%          a2 = [lowerNodeSet lowerCrossSectionSet lowerIndeterminateSet]
%          b2 = [upperNodeSet upperCrossSectionSet upperIndeterminateSet]

%%%%%%%%%%%%%%% NodeSet = [xPos][yPos][isUsed] %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          lowerNodeSet = [xLow][yLow][0]
%          upperNodeSet = [xUpp][yUpp][1]

%%%%%%% CrossSectionSet = [SectionIndexZone][PriorityZone] %%%%%%%%%%%%%%%%
%       CrossSectionSet = [S11]...[S13]
%                         .  .  .
%                         .  .  .
%                         .  .  .
%                         [S81]...[S83]
%                         [P11]...[P13]
%                         .  .  .
%                         .  .  .
%                         .  .  .
%                         [P81]...[P83]
%  lowerCrossSectionSet = [1]...[1]
%                         .  .  .
%                         .  .  .
%                         .  .  .
%                         [1]...[1]
%                         [0]...[0]
%                         .  .  .
%                         .  .  .
%                         .  .  .
%                         [0]...[0]
%  upperCrossSectionSet = [30]...[30]
%                          .  .  .
%                          .  .  .
%                          .  .  .
%                         [30]...[30]
%                         [1]...[1]
%                          .  .  .
%                          .  .  .
%                          .  .  .
%                         [1]...[1]

%%%%%% IndeterminateSet = [isUsedEachLayer] %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      IndeterminateSet = [iS11][iS12][iS13] %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         .     .     .
%                         .     .     .
%                         .     .     .
%                         [iS81][iS82][iS83]
% lowerIndeterminateSet = [0][0][0]
%                         .  .  .
%                         .  .  .
%                         .  .  .
%                         [0][0][0]
% upperIndeterminateSet = [1][1][1]
%                         .  .  .
%                         .  .  .
%                         .  .  .
%                         [1][1][1]

% SXY is crossSectionIndex in section's X in layer Y
% PX is prioritySection in section's X in layer Y
% xPos is x coordination
% yPos is y coordination
% xLow is lower x coordination of node
% yLow is lower y coordination of node
% xUpp is upper x coordination of node
% yUpp is upper y coordination of node
% iSXY is connecting on section's X in layer Y

%CoupleVariables
% lowCrossSection - uppCrossSection
% lowBoolean - uppBoolean
% lowX - uppX (specific)
% lowY - uppY (specific)

%Global Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PRB;             % From Problem's Function
global NOF;             % To Calculate Fitness

%Encode %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n[EncodeProblem] %s\n',PRB.info.name);
fprintf('[Formulation] Applied Delauney Triangulation\n');

%Set Instability Counter
NOF.Instability = 0;

%Define No. of Section and Layer
NOF.Section=8;
NOF.SectionLayer=3;
NOF.IndeterminateLayer=3;

%Set CoupleVariables
%Section
switch PRB.dv.TypeSection
    case TypeSection.Discrete
        lowCrossSection = 1;
        uppCrossSection = length(PRB.dv.crossSection(:,1));
    case TypeSection.Continuous
        lowCrossSection = PRB.dv.sectionMin;
        uppCrossSection = PRB.dv.sectionMax;
end

%Booenlean
lowBoolean = 0;
uppBoolean = 1;

%CrossSection
NOF.CrossSectionSet = NOF.Section*NOF.SectionLayer;
noCrossSectionZone = NOF.CrossSectionSet*2;
lowerCrossSectionSet = [lowCrossSection*ones(1,NOF.CrossSectionSet) lowBoolean*ones(1,NOF.CrossSectionSet)];
upperCrossSectionSet = [uppCrossSection*ones(1,NOF.CrossSectionSet) uppBoolean*ones(1,NOF.CrossSectionSet)];

%Indeterminate
noIndeterminateSet = NOF.Section*NOF.IndeterminateLayer;
NOF.IndeterminateZone = noIndeterminateSet;
lowerIndeterminateSet = lowBoolean*ones(1,noIndeterminateSet);
upperIndeterminateSet = uppBoolean*ones(1,noIndeterminateSet);

noNodeSet = 3; % 1:xPos 2:yPos 3:isUsed

%FixNodeSet
NOF.FixNode=length(PRB.bc.fix(:,1))+length(PRB.bc.load(:,1));
NOF.EachFixNode = noCrossSectionZone + noIndeterminateSet;
a1=zeros(1,NOF.FixNode*NOF.EachFixNode);
b1=zeros(1,NOF.FixNode*NOF.EachFixNode);
for i=1:NOF.FixNode
    a1(NOF.EachFixNode*(i-1)+1:1:NOF.EachFixNode*i)=[lowerCrossSectionSet lowerIndeterminateSet];
    b1(NOF.EachFixNode*(i-1)+1:1:NOF.EachFixNode*i)=[upperCrossSectionSet upperIndeterminateSet];
end

%FreeNodeSet;
%Estimate No. of freeNode from totalArea and minArea
%Calculate minArea from 3 min sides
p=(PRB.dv.lengthMin*3)/2;
minArea=sqrt(p*(p-PRB.dv.lengthMin)^3);
rectangSide=sqrt(minArea);
xnum=round(PRB.dv.xMax/rectangSide);
lengthX=PRB.dv.xMax/xnum;
ynum=round(PRB.dv.yMax/rectangSide);
lengthY=PRB.dv.yMax/ynum;

NOF.FreeNode = xnum*ynum;
NOF.EachFreeNode = noNodeSet + noCrossSectionZone + noIndeterminateSet;
a2=zeros(1,NOF.FreeNode*NOF.EachFreeNode);
b2=zeros(1,NOF.FreeNode*NOF.EachFreeNode);

countSet=1;
for i=1:ynum
    yLow=(i-1)*lengthY;
    yUpp=i*lengthY;
    if i==ynum
        yUpp=PRB.dv.yMax;
    end
    for j=1:xnum
        xLow=(j-1)*lengthX;
        xUpp=j*lengthX;
        if j==xnum
            xUpp=PRB.dv.xMax;
        end
        lowerNodeSet = [xLow yLow lowBoolean];
        upperNodeSet = [xUpp yUpp uppBoolean];
        subA=[lowerNodeSet lowerCrossSectionSet lowerIndeterminateSet];
        subB=[upperNodeSet upperCrossSectionSet upperIndeterminateSet];
        a2((countSet-1)*NOF.EachFreeNode+1:1:countSet*NOF.EachFreeNode)=subA;
        b2((countSet-1)*NOF.EachFreeNode+1:1:countSet*NOF.EachFreeNode)=subB;
        countSet=countSet+1;
    end
end

a=[a1 a2];
b=[b1 b2];

fprintf('   noVar = noFixNode*(noCrossSectionSet*2 + noIndeterminateSet) + noFreeNode*(noNodeSet + noCrossSectionSet*2 + noIndeterminateSet)\n');
fprintf('         = %d*(%d*2 + %d) + %d*(%d + %d*2+%d)\n',NOF.FixNode,NOF.CrossSectionSet,noIndeterminateSet,NOF.FreeNode,noNodeSet,NOF.CrossSectionSet,noIndeterminateSet);
noVar=NOF.FixNode*(noCrossSectionZone + noIndeterminateSet)+NOF.FreeNode*(noNodeSet + noCrossSectionZone + noIndeterminateSet);
fprintf('         = %d\n',noVar);

%Initialization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning('off','MATLAB:delaunay:DupPtsDelaunayWarnId');  % FixDelaunayWarn
verifyOpenSees();                                       % Verify OpenSees
displayInitial(lengthX,lengthY);                        % Display Initial

%Wait %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\nPress any key to Start...\n');       pause
end

function displayInitial(lengthX,lengthY)
%Global Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PRB;                     % From Problem's Function
global lineX; global lineY;     % To Truss2Drun Function
global showDetail;              % For HelpDraw
showDetail = 0;                 % Set Initial FOR Binary and CalFitness

global isSave;                  % For Truss2Drun save figure
isSave=1;                       % Set Initial FOR Truss2Drun save picture
close all;						% Close all Figures
ss = get(0,'ScreenSize');		% Get ScreenSize
% Set Position of Each Figure
figure('Name','Statistic','Position',[1 ss(4)/2 ss(3)/2 ss(4)/2]);
figure('Name','History','Position',[ss(3)/2 ss(4)/2 ss(3)/2 ss(4)/2]);
figure('Name','Structure','Position',[1 1 ss(3)/2 ss(4)/2]);
figure('Name','Constraints','Position',[ss(3)/2 1 ss(3)/2 ss(4)/2]);
figure(2);	figure(1);

% Set ylim of Statistic and History
set(0,'CurrentFigure',1);
ylim([0 500000]);
set(0,'CurrentFigure',2);
ylim([0 500000]);


% Draw Design Space
set(0,'CurrentFigure',3);
clf;    hold on;    daspect([1 1 1]);   xlabel('x'); ylabel('y');
title('Design Space','FontWeight','bold');

% Design space
xlim([PRB.dv.xMin PRB.dv.xMax]); ylim([PRB.dv.yMin PRB.dv.yMax]);

% Load
plot(PRB.bc.node(PRB.bc.load(:,1),1),PRB.bc.node(PRB.bc.load(:,1),2),'mV','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','red','MarkerSize',7);

% Support
plot(PRB.bc.node(PRB.bc.fix(:,1),1),PRB.bc.node(PRB.bc.fix(:,1),2),'ms','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',7);

% Grid
lineX=0:lengthX:PRB.dv.xMax;    lineY=0:lengthY:PRB.dv.yMax;
for i=1:length(lineX)
    plot([lineX(i) lineX(i)],[PRB.dv.yMin PRB.dv.yMax],'--black','LineWidth',1);
end
for i=1:length(lineY)
    plot([PRB.dv.xMin PRB.dv.xMax],[lineY(i) lineY(i)],'--black','LineWidth',1);
end
end
function verifyOpenSees
opensees=verifyopensees;
if opensees==0
	fprintf('ERROR Connection to OpenSees\n')
	FORCE_STOP;									% Force Terminate
end
end
