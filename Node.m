classdef Node
%Node Class is used for Truss2D.m
    
    properties
        x
        y
        
        noDirectNode
        DirectNode
        DirectNodeLength
        DirectNodeAngle
        DirectNodeZone
        DirectNodeLayer
        DirectNodeSectionIndex
        DirectNodeSectionPriority
        
        
        noOutNode
        OutNode
        OutNodeLength
        OutNodeAngle
        OutNodeZone
        OutNodeLayer
        OutNodeIndeLayer
        OutNodeSectionIsUsed
        OutNodeSectionIndex
        OutNodeSectionPriority
        
        noSection
        
        noEachSection
        noIndeEachSection
        
        layerZone
        indeLayerZone
    end
    
    methods
        function obj = Node(x,y,noSection)
            obj.noDirectNode = 0;
            obj.DirectNode = 0;
            obj.noOutNode = 0;
            obj.OutNode = 0;
            obj.x = x;
            obj.y = y;
            obj.noSection = noSection;
            obj.noEachSection = zeros(1,noSection);
            obj.noIndeEachSection = zeros(1,noSection);
            obj.layerZone=zeros(noSection,1);
            obj.indeLayerZone=zeros(noSection,1);
        end
        function obj = AddDirectNode(obj,index,x,y)
            isExist = 0;
            for i=1:obj.noDirectNode
                if obj.DirectNode(i)==index
                    isExist = 1;
                end
            end
            if isExist == 0
                now = obj.noDirectNode + 1;
                obj.noDirectNode = now;
                obj.DirectNode(now) = index;
                
                obj.DirectNodeLength(now) = norm([(obj.x-x) (obj.y-y)]);
                
                angle = getAngle([obj.x obj.y],[x y]);
                zone=ceil(angle*obj.noSection/360);
                obj.DirectNodeAngle(now) = angle;
                obj.DirectNodeZone(now) = zone;
                
                obj.noEachSection(zone) = obj.noEachSection(zone)+1;
                obj.layerZone(zone,obj.noEachSection(zone))=obj.DirectNodeLength(now);
            end 
        end
        function obj = AddOutNode(obj,index,x,y)
            isExist = 0;
            for i=1:obj.noOutNode
                if obj.OutNode(i)==index
                    isExist = 1;
                end
            end
            if isExist == 0
                for i=1:obj.noDirectNode
                    if obj.DirectNode(i)==index
                        isExist = 1;
                    end
                end
                if isExist == 0
                    now = obj.noOutNode + 1; 
                    obj.noOutNode = now;
                    obj.OutNode(now) = index;
                    
                    obj.OutNodeLength(now) = norm([(obj.x-x) (obj.y-y)]);
                    
                    angle = getAngle([obj.x obj.y],[x y]);
                    zone=ceil(angle*obj.noSection/360);
                    obj.OutNodeAngle(now) = angle;
                    obj.OutNodeZone(now) = zone;
                    
                    obj.noEachSection(zone) = obj.noEachSection(zone)+1; 
                    obj.layerZone(zone,obj.noEachSection(zone))=obj.OutNodeLength(now);
                    
                    obj.noIndeEachSection(zone) = obj.noIndeEachSection(zone)+1;
                    obj.indeLayerZone(zone,obj.noIndeEachSection(zone))=obj.OutNodeLength(now);
                end 
                

            end 
        end
        function obj = SpectDirectNode(obj,DirectNodeIndex,crossSectionIndex,crossSectionPriority)
            obj.DirectNodeSectionIndex(DirectNodeIndex) = crossSectionIndex;
            obj.DirectNodeSectionPriority(DirectNodeIndex) = crossSectionPriority;
        end
        function obj = SpectOutNode(obj,OutNodeIndex,crossSectionIndex,crossSectionPriority,isIndeUsed)
            obj.OutNodeSectionIndex(OutNodeIndex) = crossSectionIndex;
            obj.OutNodeSectionPriority(OutNodeIndex) = crossSectionPriority;
            obj.OutNodeSectionIsUsed(OutNodeIndex) = isIndeUsed; 
        end
        function output = isHave(self,index)
            output = 0;
            for i=1:self.noDirectNode
                if self.DirectNode(i)==index
                    output = 1;
                end
            end
        end
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