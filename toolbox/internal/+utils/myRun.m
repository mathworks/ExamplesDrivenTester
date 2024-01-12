function myRun(script)
% Function will be used as encapsulation to run MATLAB script. Many of the
% scripts have "clear" statement at the bgining. This wrapper makes sure
% that it does not break the infrastructure.

run(script);
end