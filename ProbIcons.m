function [result, scale,allowable]=ProbIcons(type,dat1,dat2,dat3)
global PRB; dv = PRB.dv;    mp = PRB.mp;
result=0; scale=0; allowable=0;
switch type
    case TypeCons.Length        
        % Member Length
        % dat1 is member's length
        if dat1<dv.lengthMax
            if dat1>dv.lengthMin
                % It's Ok
                scale=1;
            else
                % Too Short
                result=1;
                scale=2-dat1/dv.lengthMin;
            end
        else
            % Too Long
            result=1;
            scale=dat1/dv.lengthMax;
        end
    case TypeCons.Stress       
        % Member Stress
        % dat1 is stress
        % dat2 is length
        % dat3 is radius of gyration
        if dat1 < 0
            % Compression
            c=pi*sqrt(2*mp.elastic/mp.fy);
            lamda=dat2/dat3;
            if lamda>c
                maxCompressive=12*pi^2*mp.elastic/23/lamda^2;
            else
                maxCompressive=(1-lamda^2/2/c^2)*mp.fy/(5/3+3*lamda/8/c-lamda^3/8/c^3);
            end
            if dat1*-1>maxCompressive
                result=1;
            end
            scale=dat1*-1/maxCompressive;
            allowable=-1*maxCompressive;
        else
            % Tensile
            maxTensile=mp.fy*0.6;
            if dat1>maxTensile
                result=1;
            end
            scale=dat1/maxTensile;
            allowable=maxTensile;
        end
    case TypeCons.Slender        
        % Member Slender
        % dat1 is stress
        % dat2 is length
        % dat3 is radius of gyration
        slendernessRatio=dat2/dat3;
        if dat1<0
            if abs(dat1)>0.00001
                % Compression
                maxRatio=200;
            else
                % Tensile
                maxRatio=240;
            end
        else
            % Tensile
            maxRatio=240;
        end
        if slendernessRatio>maxRatio
            result=1;
        end
        scale=slendernessRatio/maxRatio;
        allowable=maxRatio;
    case TypeCons.Displacement        
        % Node Displacement
        % dat1 is displacement
        displacementAllowable=7;
        if  abs(dat1) - displacementAllowable > 0.00001
            result=1;
        end
        scale=abs(dat1)/displacementAllowable;
        allowable=displacementAllowable;
end
end