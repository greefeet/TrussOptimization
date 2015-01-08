function [result, scale,allowable]=ProbCaseIIcons(type,dat1,~,~)
global PRB; dv = PRB.dv;    mp = PRB.mp;
result=0; scale=0; allowable=0;
switch type
    case TypeCons.Length
        % Member Length
        % dat1 is member's length
        scale=1;
        allowable=1;
    case TypeCons.Stress
        % Member Stress
        % dat1 is stress
        % dat2 is length
        % dat3 is radius of gyration
        if dat1 < 0
            % Compression
            maxCompressive=mp.fy;
            if dat1*-1>maxCompressive
                result=1;
            end
            scale=dat1*-1/maxCompressive;
            allowable=-1*maxCompressive;
        else
            % Tensile
            maxTensile=mp.fy;
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
        scale=1;
        allowable=1;
    case TypeCons.Displacement
        % Node Displacement
        % dat1 is displacement
        displacementAllowable=2;    %2 in
        if  abs(dat1) - displacementAllowable > 0.00001
            result=1;
        end
        scale=abs(dat1)/displacementAllowable;
        allowable=displacementAllowable;
end
end