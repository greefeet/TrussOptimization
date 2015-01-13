function [stress, disX, disY] = OpenSeesRESULTS
%OpenSeesRESULTS Load Structural Analysis Results
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
        [stress,disX,disY] = OpenSeesRESULTS;
    end

    % Delay Temporary Fix Load Stress
    if ~isempty(strfind(str,'#')) || numel(disX)==0
        stress = [];
        disX = [];
        disY = [];
    end

end