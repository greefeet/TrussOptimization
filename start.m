function start
%START Start Truss Optimization Framework

%Settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prob = 'BKI';
method = 'GA';
nloop = 300;
nsol = 500;

%Start %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('[Problem] %s\n',prob);
fprintf('[Method] %s\n',method);
fprintf('[NOF.PopulationSize] %d\n',nsol);
fprintf('[NOF.Generations] %d\n',nloop);
fprintf('[ResultFolder] %s\n',resultFolder(prob,method));
[func] = feval(strcat(prob));           % Load Problem
[a,b]=feval(strcat(func,'encode'));     % Set Upper and Lower Limit
feval(method,func,a,b,nloop,nsol);      % Start Optimization

end

function output=resultFolder(prob,method)
global save_folder;
CN=getenv('COMPUTERNAME');  r=clock;
DT=sprintf('%d.%d.%d %02d.%02d.%02.0f',r(3),r(2),r(1),r(4),r(5),r(6));
save_folder = sprintf('%s - %s - %s - %s',CN,DT,prob,method);
mkdir(save_folder); output = save_folder;
end