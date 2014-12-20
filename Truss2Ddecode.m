function [node member] = Truss2Ddecode(indi)
%Truss2Ddecode Decode from design varaible to structure

%Global Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global NOF;             % From Encode Function
global PRB;             % From Problem Function

%Decode %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf('\n>>Performance\n'); 
% tic
%STEP0 - DecodeDATA
FixData=indi(1:1:NOF.FixNode*NOF.EachFixNode);
FixData=reshape(FixData,[],NOF.FixNode)';
FreeData=indi(NOF.FixNode*NOF.EachFixNode+1:1:length(indi));
FreeData=reshape(FreeData,[],NOF.FreeNode)';
% s(1)=toc;

%STEP1 - Preallowcate
% tic 
CrossSectionSet = struct('SectionIndex',zeros(1,NOF.CrossSectionSet),'Priority',zeros(1,NOF.CrossSectionSet));
IndeterminateSet = zeros(1,NOF.IndeterminateZone);
Raw = repmat(struct('crossSection',CrossSectionSet,'indeStruct',IndeterminateSet), NOF.FixNode+NOF.FreeNode, 1 );
rawNode = zeros(NOF.FixNode+NOF.FreeNode,2);
rawAd = zeros(NOF.FixNode+NOF.FreeNode,2);
% s(2)=toc;

%STEP2 - DecodeNode
% tic
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
% s(3)=toc;

%STEP3 - DecodeConnectivity 
%DelaunayTriangulation
% tic
x=node(:,1);  y=node(:,2);  tri = delaunay(x,y);  noTri=length(tri(:,1));
% e(1)=toc;

%Preallowcate
% tic
dNode = Node.empty(noNode,0);
for i=1:noNode
    dNode(i)=Node(node(i,1),node(i,2),NOF.Section);
end
% e(2)=toc;

%Determinate Structure
% tic
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
% e(3)=toc;

%Indeterminate Structure
% tic
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
% e(4)=toc; 
% s(4)=toc;

%STEP4 - Decode CrossSection
% tic
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
end
% s(5)=toc;

%STEP5 - Build Member
% tic
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
    
    %Build Member from Indeterminate Structure
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
% s(6)=toc;
% 
% 
% % eSum = sum(e);
% % s(4)=eSum;
% sSum = sum(s);
% 
% fprintf('  Total : %f\n',sSum);
% fprintf('  STEP0 - DecodeDATA          : %f (%f%%)\n',s(1),s(1)/sSum*100);
% fprintf('  STEP1 - Preallowcate        : %f (%f%%)\n',s(2),s(2)/sSum*100);
% fprintf('  STEP2 - DecodeNode          : %f (%f%%)\n',s(3),s(3)/sSum*100);
% % fprintf('  --------------------------------------\n'); 
% fprintf('  STEP3 - DecodeConnectivity  : %f (%f%%)\n',s(4),s(4)/sSum*100);
% % fprintf('  --------------------------------------\n'); 
% % fprintf('    DelaunayTriangulation     : %f (%f%%)\n',e(1),e(1)/eSum*100);
% % fprintf('    Preallowcate              : %f (%f%%)\n',e(2),e(2)/eSum*100);
% % fprintf('    DeterminateStructure      : %f (%f%%)\n',e(3),e(3)/eSum*100);
% % fprintf('    IndeterminateStructure    : %f (%f%%)\n',e(4),e(4)/eSum*100); 
% % fprintf('  --------------------------------------\n'); 
% 
% fprintf('  STEP4 - DecodeCrossSection  : %f (%f%%)\n',s(5),s(5)/sSum*100);
% fprintf('  STEP5 - BuildMember         : %f (%f%%)\n',s(6),s(6)/sSum*100);
% pause
end
