function GA( func,a,b,nloop,nsol)
fprintf('Method  : Genetic Algorithms (GA)\n');

% Optimizer's Parameters
nvar=length(a);     % no. design variables
nbit=10;            % no. of binary bit for one design variable
pc=1.0;             % probability of crossover
pm=0.2;             % mutation probability
pt=0.05;            % translation probability

% Collecing
Method.name='Genetic Algorithms (GA)';
Method.NoSolver=nsol;
Method.nvar=nvar;
Method.nbit=nbit;
Method.pc=pc;
Method.pm=pm;
Method.pt=pt;

tic
[pop0,~,f0] = initialBinary(func,nvar,nbit,nsol,a,b);
displayEstimate(toc,nloop,1,0);

statistic.stat=[];
statistic.hisFitness=[];
statistic.hisPenal=[];
statistic.hisPureFitness=[];

for iter=1:nloop
    tic
    pop1=ga_select(pop0,f0);                %selection
    pop2=ga_crossover(pop1,nvar,nbit,pc);   %crossover
    pop3=ga_mutate(pop2,pm);                %mutation
    [pop4,f4]=ga_translate(func,pop3,nvar,nbit,a,b,pt);%translation
    [pop5,f5]=ga_elite(pop0,pop4,f0,f4);    %keep elite and the next generation
    pop0=pop5;f0=f5;

    % Display and Save
    x0 = bin2real(pop0,a,b);
    [bestfit,nmin]=min(f0);

    % Display Statistic
    [statistic]=collectStatistic(func,Method,f0,x0(:,nmin),statistic,iter);

    % Post Process
    feval(strcat(func,'run'),iter,x0(:,nmin),Method,statistic);

    fprintf('  %3d-Best is %d ',iter,bestfit);
    displayEstimate(toc,nloop,2,iter);
    pause(0.0001);
end
end

function bin1 = ga_select(bin2,ff)
%
% Selection procedure of GA
%
[m,n]=size(bin2);
% [ff1,n1]=sort(-ff);
% bin2=bin2(:,n1);
[ff1,n1]=sort(-ff);
w0(n1)=1:n;
[ff;w0]';
w0=w0';
w1=w0/sum(w0);
w=cumsum(w1);
% figure(1),clf,pie(w1)
for i=1:n
    prob=rand;
    if prob <= w(1)
        bin1(:,i)=bin2(:,1);
    else
        ii=1;
        while prob > w(ii)|ii < n
            if prob > w(ii)&prob <= w(ii+1)
                bin1(:,i)=bin2(:,ii+1);
            end
            ii=ii+1;
        end
    end
end
end
function bin1=ga_crossover(bin2,nv,nc,pc)
%
% GA crossover operator
% with pc = 0.9
%
[m,n]=size(bin2);
bin1=bin2;
for i=1:2:n-1
    if rand <= pc% crossover prob.
        for j=1:nv
            st=(j-1)*nc+1;en=j*nc;
            slect1=ceil(rand*nc)-1;
            st2=st+slect1;en2=st2+ceil(rand*(en-st2));
            bin1(st2:en2,i)=bin2(st2:en2,i+1);
            bin1(st2:en2,i+1)=bin2(st2:en2,i);
        end
    end
end
end
function bin1 = ga_mutate(bin2,pm)
%
% Mutation operator for simple GA
%
[m,n]=size(bin2);
bin1=bin2;
for i=1:n
    if rand < pm%mutation prob.
        select=ceil(rand*m);
        bin1(select,i)=~bin2(select,i);
    end
end
end
function [bin1,f]=ga_translate(fun,bin2,nv,nc,a,b,pt)
%
% GA Translation operator&new blood
%
[m,n]=size(bin2);
newblood=round(rand(m,1));
nperm = randperm(n);
bin1=[newblood bin2(:,nperm(2:n))];
for i=1:n
    if i > 1
        if rand < pt%translation prob.
            cut=ceil(rand*m);
            bin1(:,i) = [bin2(cut+1:m,i);bin2(1:cut,i)];
        end
    end
    for j=1:nv
        x(j,i)=bin2dec(bin1((j-1)*nc+1:j*nc,i),a(j),b(j));
    end
    f(i)=feval(fun,x(:,i));
%     clc
    fprintf('~%.2f',i/n*100);
end
end
function [x,f]=ga_elite(x1,x2,f1,f2)
%
% GA Elite strategy
% keep 1 elite from the old generation and another from the
% new generation
[m,n]=size(x1);
nperm1=randperm(n);
nperm2=randperm(n);
nn1=ceil((n-2)/2);nn2=n-nn1-2;
[fmin1,n1]=min(f1);
xmin1=x1(:,n1);
[fmin2,n2]=min(f2);
xmin2=x2(:,n2);
x=[xmin1 x1(:,nperm1(1:nn1)) xmin2 x2(:,nperm2(1:nn2))];
f=[fmin1 f1(:,nperm1(1:nn1)) fmin2 f2(:,nperm2(1:nn2))];
end
function x=bin2dec(bin,a,b)
%
% Transformation from binary string to real number
% with lowr limit a and upper limit b
n=max(size(bin));
trans=cumprod(2*ones(size(bin)))/2;
real1=sum(bin.*trans);
x=a+(real1*(b-a))/(2^n-1);
end
function x=bin2real(bin,a,b)
[m,n]=size(bin);
nvar=length(a);
nbit=m/nvar;

for i=1:n
    for j=1:nvar
        x(j,i)=bin2dec(bin((j-1)*nbit+1:j*nbit,i),a(j),b(j));
	end
end
end
