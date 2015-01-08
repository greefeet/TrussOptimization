function Truss2Dverify(indi)
%Truss2Dverify %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PRB;
bc =  PRB.bc;
dv = PRB.dv;
mp = PRB.mp;
prob = PRB.info.prob;

fprintf('[Validate Results]\n');
fitness=Truss2D(indi);
fprintf('     fitness: %.0f\n',fitness);

%Transform RAW Data to Truss Structure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[node, member] = Truss2Ddecode(indi);
numberMember=length(member(:,1));
numberNode=length(node(:,1));
no=length(bc.fix(:,1));
r=0;
for i=1:no
    r=r+bc.fix(i,2)+bc.fix(i,3);
end
fprintf('[Detail]\n');
fprintf('        node: %d\n',numberNode);
fprintf('      member: %d\n',numberMember);
fprintf('[Stability]\n');

%Check b+r>=2*j %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('    b+r>=2*j: ');
gB=numberMember;
gJ=numberNode;
gR=0;
for i=1:length(bc.fix(:,1))
    gR=gR+bc.fix(i,2)+bc.fix(i,3);
end
if gB+gR>=2*gJ
    fprintf('Pass\n');
else
    fprintf('NotPass\n');
end

%Check Stability %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('    GroupSt.: ');
[result, group]=validateStability(node,member);
region=[dv.xMin dv.xMax dv.yMin dv.yMax];
if result > 0
    fprintf('Pass\n');
else
    fprintf('NotPass\n');
    drawGroup(node,group,bc.load,bc.fix,region,member,dv.crossSection);
    return;
end

%Structure Analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('[Structural Analysis] ');
sa(node,member);
[stress, disX, disY]=sa_results;
if ~isempty(stress)
    fprintf('AnalysisComplete\n');
else
    fprintf('ErrorAnalysis\n');
    return;
end

%Check Member Constraints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
countPass=0;
weight=0;
checkMember=1:numberMember;
for i=1:numberMember
    fprintf('   Member%d\n',i);
    fprintf('      StartNode   : (%.1f,%.1f)\n',node(member(i,1),1),node(member(i,1),2));
    fprintf('      StopNode    : (%.1f,%.1f)\n',node(member(i,2),1),node(member(i,2),2));
    tLength=sqrt((node(member(i,1),1)-node(member(i,2),1))^2+(node(member(i,1),2)-node(member(i,2),2))^2);
    fprintf('      Length      : %12.2f\n',tLength);
    fprintf('      SectionArea : %12.2f\n',member(i,3));
    fprintf('      Radi of Gyr : %12.2f\n',member(i,4));
    fprintf('      Stress      : %12.2f ',stress(i));
    weight=weight+tLength*mp.density*member(i,3);
    checkMember(i)=true;

    % Check Stress
    [passed, ~, allowable]=feval(strcat(prob,'cons'),TypeCons.Stress,stress(i),tLength,member(i,4));
    fprintf('(allow: %.0f) ',allowable);
    if passed==1
        fprintf('NotPass\n');
        checkMember(i)=false;
    else
        fprintf('Pass\n');
        countPass=countPass+1;
    end

    % Check slendernessRatio
    slendernessRatio=tLength/member(i,4);
    fprintf('      Slenderness : %12.2f ',slendernessRatio);
    [passed, ~, allowable]=feval(strcat(prob,'cons'),TypeCons.Slender,stress(i),tLength,member(i,4));
    fprintf('(allow: %.0f) ',allowable);
    if passed==1
        fprintf('NotPass\n');
        checkMember(i)=false;
    else
        fprintf('Pass\n');
        countPass=countPass+1;
    end
    fprintf('\n');
end

%Check Node Constraints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:numberNode
    % Check Displacement
    fprintf('   Node%d\n',i);
    [passed , ~, allowable]=feval(strcat(prob,'cons'),TypeCons.Displacement,disX(i));
    fprintf('      coorX : %8.1f, disX : %6.2f (allow: +-%d) ',node(i,1),disX(i),allowable);
    if passed==1
        fprintf('NotPass\n');
    else
        fprintf('Pass\n');
        countPass=countPass+1;
    end
    [passed , ~, allowable]=feval(strcat(prob,'cons'),TypeCons.Displacement,disY(i));
    fprintf('      coorY : %8.1f, disY : %6.2f (allow: +-%d) ',node(i,2),disY(i),allowable);
    if passed==1
        fprintf('NotPass\n');
    else
        fprintf('Pass\n');
        countPass=countPass+1;
    end
    fprintf('\n');
end
NeedPass=2*numberMember+2*numberNode;
fprintf('[Result]\n');
fprintf('   Weight : %7.0f\n',weight);
fprintf('   fitness: %7.0f\n\n',fitness);
if NeedPass>countPass
    fprintf('   Validation Error\n');
    fprintf('   Fail %d case\n',NeedPass-countPass);
else
    fprintf('   Validation complete\n');
end
set(0,'CurrentFigure',3);
displacement=[disX disY];

%Display Structure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plotDis2D(node,displacement,stress,bc.load,bc.fix,region,member,dv.crossSection,checkMember);
end

function [result, Group] = validateStability(~,member)
global PRB;
bc = PRB.bc;
numberMember=size(member);
numberMember=numberMember(1);
Group{numberMember}=[];
for i=1:numberMember
    Group{i}=union(member(i,1),member(i,2));
end

while true
    [loop, Group]=checkGroup(Group);
    if loop==false
        break;
    end
end
noGroup=length(Group);
if noGroup==1
    numberFix=size(bc.fix);
    numberFix=numberFix(1);
    nodeFix=[];
    for i=1:numberFix
        nodeFix=union(nodeFix,bc.fix(i,1));
    end
    if length(intersect(Group{1},nodeFix))==numberFix
        result=100;
    else
        result=-100;
    end

else
    result=-100;
end
end
function [complete, Group]=checkGroup(Group)
noGroup=length(Group);
if noGroup<2
    complete=false;
    return;
elseif noGroup<3
    if length(intersect(Group{1},Group{2}))==length(Group{1}) || length(intersect(Group{1},Group{2}))==length(Group{2})
        Group{1}=union(Group{1},Group{2});
        Group(2)=[];
        complete=false;
        return;
    end
else
    for i=1:noGroup-2
    for j=i+1:noGroup-1
        for k=j+1:noGroup
            intIJ=intersect(Group{i},Group{j});
            intIK=intersect(Group{i},Group{k});
            intJK=intersect(Group{j},Group{k});
            if isequal(intIJ,Group{i})||isequal(intIJ,Group{j})
                Group{i}=union(Group{i},Group{j});
                Group(j)=[];
                complete=true;
                return;
            end
            if isequal(intIK,Group{i})||isequal(intIK,Group{k})
                Group{i}=union(Group{i},Group{k});
                Group(k)=[];
                complete=true;
                return;
            end
            if isequal(intJK,Group{j})||isequal(intJK,Group{k})
                Group{j}=union(Group{j},Group{k});
                Group(k)=[];
                complete=true;
                return;
            end
            if ~isempty(intIJ)
                tIJ=union(setdiff(Group{i}, intIJ),setdiff(Group{j}, intIJ));
                if length(intersect(tIJ,Group{k}))>1
                    Group{i}=union(Group{i},Group{j});
                    Group{i}=union(Group{i},Group{k});
                    if j>k
                        Group(j)=[];
                        Group(k)=[];
                    else
                        Group(k)=[];
                        Group(j)=[];
                    end
                    complete=true;
                    return;
                end
            end
        end
    end
    end
end
complete=false;
end
function result = sa(node,member)
%Structure Analysis by OpenSees
    global PRB;
    mp = PRB.mp;
    bc = PRB.bc;

    %Clear OutputFile
    fid = fopen('File-OutStress.out', 'w');
    fprintf(fid,'');
    fclose(fid);
    fid = fopen('File-OutDisp.out', 'w');
    fprintf(fid,'');
    fclose(fid);

    %Write InputFile
    %initial data
    fileID = fopen('File-Input.tcl','w');
    fprintf(fileID,'wipe\n');
    fprintf(fileID,'model BasicBuilder -ndm 2 -ndf 2\n');

    %loop node
    numberNode=length(node(:,1));
    for i=1:numberNode
        fprintf(fileID,'node %d %.1f %.1f\n',i,node(i,1),node(i,2));
    end

    %loop support
    for i=1:length(bc.fix(:,1))
        fprintf(fileID,'fix %d %d %d\n',bc.fix(i,1),bc.fix(i,2),bc.fix(i,3));
    end

    %loop element
    fprintf(fileID,'uniaxialMaterial Elastic 1 %d\n',mp.elastic); %E=201 GPa
    numberMember=length(member(:,1));
    for i=1:numberMember
        fprintf(fileID,'element truss %d %d %d %.0f 1\n',i,member(i,1),member(i,2),member(i,3));
    end

    %load
    fprintf(fileID,'pattern Plain 1 "Linear" {\n');

    %loop Load
    numberLoad=length(bc.load(:,1));
    for i=1:numberLoad
        fprintf(fileID,'load %d %d %d\n',bc.load(i,1),bc.load(i,2),bc.load(i,3));
    end
    fprintf(fileID,'}\n');

    %final data
    fprintf(fileID,'system SparseGEN\n');
    fprintf(fileID,'numberer RCM\n');
    fprintf(fileID,'constraints Plain\n');
    fprintf(fileID,'integrator LoadControl 1.0\n');
    fprintf(fileID,'algorithm Linear\n');
    fprintf(fileID,'analysis Static\n');
    fprintf(fileID,'recorder Node -file File-OutDisp.out -node ');
    fprintf(fileID,'%d ',1:numberNode);
    fprintf(fileID,'-dof 1 2 disp\n');
    fprintf(fileID,'recorder Element -file File-OutStress.out -ele ');
    fprintf(fileID,'%d ',1:numberMember);
    fprintf(fileID,'material stress\n');
    fprintf(fileID,'analyze 1\n');
    fprintf(fileID,'quit\n');
    fclose(fileID);


    %run OpenSees
    [~,sout]=system('OpenSees.exe File-Input.tcl');

    if isempty(strfind(sout,'analyze failed'))
        result = true;
    else
        result = false;
    end
end
function [stress, disX, disY] = sa_results

    % Load Stress
    fid = fopen('File-OutStress.out');
    stress = fscanf(fid, '%f ');
    str=fscanf(fid,'%s');
    if ~isempty(strfind(str,'#'))
        stress=[];
    end
    fclose(fid);

    % Load Displacement
    fid = fopen('File-OutDisp.out');
    displacement = fscanf(fid,'%f ');
    numberNode=length(displacement);
    disX=displacement(1:2:numberNode);
    disY=displacement(2:2:numberNode);
    fclose(fid);
end
function [h]=plotDis2D(node,displacement,stress,load,fix,region,element,crossSection,checkMember)
% plot Input - Node Support Element Load
clf
global PRB;
hold on
daspect([1 1 1]); xlabel('x');ylabel('y');zlabel('z');

maxDis=max(abs(displacement));
maxDis=max(maxDis);

height=region(4)-region(3);
ratio=height*0.1/maxDis;
draw=node+ratio*displacement;
no=size(element);
no=no(1);
% maxA=max(crossSection);
% minA=min(crossSection);
switch PRB.dv.TypeSection
    case TypeSection.Discrete
        maxA=max(dv.crossSection(:,1));
        minA=min(dv.crossSection(:,1));
    case TypeSection.Continuous
        maxA=PRB.dv.sectionMax;
        minA=PRB.dv.sectionMin;
end

for i=1:no
    lw=1+4*(element(i,3)-minA)/(maxA-minA);
    plot(node(element(i,1:2),1),node(element(i,1:2),2),'-black','LineWidth',lw);
end

for i=1:no
    lw=1;
    if stress(i)>0
        line='--green';
    else
        line='--red';
    end
    plot(draw(element(i,1:2),1),draw(element(i,1:2),2),line,'LineWidth',lw);
end

plot(node(fix(:,1),1),node(fix(:,1),2),'ms','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',7);
h=plot(node(load(:,1),1),node(load(:,1),2),'mV','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','red','MarkerSize',7);
for i=1:length(node)
    tt=sprintf('%d',i);
    [passedX, ~, ~]=feval(strcat(PRB.info.prob,'cons'),4,displacement(i,1));
    [passedY, ~, ~]=feval(strcat(PRB.info.prob,'cons'),4,displacement(i,2));
    if passedX ~=0 || passedY ~= 0
        color=[.9 .9 .7];
    else
        color=[.7 .9 .7];
    end
    text(node(i,1),node(i,2),tt,'BackgroundColor',color,'EdgeColor','black')
end
for i=1:no
    nowX=(node(element(i,1),1)+node(element(i,2),1))/2;
    nowY=(node(element(i,1),2)+node(element(i,2),2))/2;

    if checkMember(i)==true
        ttColor='yellow';
    else
        ttColor='red';
    end
    tt=sprintf('%d',i);
    text(nowX,nowY,tt,'BackgroundColor',ttColor)
end
height=region(4)-region(3);
height=height*0.7;
width=region(2)-region(1);
width=width*0.2;
if width<height
    height=width;
else
    width=height;
end
axis([region(1)-width region(2)+width region(3)-height region(4)+height])
end
function [h]=drawGroup(node,group,load,fix,region,element,crossSection)
% plot Input - Node Support Element Load
clf
hold on
daspect([1 1 1]); xlabel('x');ylabel('y');zlabel('z');

no=size(element);
no=no(1);
maxA=max(crossSection);
minA=min(crossSection);
for i=1:no
    lw=1+4*(element(i,3)-minA)/(maxA-minA);
    color='-black';
    if length(intersect(element(i,1:2),group{1}))>1
        color='-red';
    elseif length(intersect(element(i,1:2),group{2}))>1
        color='-blue';
    elseif length(intersect(element(i,1:2),group{3}))>1
        color='-green';
    elseif length(intersect(element(i,1:2),group{4}))>1
        color='-cyan';
    elseif length(intersect(element(i,1:2),group{5}))>1
        color='-magenta';
    elseif length(intersect(element(i,1:2),group{6}))>1
        color='-yellow';
    end

    plot(node(element(i,1:2),1),node(element(i,1:2),2),color,'LineWidth',lw);
end

element=sortrows(element,[1 2])
noGroup=length(group);
fprintf('\n[StabilityDetail]\n');
for i=1:noGroup
    fprintf('Group : %d\n',i);
    noMember=length(group{i});
    for j=1:noMember-1
        fprintf('   %2d-%2d (%2d-%2d) (%d,%d)-(%d,%d)\n',j,j+1,group{i}(j),group{i}(j+1),node(group{i}(j),1),node(group{i}(j),2),node(group{i}(j+1),1),node(group{i}(j+1),2));
    end
end


plot(node(fix(:,1),1),node(fix(:,1),2),'ms','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',7);
h=plot(node(load(:,1),1),node(load(:,1),2),'mV','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','red','MarkerSize',7);
numberFix=size(fix);
numberFix=numberFix(1);
numberLoad=size(load);
numberLoad=numberLoad(1);
numberNode=size(node);
numberNode=numberNode(1);
startFee=numberFix+numberLoad;

plot(node(startFee+1:numberNode,1),node(startFee+1:numberNode,2),'mO','LineWidth',1,'MarkerEdgeColor','b','MarkerFaceColor','yellow','MarkerSize',7);
for i=1:numberNode
    text(node(i,1)+50,node(i,2)+50,sprintf('%d',i));
end

height=region(4)-region(3);
height=height*0.7;
width=region(2)-region(1);
width=width*0.2;
if width<height
    height=width;
else
    width=height;
end
axis([region(1)-width region(2)+width region(3)-height region(4)+height])
end