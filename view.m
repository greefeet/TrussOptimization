function view
%view
global fitnessLabel; global isSave;

% Load FROM workspace %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Method = evalin('base','Method');
Running = evalin('base','Running');
Solution = evalin('base','Solution');

% Initial
prob=Solution.prob;
func=Solution.func;
bestindi=Solution.indi;
gen=Running.gen;

feval(prob);                   % Load Problem
feval(strcat(func,'encode'));  % Set Upper and Lower Limit

fprintf('[Optimizer]\n');
Method
fprintf('[Generation] %d\n',gen);
f0=feval(func,bestindi);
fprintf('[Fitness] %d\n',f0);

% Draw Statistic %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cF=[47/255 51/255 59/255];
cW=[0/255 146/255 146/255];
cP=[255/255 54/255 0/255];
set(0,'CurrentFigure',1);
hold on
plot(1:gen,Running.stat(1:gen,1),'-o','LineWidth',1,'MarkerEdgeColor','black','MarkerFaceColor','black','MarkerSize',2,'Color','black');
plot(1:gen,Running.stat(1:gen,2),'-v','LineWidth',1,'MarkerEdgeColor',cP,'MarkerFaceColor',cP,'MarkerSize',3,'Color',cP);
plot(1:gen,Running.stat(1:gen,3),':x','LineWidth',1,'MarkerEdgeColor',cF,'MarkerFaceColor',cF,'MarkerSize',3,'Color',cF);
legend('Medain','Mode','Min');
xlabel('Generations Number');
ylabel(fitnessLabel);
title('Statistic of Population','FontWeight','bold')

% Draw History of Best Individual %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0,'CurrentFigure',2);
hold on
plot(1:gen,Running.hisFitness,'-o','LineWidth',1,'MarkerEdgeColor',cF,'MarkerFaceColor',cF,'MarkerSize',3,'Color',cF);
plot(1:gen,Running.hisPureFitness,'-v','LineWidth',1,'MarkerEdgeColor',cW,'MarkerFaceColor',cW,'MarkerSize',3,'Color',cW);
plot(1:gen,Running.hisPenal,'-x','LineWidth',1,'MarkerEdgeColor',cP,'MarkerFaceColor',cP,'MarkerSize',3,'Color',cP);
legend('Fitness','PureFitness','Penalty')
xlabel('Generation Number');
ylabel(fitnessLabel);
title('Best Individuals in each Generation','FontWeight','bold')

% Run %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
isSave=0;
feval(strcat(func,'run'),gen,bestindi,Method,Running);
isSave=1;
% Verify %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
feval(strcat(func,'verify'),bestindi);
end