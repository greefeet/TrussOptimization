function [fitness, penalty, weight] = TrussSymmetry2D(indi)
%Truss2D fitness [in] mp,bc,dv [out] fitness,penalty,weight
[node, member]=TrussSymmetry2Ddecode(indi);           %Decode individual
[fitness, penalty, weight]=getFitness(node,member);   %Calculate Fitness
end
function [fitness, penalty, weight] = getFitness(node,member)
    global showDetail;
    global NOF;
    global PRB;
    mp = PRB.mp;                                %Material Properties
    prob = PRB.info.prob;                       %Problem
    
    memSize=size(member);                       %Critical Case cann't Build Connection
    if memSize(1)==0
        weight=0;
        penalty=PRB.PenaltyConstant*100;
        fitness=penalty;
        return;
    end
    
    isStable = OpenSeesRUN(node,member);        %Run OpenSees
    
    if isStable == true;
        [stress, disX, disY]=OpenSeesRESULTS;   %Get Results
    else
        stress=[]; disX=[]; disY=[];
    end
    
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
    
    penalty=0;
    clength=0;
    cstress=0;
    cslender=0;
    cdis=0;

    penalLength=0;
    penalStress=0;
    penalSlenderness=0;
    penalDis=0;

    pLength=weight/noMember;
    pStress=weight/noMember;
    pSlender=weight/noMember;
    pDis=weight/noNode/2;
    
    % Constraints Details
    if showDetail==1
        barMemberLength=zeros(noMember,1);
        barMemberStress=zeros(noMember,1);
        barMemberSlender=zeros(noMember,1);
        barNodeDisplacement=zeros(noNode,2);
    end
    
if ~isempty(stress)
    for i=1:noMember
        tX=(node(member(i,1),1)-node(member(i,2),1))^2;
        tY=(node(member(i,1),2)-node(member(i,2),2))^2;
        tLength=sqrt(tX+tY);

        % Member Length
        [passed, scale]=feval(strcat(prob,'cons'),TypeCons.Length,tLength);
        penalLength=penalLength+scale*pLength*passed;
        clength=clength+passed;
        barMemberLength(i)=scale;

        % Check Allowable stress
        [passed, scale]=feval(strcat(prob,'cons'),TypeCons.Stress,stress(i),tLength,member(i,4));
        penalStress=penalStress+scale*pStress*passed;
        cstress=cstress+passed;
        barMemberStress(i)=scale;

        % Slenderness Ratio
        switch PRB.dv.TypeSection
            case TypeSection.Discrete
                [passed, scale]=feval(strcat(prob,'cons'),TypeCons.Slender,stress(i),tLength,member(i,4));
            case TypeSection.Continuous
                passed = 0;     scale = 1;
        end
        
        penalSlenderness=penalSlenderness+scale*pSlender*passed;
        cslender=cslender+passed;
        barMemberSlender(i)=scale;
    end

    for i=1:noNode
        % x Displacement
        [passed, scale]=feval(strcat(prob,'cons'),TypeCons.Displacement,disX(i));
        penalDis=penalDis+scale*pDis*passed;
        cdis=cdis+passed;
        barNodeDisplacement(i,1)=scale;

        % y Displacement
        [passed, scale]=feval(strcat(prob,'cons'),TypeCons.Displacement,disY(i));
        penalDis=penalDis+scale*pDis*passed;
        cdis=cdis+passed;
        barNodeDisplacement(i,2)=scale;
    end

else
    NOF.Instability = NOF.Instability + 1;
    fprintf('\nInStability :  %d\n',NOF.Instability);
    isStable=0;
    for i=1:noMember
        tX=(node(member(i,1),1)-node(member(i,2),1))^2;
        tY=(node(member(i,1),2)-node(member(i,2),2))^2;
        tLength=sqrt(tX+tY);

        % Member Length
        [passed, scale]=feval(strcat(prob,'cons'),TypeCons.Length,tLength);
        penalLength=penalLength+scale*pLength*passed;
        clength=clength+passed;
    end
    cstress=noMember;
    cslender=noMember;
    cdis=noNode*2;
    penalty=weight*10;
end

%Penalty by CONSTANT SCORE
if PRB.dv.TypeSection==TypeSection.Continuous && cstress+cslender+cdis+clength > 0
    penalty=penalty+PRB.PenaltyConstant;
end
fitness=penalty;

%Penalty by Condition
fitness=fitness+weight+(clength/noMember)*weight+(cstress/noMember)*weight+(cslender/noMember)*weight+(cdis/noNode*2)*weight;

%Penalty by Violence
fitness=fitness+penalLength+penalStress+penalSlenderness+penalDis;

%Splite Penalty and Weight
penalty=fitness-weight;

if showDetail==1
    set(0,'CurrentFigure',4);
    if isStable==true
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