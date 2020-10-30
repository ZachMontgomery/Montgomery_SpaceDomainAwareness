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

% initialize dele vector
dele = zeros(simpar.general.n_design,1);
% loop thru chaser assets
for i=1:simpar.general.n_assets
    % store the error injection for the clocing bias of asset i
    dele(i) = simpar.errorInjection.(['b',int2str(i)]);
end
% setup axis array to loop thru axes
axis = {'x','y','z'};
% loop thru axes
for i=1:3
    % set the target position error injection for axis i
    dele(simpar.general.n_assets+i)   = simpar.errorInjection.(['pt',axis{i}]);
    % set the target velocity error injection for axis i
    dele(simpar.general.n_assets+i+3) = simpar.errorInjection.(['vt',axis{i}]);
    % set the atmo acceler error injection for axis i
    dele(simpar.general.n_assets+i+6) = simpar.errorInjection.(['a',axis{i}]);
end



xhat_errorInject = injectErrors(truth2nav(x, simpar), dele, simpar);
estimationErrors = calcErrors(xhat_errorInject, x, simpar);
assert(norm(estimationErrors - dele) < 1e-11);

x_errorCorrect = correctErrors(xhat_errorInject, dele, simpar);
assert(norm(xhat - x_errorCorrect) < 1e-12);

% store initialized vectors for latex table
% simpar.table.true = x;
% simpar.table.design = xhat;
% simpar.table.error = dele;
% simpar.table.estimate = xhat_errorInject;
% simpar.table.estError = estimationErrors;
% simpar.table.design_errorCorrected = x_errorCorrect;
% 
% simpar.table
end
