function result=verifyopensees
%VERIFYOPENSEES    Verify Connection between MATLAB and OpenSees
fprintf('[VerifyOpenSees] \n');
result=1;

% Create TestFile
fileID=fopen('vOpenSees.tcl','w');
fprintf(fileID,'model BasicBuilder -ndm 2 -ndf 2\n');
fprintf(fileID,'node 1 0.0 0.0\n');
fprintf(fileID,'node 2 144.0 0.0\n');
fprintf(fileID,'node 3 168.0 0.0\n');
fprintf(fileID,'node 4 72.0 96.0\n');
fprintf(fileID,'fix 1 1 1\n');
fprintf(fileID,'fix 2 1 1\n');
fprintf(fileID,'fix 3 1 1\n');
fprintf(fileID,'uniaxialMaterial Elastic 1 3000\n');
fprintf(fileID,'element truss 1 1 4 10.0 1\n');
fprintf(fileID,'element truss 2 2 4 5.0 1\n');
fprintf(fileID,'element truss 3 3 4 5.0 1\n');
fprintf(fileID,'pattern Plain 1 "Linear" {\n');
fprintf(fileID,'load 4 100 -50\n');
fprintf(fileID,'}\n');
fprintf(fileID,'system BandSPD\n');
fprintf(fileID,'numberer RCM\n');
fprintf(fileID,'constraints Plain\n');
fprintf(fileID,'integrator LoadControl 1.0\n');
fprintf(fileID,'algorithm Linear\n');
fprintf(fileID,'analysis Static\n');
fprintf(fileID,'recorder Node -file example.out -load -node 4 -dof 1 2 disp\n');
fprintf(fileID,'analyze 1\n');
fprintf(fileID,'print node 4\n');
fprintf(fileID,'print ele\n');
fclose(fileID);

% MATLAB Execute OpenSees
[fed,sout]=system('OpenSees.exe vOpenSees.tcl');

% CheckResults
if fed==0
    if isempty(strfind(sout,'OpenSees'))
        fprintf('   Error... Matlab connection fail with OpenSees (reinstall TCL)\n');
        result=0;
    else
        if isempty(strfind(sout,'analyze failed'))
            fprintf('   Complete... Matlab conect OpenSees\n');
            % Load Stress
            fid = fopen('example.out');
            displacement = fscanf(fid, '%f ');
            str=fscanf(fid,'%s');
            if ~isempty(strfind(str,'#'))
                stress=[];
            end
            fclose(fid);
            if ~isempty(displacement)
                fprintf('   Complete... Read results\n');
            else
                fprintf('   Error... Read results fail\n');
                result=0;
            end
        else
            fprintf('   Error... Analysis failed\n');
            result=0;
        end
    end
else
    fprintf('   Error... Miss OpenSees.exe (Reinstall OpenSees)\n');
    result=0;
end

% Delete TestFile
delete('vOpenSees.tcl');

end