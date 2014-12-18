function [node member] = Truss2Ddecode(indi)
%Truss2Ddecode Decode from design varaible to structure

%Global Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global NOF;             % From Encode Function
global PRB;             % From Problem Function

%Decode %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%STEP0 - DecodeDATA to Raw
FixData=indi(1:1:NOF.FixNode*NOF.EachFixNode);
FixData=reshape(FixData,[],NOF.FixNode)';
FreeData=indi(NOF.FixNode*NOF.EachFixNode+1:1:length(indi));
FreeData=reshape(FreeData,[],NOF.FreeNode)';

%Preallowcate
% ConnectivitySet = struct('SectionIndex',zeros(1,NOF.CrossSectionSet),'Priority',zeros(1,NOF.CrossSectionSet));
CrossSectionSet = struct('SectionIndex',zeros(1,NOF.CrossSectionSet),'Priority',zeros(1,NOF.CrossSectionSet));
IndeterminateSet = zeros(1,NOF.IndeterminateZone);
Raw = repmat(struct('crossSection',CrossSectionSet,'indeStruct',IndeterminateSet), NOF.FixNode+NOF.FreeNode, 1 );
rawNode = zeros(NOF.FixNode+NOF.FreeNode,2);
rawAd = zeros(NOF.FixNode+NOF.FreeNode,2);

%STEP1 - DecodeNode
noNode = 0;
for i=1:NOF.FixNode
    %node
    noNode=noNode+1;
    rawNode(noNode,1:2) = [PRB.bc.node(i,1) PRB.bc.node(i,2)];
    rawAd(noNode,1) = i;
    
    %Prepare CrossSectionData
    Raw(i).crossSection.SectionIndex = FixData(1,1:NOF.CrossSectionSet); 
    Raw(i).crossSection.Priority = FixData(i,NOF.CrossSectionSet+1:NOF.CrossSectionSet*2);
    
    %Prepare IndeterminateStructureData
    Raw(i).indeStruct = FixData(i,NOF.CrossSectionSet*2 + 1:NOF.CrossSectionSet*2 + NOF.IndeterminateZone);
end
for i=1:NOF.FreeNode
    nI = NOF.FixNode+i; 
    
    %node
    if FreeData(i,3) >= 0.5
        noNode=noNode+1;
        rawNode(noNode,1:2) = [FreeData(i,1) FreeData(i,2)];
        rawAd(noNode,1) = nI;
    end
    
    %Prepare CrossSection
    Raw(nI).crossSection.SectionIndex = FreeData(i,3+1:3+NOF.CrossSectionSet);
    Raw(nI).crossSection.Priority = FreeData(i,3+NOF.CrossSectionSet+1:3+NOF.CrossSectionSet*2);
     
    %Prepare IndeterminateStructureData
    Raw(nI).indeStruct = FreeData(i,3+NOF.CrossSectionSet*2+1:3+NOF.CrossSectionSet*2+NOF.IndeterminateZone);
end
node = rawNode(1:noNode,1:2); 
ad = rawAd(1:noNode,1);

%STEP2 - DecodeConnectivity
%DelaunayTriangulation
x=node(:,1);  y=node(:,2);  tri = delaunay(x,y);  noTri=length(tri(:,1));
%Preallowcate
dNode = Node.empty(noNode,0);
for i=1:noNode
    dNode(i)=Node(node(i,1),node(i,2),NOF.Section);
end
%Determinate Structure
for i=1:noTri
    n1 = tri(i,1);
    n2 = tri(i,2);
    n3 = tri(i,3);
    
    dNode(n1) = dNode(n1).AddDirectNode(n2,node(n2,1),node(n2,2));
    dNode(n1) = dNode(n1).AddDirectNode(n3,node(n3,1),node(n3,2));
     
    dNode(n2) = dNode(n2).AddDirectNode(n1,node(n1,1),node(n1,2));
    dNode(n2) = dNode(n2).AddDirectNode(n3,node(n3,1),node(n3,2));
    
    dNode(n3) = dNode(n3).AddDirectNode(n1,node(n1,1),node(n1,2));
    dNode(n3) = dNode(n3).AddDirectNode(n2,node(n2,1),node(n2,2));
end
%Indeterminate Structure
for i=1:noNode
    if dNode(i).noDirectNode>1
        for j=2:dNode(i).noDirectNode
            for k=1:j-1
                nJ = dNode(i).DirectNode(j);
                nK = dNode(i).DirectNode(k);
                % Check node is linked
                if dNode(nJ).isHave(nK)
                    for l=1:dNode(nJ).noDirectNode
                        nL = dNode(nJ).DirectNode(l);
                        if nL ~= i && dNode(nK).isHave(nL)
                            dNode(i) = dNode(i).AddOutNode(nL,node(nL,1),node(nL,2));
                        end
                    end
                end
            end
        end
    end
end

%STEP2 - Decode CrossSection
noTotalMember = 0;
for i=1:noNode
    noTotalMember = noTotalMember + dNode(i).noDirectNode + dNode(i).noOutNode;
    %Sort Each Layer
    for j=1:NOF.Section
        %Deteminate Structure
        noThisSection = dNode(i).noEachSection(j);
        if noThisSection > 0
            tempLayer = dNode(i).layerZone(j,1:noThisSection);
            dNode(i).layerZone(j,1:noThisSection) = sort(tempLayer);
        end
        %Indeterminate Structure
        noThisSection = dNode(i).noIndeEachSection(j);
        if noThisSection > 0
            tempLayer = dNode(i).indeLayerZone(j,1:noThisSection);
            dNode(i).indeLayerZone(j,1:noThisSection) = sort(tempLayer);
        end
    end
    
    %DecodeLayer DeteminateStructure
    for j=1:dNode(i).noDirectNode
        nowZone = dNode(i).DirectNodeZone(j);
        
        %Specific LayerIndex
        if dNode(i).noEachSection(nowZone)==1
            dNode(i).DirectNodeLayer(j) = 1;
        else
            isSet = 0;
            maxLoop = NOF.SectionLayer;
            if dNode(i).noEachSection(nowZone) < NOF.SectionLayer
                maxLoop = dNode(i).noEachSection(nowZone);
            end
            for k=1:maxLoop
                if dNode(i).DirectNodeLength(j) <= dNode(i).layerZone(nowZone,k)
                    dNode(i).DirectNodeLayer(j) = k;
                    isSet = 1;
                    break;
                end
            end
            if isSet==0
                dNode(i).DirectNodeLayer(j) = NOF.SectionLayer;
            end
        end
        
        %Specific CrossSectionIndex
        crossSectionSet = reshape(Raw(ad(i)).crossSection.SectionIndex,NOF.SectionLayer,NOF.Section)';
        prioritySet = reshape(Raw(ad(i)).crossSection.Priority,NOF.SectionLayer,NOF.Section)';
        
        crossSectionIndex = round(crossSectionSet(dNode(i).DirectNodeZone(j),dNode(i).DirectNodeLayer(j)));
        priority = prioritySet(dNode(i).DirectNodeZone(j),dNode(i).DirectNodeLayer(j));
        dNode(i) = dNode(i).SpectDirectNode(j,crossSectionIndex,priority);
    end
    
    %DecodeLayer IndeteminateStructure
    for j=1:dNode(i).noOutNode
        nowZone = dNode(i).OutNodeZone(j);
        
        %Specific LayerIndex
        if dNode(i).noEachSection(nowZone)==1
            dNode(i).OutNodeLayer(j) = 1;
        else
            isSet = 0;
            maxLoop = NOF.SectionLayer;
            if dNode(i).noEachSection(nowZone) < NOF.SectionLayer
                maxLoop = dNode(i).noEachSection(nowZone);
            end
            for k=1:maxLoop
                if dNode(i).OutNodeLength(j) <= dNode(i).layerZone(nowZone,k)
                    dNode(i).OutNodeLayer(j) = k;
                    isSet = 1;
                    break;
                end
            end
            if isSet==0
                dNode(i).OutNodeLayer(j) = NOF.SectionLayer;
            end
        end
        
        %Specific IndeLayerIndex
        if dNode(i).noIndeEachSection(nowZone)==1
            dNode(i).OutNodeIndeLayer(j) = 1;
        else
            isSet = 0;
            maxLoop = NOF.IndeterminateLayer;
            if dNode(i).noIndeEachSection(nowZone) < NOF.IndeterminateLayer
                maxLoop = dNode(i).noIndeEachSection(nowZone);
            end
            for k=1:maxLoop
                if dNode(i).OutNodeLength(j) <= dNode(i).indeLayerZone(nowZone,k)
                    dNode(i).OutNodeIndeLayer(j) = k;
                    isSet = 1;
                    break;
                end
            end
            if isSet==0
                dNode(i).OutNodeIndeLayer(j) = NOF.IndeterminateLayer;
            end
        end
         
        %Specific CrossSectionIndex & IndeteminateIsUsed
        crossSectionSet = reshape(Raw(ad(i)).crossSection.SectionIndex,NOF.SectionLayer,NOF.Section)';
        prioritySet = reshape(Raw(ad(i)).crossSection.Priority,NOF.SectionLayer,NOF.Section)';
        indeterminateSet = reshape(Raw(ad(i)).indeStruct,NOF.IndeterminateLayer,NOF.Section)';
        crossSectionIndex = round(crossSectionSet(dNode(i).OutNodeZone(j),dNode(i).OutNodeLayer(j)));
        priority = prioritySet(dNode(i).OutNodeZone(j),dNode(i).OutNodeLayer(j));
        
        isUsed = indeterminateSet(dNode(i).OutNodeZone(j),dNode(i).OutNodeIndeLayer(j));
        dNode(i) = dNode(i).SpectOutNode(j,crossSectionIndex,priority,isUsed);
    end
    
    
%     dNode(i) 
    
end
% fprintf('TotalMember : %d\n',noTotalMember);
%Build Member
rMember=zeros(noTotalMember,5);
noMember = 0;
for i=1:noNode
    %Build Member from Determinate Structure
    for j=1:dNode(i).noDirectNode 
        noMember = noMember+1;
        temp(1)=i;temp(2)=dNode(i).DirectNode(j);
        rMember(noMember,1) = min(temp);
        rMember(noMember,2) = max(temp);
        rMember(noMember,3) = PRB.dv.crossSection(dNode(i).DirectNodeSectionIndex(j),1);
        rMember(noMember,4) = PRB.dv.crossSection(dNode(i).DirectNodeSectionIndex(j),2);
        rMember(noMember,5) = dNode(i).DirectNodeSectionPriority(j);
    end
    
    %Build Member from Determinate Structure
    for j=1:dNode(i).noOutNode 
        if dNode(i).OutNodeSectionIsUsed(j) == 1
            noMember = noMember+1;
            temp(1)=i;temp(2)=dNode(i).OutNode(j);
            rMember(noMember,1) = min(temp);
            rMember(noMember,2) = max(temp);
            rMember(noMember,3) = PRB.dv.crossSection(dNode(i).OutNodeSectionIndex(j),1);
            rMember(noMember,4) = PRB.dv.crossSection(dNode(i).OutNodeSectionIndex(j),2);
            rMember(noMember,5) = dNode(i).OutNodeSectionPriority(j);
        end
    end
end 
% rMember
% fprintf('------------------------------------\n');
rMember = sortrows(rMember,[1 2 -5]);
oldNode = [0 0];
nowMember=0;
for i=1:noTotalMember
    if rMember(i,1) ~= oldNode(1) || rMember(i,2) ~= oldNode(2)
        oldNode = [rMember(i,1) rMember(i,2)];
        nowMember = nowMember + 1;
        member(nowMember,1:4) = rMember(i,1:4);
    end
end
% member
% pause
% 
% % rawMember=zeros(noTri*3,2);
% % for i=1:noTri
% %     temp(1)=tri(i,1);temp(2)=tri(i,2);
% %     rawMember(i*3-2,1)=min(temp);
% %     rawMember(i*3-2,2)=max(temp);
% %     
% %     temp(1)=tri(i,2);temp(2)=tri(i,3);
% %     rawMember(i*3-1,1)=min(temp);
% %     rawMember(i*3-1,2)=max(temp);
% %     
% %     temp(1)=tri(i,3);temp(2)=tri(i,1);
% %     rawMember(i*3,1)=min(temp);
% %     rawMember(i*3,2)=max(temp);
% % end
% 
% %Indeterminate Structure
% rawMember=unique(rawMember,'rows');
% noMember=length(rawMember(:,1));
% 
% %STEP3 - DecodeCrossSection
% member=zeros(noMember,4);
% for i=1:noMember
% %     [pri1 sec1]=getSectionData(Raw(ad(rawMember(i,1))),Raw(ad(rawMember(i,2))));
% %     [pri2 sec2]=getSectionData(Raw(ad(rawMember(i,2))),Raw(ad(rawMember(i,1))));
% 
%     pri1 = 0.8; pri2=0.7;
%     sec1 = 20; sec2 = 25;
%     
%     member(i,1)=rawMember(i,1);
%     member(i,2)=rawMember(i,2);
%     if pri1>pri2
%         member(i,3)=PRB.dv.crossSection(round(sec1),1);
%         member(i,4)=PRB.dv.crossSection(round(sec1),2);
%     else
%         member(i,3)=PRB.dv.crossSection(round(sec2),1);
%         member(i,4)=PRB.dv.crossSection(round(sec2),2);
%     end
% end
% % member
% % pause
end
function [pri index] = getSectionData(fromNode,toNode)
%     fromNode.crossSection
%     toNode.crossSection
%     pause
    pri = 0.8;
    index = 20;
end
function [pri index] = getPriority(node1,node2,node,FixData,FreeData,adap)
    global noFixNode;
    global noSection;
    angle=getAngle(node(node1,:),node(node2,:));
    sIndex=ceil(angle*noSection/360);
    if node1<=noFixNode
        index=FixData(node1,sIndex);
        pri=FixData(node1,sIndex+noSection);
    else
        index=FreeData(adap(node1-noFixNode),3+sIndex);
        pri=FreeData(adap(node1-noFixNode),3+sIndex+noSection);
    end
end
function [angle]=getAngle(node1,node2)
    tX=node2(1)-node1(1);
    tY=node2(2)-node1(2);
    if node1(1)<node2(1)&&node1(2)<node2(2)
        %#1
        angle=90-radtodeg(cart2pol(tX,tY));
    elseif node1(1)<=node2(1)&&node1(2)>=node2(2)
        %#2
        angle=90-radtodeg(cart2pol(tX,tY));
    elseif node1(1)>node2(1)&&node1(2)>node2(2)
        %#3
        angle=90-radtodeg(cart2pol(tX,tY));
    else
        %#4
        angle=450-radtodeg(cart2pol(tX,tY));
    end
    if isnan(angle)
        angle=360;
    end
end
