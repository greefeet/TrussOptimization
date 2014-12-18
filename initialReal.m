function [pop0,f0] = initialReal(fun,nsol,a,b)
%Randomly initiate the population, design variable, Real-Number
% nsol is a number of individuals
% a     is lower limit
% b     is upper limit
nvar = length(a);       % no. of variables
pop = rand(nvar,nsol);
f0=zeros(nsol,1);
pop00=zeros(nvar,nsol);
for i=1:nsol
    for j=1:nvar
        pop00(j,i) = a(j)+(b(j)-a(j))*pop(j,i);
    end
    f0(i)=feval(fun,pop00(:,i));
    fprintf('|');
    pop0=pop00;
end
f0=f0';
global dis_initial;
if dis_initial==true
    fprintf('[InitialPopulation]\n');
    for i=1:nsol
        fprintf('  %3d - %d\n',i,f0(i));
    end
end

fprintf('    initialReal\n');
end