function [statistic]=collectStatistic(func,Method,f0,bestindi,statistic,gen)
global save_folder;   global PRB;
fitnessLabel = PRB.info.Label;
sMedian=median(f0); sMode=mode(f0); sMin=min(f0);
statistic.stat=[statistic.stat;sMedian sMode  sMin];

[tfitness tpenal tpurefitness]=feval(func,bestindi);
statistic.hisFitness=[statistic.hisFitness; tfitness];
statistic.hisPenal=[statistic.hisPenal; tpenal];
statistic.hisPureFitness=[statistic.hisPureFitness; tpurefitness];

cF=[47/255 51/255 59/255];
cW=[0/255 146/255 146/255];
cP=[255/255 54/255 0/255];

% Draw Statistic
set(0,'CurrentFigure',1);
hold on
plot(1:gen,statistic.stat(1:gen,1),'-o','LineWidth',1,'MarkerEdgeColor','black','MarkerFaceColor','black','MarkerSize',2,'Color','black');
plot(1:gen,statistic.stat(1:gen,2),'-v','LineWidth',1,'MarkerEdgeColor',cP,'MarkerFaceColor',cP,'MarkerSize',3,'Color',cP);
plot(1:gen,statistic.stat(1:gen,3),':x','LineWidth',1,'MarkerEdgeColor',cF,'MarkerFaceColor',cF,'MarkerSize',3,'Color',cF);
legend('Medain','Mode','Min');
xlabel('Generations Number');
ylabel(fitnessLabel);
title('Statistic of Population','FontWeight','bold')

% Draw History of Best Individual
set(0,'CurrentFigure',2);
hold on
plot(1:gen,statistic.hisFitness,'-o','LineWidth',1,'MarkerEdgeColor',cF,'MarkerFaceColor',cF,'MarkerSize',3,'Color',cF);
plot(1:gen,statistic.hisPureFitness,'-v','LineWidth',1,'MarkerEdgeColor',cW,'MarkerFaceColor',cW,'MarkerSize',3,'Color',cW);
plot(1:gen,statistic.hisPenal,'-x','LineWidth',1,'MarkerEdgeColor',cP,'MarkerFaceColor',cP,'MarkerSize',3,'Color',cP);
legend('Fitness','PureFitness','Penalty')
xlabel('Generation Number');
ylabel(fitnessLabel);
title('Best Individuals in each Generation','FontWeight','bold')

% Save Figure
fullFileName=fullfile(cd,save_folder,'StatisticHistory.png');
saveas(1,fullFileName, 'png')
fullFileName=fullfile(cd,save_folder,'BestFitnessHistory.png');
saveas(2,fullFileName, 'png')

%Save Data
Solution.func=func;
Solution.prob=PRB.info.prob;
Solution.indi=bestindi;
Running.gen=gen;
Running.stat=statistic.stat;
Running.hisFitness=statistic.hisFitness;
Running.hisPureFitness=statistic.hisPureFitness;
Running.hisPenal=statistic.hisPenal;
assignin('base','Solution',Solution);
assignin('base','Method',Method);
assignin('base','Running',Running);
name=sprintf('gen-%3.0f.mat',gen);
fullFileName=fullfile(cd,save_folder,name);
save(fullFileName,'Solution','Method','Running');
end
