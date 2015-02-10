function [result, scale,allowable]=BKIIcons(type,dat1,dat2,dat3)
global PRB; mp = PRB.mp;
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
        % dat3 is CrossSection Area
        if dat1 < 0
            % Compression
            a=4;    %Buckling coefficent 
            maxCompressive=a*mp.elastic*dat3/dat2/dat2;
            if maxCompressive < mp.fy
                maxCompressive = mp.fy;
            end
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
        scale=1;
        allowable=1;
end
end