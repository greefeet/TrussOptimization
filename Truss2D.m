function [fitness, penalty, weight] = Truss2D(indi)
%Truss2D fitness [in] mp,bc,dv [out] fitness,penalty,weight
[node, member]=Truss2Ddecode(indi);                   %Decode individual
[fitness, penalty, weight]=getFitness(node,member);   %Calculate Fitness
end
function result = sa_run(node,member)
%Structure Analysis by OpenSees
    global PRB;
    mp = PRB.mp;    %Material Properties
    bc = PRB.bc;    %Boundary Condition

    %Clear OutputFile
    [fid, mess] = fopen('File-OutStress.out', 'w');
    while fid<0
        fprintf('ERROR : %s\n',mess);
        [fid, mess] = fopen('File-OutStress.out', 'w');
    end
    fclose(fid);

    [fid, mess] = fopen('File-OutDisp.out', 'w');
    while fid<0
        fprintf('ERROR : %s\n',mess);
        [fid, mess] = fopen('File-OutDisp.out', 'w');
    end
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
        fprintf(fileID,'element truss %d %d %d %d 1\n',i,member(i,1),member(i,2),member(i,3));
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
    fprintf(fileID,'system BandSPD\n');
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
    [~,sout]=system('OpenSeesHelper.exe File-Input.tcl');

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
    fclose(fid);

    % Load Displacement
    fid = fopen('File-OutDisp.out');
    displacement = fscanf(fid,'%f ');
    numberNode=length(displacement);
    disX=displacement(1:2:numberNode);
    disY=displacement(2:2:numberNode);
    fclose(fid);

    % Delay Temporary Fix Load Output
    order = 1;
    while (numel(disX)==0 || ~isempty(strfind(str,'#'))) && order < 10
        order = order + 1;
        pause(0.01);
        system('OpenSeesHelper.exe File-Input.tcl');
        [stress,disX,disY] = sa_results;
    end

    % Delay Temporary Fix Load Stress
    if ~isempty(strfind(str,'#')) || numel(disX)==0
        stress = [];
        disX = [];
        disY = [];
    end

end
function [fitness, penalty, weight] = getFitness(node,member)
    global showDetail;
    global NOF;
    global PRB;
    mp = PRB.mp;                        %Material Properties
    prob = PRB.info.prob;

    sa_run(node,member);                %Run OpenSees
    [stress, disX, disY]=sa_results;    %Get Results

    noNode=length(node(:,1));
    noMember=length(member(:,1));

    %Calculate Weight
    weight=0;
    for i=1:noMember
        tX=(node(member(i,1),1)-node(member(i,2),1))^2;
        tY=(node(member(i,1),2)-node(member(i,2),2))^2;
        tLength=sqrt(tX+tY);
        weight=weight+tLength*mp.density*member(i,3);
    end

    clength=0;
    cstress=0;
    cslender=0;
    cdis=0;

    penalLength=0;
    penalStress=0;
    penalSlenderness=0;
    penalDis=0;

    pLength=1/noMember*weight;
    pStress=1/noMember*weight;
    pSlender=1/noMember*weight;
    pDis=1/noNode/2*weight;
    penalty=0;

    % Constraints Details
    if showDetail==1
        barMemberLength=zeros(noMember,1);
        barMemberStress=zeros(noMember,1);
        barMemberSlender=zeros(noMember,1);
        barNodeDisplacement=zeros(noNode,2);
    end
    inStability=1;
if ~isempty(stress)
    for i=1:noMember
        tX=(node(member(i,1),1)-node(member(i,2),1))^2;
        tY=(node(member(i,1),2)-node(member(i,2),2))^2;
        tLength=sqrt(tX+tY);

        % Member Length
        [passed, scale]=feval(strcat(prob,'cons'),1,tLength);
        penalLength=penalLength+scale*pLength*passed;
        clength=clength+passed;
        barMemberLength(i)=scale;

        % Check Allowable stress
        [passed, scale]=feval(strcat(prob,'cons'),2,stress(i),tLength,member(i,4));
        penalStress=penalStress+scale*pStress*passed;
        cstress=cstress+passed;
        barMemberStress(i)=scale;

        % Slenderness Ratio
        [passed, scale]=feval(strcat(prob,'cons'),3,stress(i),tLength,member(i,4));
        penalSlenderness=penalSlenderness+scale*pSlender*passed;
        cslender=cslender+passed;
        barMemberSlender(i)=scale;
    end

    for i=1:noNode
        % x Displacement
        [passed, scale]=feval(strcat(prob,'cons'),4,disX(i));
        penalDis=penalDis+scale*pDis*passed;
        cdis=cdis+passed;
        barNodeDisplacement(i,1)=scale;

        % y Displacement
        [passed, scale]=feval(strcat(prob,'cons'),4,disY(i));
        penalDis=penalDis+scale*pDis*passed;
        cdis=cdis+passed;
        barNodeDisplacement(i,2)=scale;
    end

else
    NOF.Instability = NOF.Instability + 1;
    fprintf('\nInStability :  %d\n',NOF.Instability);
    inStability=0;
    for i=1:noMember
        tX=(node(member(i,1),1)-node(member(i,2),1))^2;
        tY=(node(member(i,1),2)-node(member(i,2),2))^2;
        tLength=sqrt(tX+tY);

        % Member Length
        [passed, scale]=feval(strcat(prob,'cons'),1,tLength);
        penalLength=penalLength+scale*pLength*passed;
        clength=clength+passed;
    end
    cstress=noMember;
    cslender=noMember;
    cdis=noNode*2;
    penalty=weight*10;
end
fitness=weight+(clength/noMember)*weight+(cstress/noMember)*weight+(cslender/noMember)*weight+(cdis/noNode*2)*weight+penalty;
fitness=fitness+penalLength+penalStress+penalSlenderness+penalDis;
penalty=fitness-weight;

if showDetail==1
    set(0,'CurrentFigure',4);
    if inStability==1
        clf
        subplot(2,2,1);
        plot(1:noMember,barMemberLength);
        title('Length');

        subplot(2,2,2);
        plot(1:noMember,barMemberStress);
        title('Stress');

        subplot(2,2,3);
        plot(1:noMember,barMemberSlender);
        title('Slenderness');

        subplot(2,2,4);
        plot(1:noNode,barNodeDisplacement(:,2));
        title('Displacement');
    else
        fprintf('\nInstability\n');
    end
end
end