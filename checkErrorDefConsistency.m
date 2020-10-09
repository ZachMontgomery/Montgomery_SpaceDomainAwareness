function checkErrorDefConsistency( xhat, x, simpar )
%checkErrorDefConsistency checks consistency of the error injection,
%calcuation, and correction functions.
%
% Inputs:
%   simpar = description (units)
%   x = description (units)
%
% Example Usage
% checkErrorDefConsistency( simpar, x )
%

% Author: Randy Christensen
% Date: 25-Jan-2019 12:02:28
% Reference:
% Copyright 2018 Utah State University
fnames = fieldnames(simpar.errorInjection);
dele = zeros(length(fnames),1);
for i=1:length(fnames)
    dele(i) = simpar.errorInjection.(fnames{i});
end
xhat_errorInject = injectErrors(truth2nav(x, simpar), dele, simpar);
estimationErrors = calcErrors(xhat_errorInject, x, simpar);
assert(norm(estimationErrors - dele) < 1e-11);
x_errorCorrect = correctErrors(xhat_errorInject, dele, simpar);
assert(norm(xhat - x_errorCorrect) < 1e-12);

% store initialized vectors for latex table
simpar.table.true = x;
simpar.table.design = xhat;
simpar.table.error = dele;
simpar.table.estimate = xhat_errorInject;
simpar.table.estError = estimationErrors;
simpar.table.design_errorCorrected = x_errorCorrect;


end
