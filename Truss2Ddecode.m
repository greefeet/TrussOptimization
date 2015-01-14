function [node, member] = Truss2Ddecode(indi)
%Truss2Ddecode Decode from design varaible to structure

%Global Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global NOF;             % From Encode Function
global PRB;             % From Problem Function

%Decode %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%STEP0 - DecodeDATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FixData=indi(1:1:NOF.FixNode*NOF.EachFixNode);
FixData=reshape(FixData,[],NOF.FixNode)';
FreeData=indi(NOF.FixNode*NOF.EachFixNode+1:1:length(indi));
FreeData=reshape(FreeData,[],NOF.FreeNode)';

%STEP1 - Preallowcate %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CrossSectionSet = struct('SectionIndex',zeros(1,NOF.CrossSectionSet),'Priority',zeros(1,NOF.CrossSectionSet));
IndeterminateSet = zeros(1,NOF.IndeterminateZone);
Raw = repmat(struct('crossSection',CrossSectionSet,'indeStruct',IndeterminateSet), NOF.FixNode+NOF.FreeNode, 1 );
rawNode = zeros(NOF.FixNode+NOF.FreeNode,2);
rawAd = zeros(NOF.FixNode+NOF.FreeNode,2);

%STEP2 - DecodeNode %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%STEP3 - DecodeConnectivity %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DelaunayTriangulation
tri=delaunayTriangulation(node).ConnectivityList;
triSize=size(tri); noTri=triSize(1);
if noTri==0
    member=[];
    return;
end

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
                if dNode(nJ).isHave(nK)     % Check node is linked
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

%STEP4 - Decode CrossSection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        crossSectionIndex = crossSectionSet(dNode(i).DirectNodeZone(j),dNode(i).DirectNodeLayer(j)); 
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
        crossSectionIndex = crossSectionSet(dNode(i).OutNodeZone(j),dNode(i).OutNodeLayer(j));
        priority = prioritySet(dNode(i).OutNodeZone(j),dNode(i).OutNodeLayer(j));
        
        isUsed = indeterminateSet(dNode(i).OutNodeZone(j),dNode(i).OutNodeIndeLayer(j));
        dNode(i) = dNode(i).SpectOutNode(j,crossSectionIndex,priority,isUsed);
    end
end

%STEP5 - Build Member %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rMember=zeros(noTotalMember,5);
noMember = 0;
switch PRB.dv.TypeSection
    case TypeSection.Discrete
        %Discrete CrossSection
        for i=1:noNode
            %Build Member from Determinate Structure
            for j=1:dNode(i).noDirectNode 
                noMember = noMember+1;
                temp(1)=i;temp(2)=dNode(i).DirectNode(j);
                rMember(noMember,1) = min(temp);
                rMember(noMember,2) = max(temp);
                SectionIndex = round(dNode(i).DirectNodeSectionIndex(j));
                rMember(noMember,3) = PRB.dv.crossSection(SectionIndex,1);
                rMember(noMember,4) = PRB.dv.crossSection(SectionIndex,2);
                rMember(noMember,5) = dNode(i).DirectNodeSectionPriority(j);
            end

            %Build Member from Indeterminate Structure
            for j=1:dNode(i).noOutNode 
                if round(dNode(i).OutNodeSectionIsUsed(j)) == 1         %Can Change Search only determiniate Structure here!
                    noMember = noMember+1;
                    temp(1)=i;temp(2)=dNode(i).OutNode(j);
                    rMember(noMember,1) = min(temp);
                    rMember(noMember,2) = max(temp);
                    SectionIndex = round(dNode(i).OutNodeSectionIndex(j));
                    rMember(noMember,3) = PRB.dv.crossSection(SectionIndex,1);
                    rMember(noMember,4) = PRB.dv.crossSection(SectionIndex,2);
                    rMember(noMember,5) = dNode(i).OutNodeSectionPriority(j);
                end
            end
        end
    case TypeSection.Continuous
        %Continuous CrossSection
        for i=1:noNode
            %Build Member from Determinate Structure
            for j=1:dNode(i).noDirectNode 
                noMember = noMember+1;
                temp(1)=i;temp(2)=dNode(i).DirectNode(j);
                rMember(noMember,1) = min(temp);
                rMember(noMember,2) = max(temp);
                rMember(noMember,3) = dNode(i).DirectNodeSectionIndex(j);
                rMember(noMember,4) = dNode(i).DirectNodeSectionIndex(j);
                rMember(noMember,5) = dNode(i).DirectNodeSectionPriority(j);
            end

            %Build Member from Indeterminate Structure
            for j=1:dNode(i).noOutNode 
                if round(dNode(i).OutNodeSectionIsUsed(j)) == 1 %Can Change Search only determiniate Structure here!
                    noMember = noMember+1;
                    temp(1)=i;temp(2)=dNode(i).OutNode(j);
                    rMember(noMember,1) = min(temp);
                    rMember(noMember,2) = max(temp);
                    rMember(noMember,3) = dNode(i).OutNodeSectionIndex(j);
                    rMember(noMember,4) = dNode(i).OutNodeSectionIndex(j);
                    rMember(noMember,5) = dNode(i).OutNodeSectionPriority(j);
                end
            end
        end
end

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
end