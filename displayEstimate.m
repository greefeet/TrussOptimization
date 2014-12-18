function displayEstimate(t,nloop,state,iter)
switch state
    case 1
        fprintf('Estimate time : %.0f sec\n',t);
        fprintf('Total Time    : ');
        disp(datestr(datenum(0,0,0,0,0,round(t)*nloop),'HH:MM:SS'))
        fprintf('Complete at %s\n', datestr(addtodate(now,round(t)*nloop,'sec')));
    case 2
        fprintf('%2.2f%% (%s)\n',iter/nloop*100,datestr(addtodate(now,round(toc)*(nloop-iter),'sec')));
end

end