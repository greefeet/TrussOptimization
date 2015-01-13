function result = OpenSeesRUN(node,member)
%OpenSeesRUN Send node and member to Structural Analysis by OpenSees
%Structure Analysis by OpenSees
    global PRB;
    mp = PRB.mp;    %Material Properties
    bc = PRB.bc;    %Boundary Condition

    %Clear OutputFile
    [fid, mess] = fopen('File-OutStress.out', 'w');
    while fid<0
        fprintf('ERROR : %s\n',mess);
        [fid, mess] = fopen('File-OutStress.out', 'w');
    end
    fclose(fid);

    [fid, mess] = fopen('File-OutDisp.out', 'w');
    while fid<0
        fprintf('ERROR : %s\n',mess);
        [fid, mess] = fopen('File-OutDisp.out', 'w');
    end
    fclose(fid);

    %Write InputFile
    %initial data
    fileID = fopen('File-Input.tcl','w');
    fprintf(fileID,'wipe\n'); 
    fprintf(fileID,'model BasicBuilder -ndm 2 -ndf 2\n');

    %loop node
    numberNode=length(node(:,1));
    for i=1:numberNode
        fprintf(fileID,'node %d %.4f %.4f\n',i,node(i,1),node(i,2));
    end

    %loop support
    for i=1:length(bc.fix(:,1))
        fprintf(fileID,'fix %d %d %d\n',bc.fix(i,1),bc.fix(i,2),bc.fix(i,3));
    end

    %loop element
    fprintf(fileID,'uniaxialMaterial Elastic 1 %d\n',mp.elastic); %E=201 GPa
    numberMember=length(member(:,1));
    for i=1:numberMember
        fprintf(fileID,'element truss %d %d %d %.4f 1\n',i,member(i,1),member(i,2),member(i,3));
    end

    %load
    fprintf(fileID,'pattern Plain 1 "Linear" {\n');

    %loop Load
    numberLoad=length(bc.load(:,1));
    for i=1:numberLoad
        fprintf(fileID,'load %d %d %d\n',bc.load(i,1),bc.load(i,2),bc.load(i,3));
    end
    fprintf(fileID,'}\n');

    %final data
    fprintf(fileID,'system BandSPD\n');
    fprintf(fileID,'numberer RCM\n');
    fprintf(fileID,'constraints Plain\n');
    fprintf(fileID,'integrator LoadControl 1.0\n');
    fprintf(fileID,'algorithm Linear\n');
    fprintf(fileID,'analysis Static\n');
    fprintf(fileID,'recorder Node -file File-OutDisp.out -node ');
    fprintf(fileID,'%d ',1:numberNode);
    fprintf(fileID,'-dof 1 2 disp\n');
    fprintf(fileID,'recorder Element -file File-OutStress.out -ele ');
    fprintf(fileID,'%d ',1:numberMember);
    fprintf(fileID,'material stress\n');
    fprintf(fileID,'analyze 1\n');
    fprintf(fileID,'quit\n');
    fclose(fileID);

    %run OpenSees
    [~,sout]=system('OpenSeesHelper.exe File-Input.tcl');
    
    if isempty(strfind(sout,'analyze failed'))
        result = true;
    else
        result = false;
    end
end