function [bin,x,f] = initialBinary(fun,nvar,nbit,nsol,a,b)
%Randomly initiate the population, design variables
% nvar=no. of variables
% nbit is the number of cell in each variable
% nsol is a number of gene
rng('shuffle');
bin = round(rand(nvar*nbit,nsol));
f = zeros(1,nsol);
x = zeros(nvar,nsol);
for i=1:nsol
    for j=1:nvar
        binn=bin((j-1)*nbit+1:j*nbit,i);
        x(j,i)=bin2dec(binn,a(j),b(j));
    end
    f(i)=feval(fun,x(:,i));
    fprintf('[InitialBinary] %d/%d\n',i,nsol);
end
end
function x=bin2dec(bin,a,b)
% Transformation from binary string to real number
% with lowr limit a and upper limit b
n=max(size(bin));
trans=cumprod(2*ones(size(bin)))/2;
real1=sum(bin.*trans);
x=a+(real1*(b-a))/(2^n-1);
end