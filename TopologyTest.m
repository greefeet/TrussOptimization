function TopologyTest
%TopologyTest Bruce Force Display All Topology
prob = 'BKI';
feval(strcat(prob));           % Load Problem

global PRB;
% %BKI
% PRB.bc.FreeNode=[
%     360 360
%     720 360
%     ];
PRB.bc.FreeNode=[
    60 60
    180 60
    300 60
    420 60
    540 60
    660 60
    
    60 180
    180 180
    300 180
    420 180
    540 180
    660 180
    
    60 300
    180 300
    300 300
    420 300
    540 300
    660 300
    ];

% %BKIII
% PRB.bc.FreeNode=[
%     0 120
%     120 120
%     240 120
%     360 120
%     480 120
%     0 240
%     120 240
%     240 240
%     360 240
%     480 240
%     ];


noFreeNode=length(PRB.bc.FreeNode(:,1));
close all
for i=0:2^noFreeNode-1
    if mod(i,14000)==0
        str=dec2bin(i);
        fprintf('%s\n',dec2bin(i));    
        node=PRB.bc.node;
        for j=1:length(str)
            if str(length(str)-j+1)=='1'
                node=[node; PRB.bc.FreeNode(j,:)];
            end
        end
        tri=delaunayTriangulation(node).ConnectivityList;
        triSize=size(tri); noTri=triSize(1);
        if noTri==0
            clf
            fprintf('Instability\n');
            pause(0.2);
        else
            DT=delaunayTriangulation(node);
            DrawStructure(node,DT);
            pause;
        end
    end
%     str=dec2bin(i);
%     if strcmp(str,'0') || strcmp(str,'111111111') || strcmp(str,'111111111111111111')
%         fprintf('%s\n',dec2bin(i));    
%         node=PRB.bc.node;
%         for j=1:length(str)
%             if str(length(str)-j+1)=='1'
%                 node=[node; PRB.bc.FreeNode(j,:)];
%             end
%         end
%         tri=delaunayTriangulation(node).ConnectivityList;
%         triSize=size(tri); noTri=triSize(1);
%         if noTri==0
%             clf
%             fprintf('Instability\n');
%             pause(0.2);
%         else
%             DT=delaunayTriangulation(node);
%             DrawStructure(node,DT);
%             pause(0.2);
%         end
%     end
end

end

function output=resultFolder(prob,method)
global save_folder;
CN=getenv('COMPUTERNAME');  r=clock;
DT=sprintf('%d.%d.%d %02d.%02d.%02.0f',r(3),r(2),r(1),r(4),r(5),r(6));
save_folder = sprintf('%s - %s - %s - %s',CN,DT,prob,method);
mkdir(save_folder); output = save_folder;
end

function DrawStructure(node,DT)
global PRB;
bc=PRB.bc;dv=PRB.dv;

% Draw Structure
clf
hold on
daspect([1 1 1]);
xlabel('x');ylabel('y');

% Design space
xlim([dv.xMin dv.xMax]);
ylim([dv.yMin dv.yMax]);

%load
plot(bc.node(bc.load(:,1),1),bc.node(bc.load(:,1),2),'mV','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','red','MarkerSize',7);
%support
plot(bc.node(bc.fix(:,1),1),bc.node(bc.fix(:,1),2),'ms','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',7);

triplot(DT,'-black','LineWidth',3);

noFixNode=length(PRB.bc.node(:,1));
noNode=length(node(:,1));
plot(node(noFixNode:noNode,1),node(noFixNode:noNode,2),'mO','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','Yellow','MarkerSize',7);
%load
plot(bc.node(bc.load(:,1),1),bc.node(bc.load(:,1),2),'mV','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','red','MarkerSize',7);
%support
plot(bc.node(bc.fix(:,1),1),bc.node(bc.fix(:,1),2),'ms','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',7);
til=sprintf('Best Individual\n');
title(til,'FontWeight','bold')
end