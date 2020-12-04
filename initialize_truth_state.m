function [ x ] = initialize_truth_state(simpar)
%initialize_truth_state initialize the truth state vector consistent with
%the initial covariance matrix

% In the initialization of the truth and navigation states, you need only
% ensure that the estimation error is consistent with the initial
% covariance matrix.  One realistic way to do this is to set the true 
% vehicle states to the same thing every time, and randomize any sensor 
% parameters.

% determine the number of assets
Na = simpar.general.n_assets;
% initialize the truth state vector
x = zeros(simpar.general.n_design+simpar.general.n_chaser*Na,1);
% initialize a cell array with xyz
axis = {'x','y','z'};
% loop thru the chaser assets
for i=1:Na
    % loop thru the axes
    for j=1:3
        % set position initial condition for the ith asset and jth axis
        x((i-1)*simpar.general.n_chaser+j) = simpar.general.ic.(['p',int2str(i),axis{j}]);
        % set velocity initial condition for the ith asset and jth axis
        x((i-1)*simpar.general.n_chaser+3+j) = simpar.general.ic.(['v',int2str(i),axis{j}]);
    end
    % set bias initial condition for the ith asset
    x(Na*simpar.general.n_chaser+i) = simpar.truth.ic.(['sig_b',int2str(i)]) * randn;
end

% set the indexer
i = Na*simpar.general.n_chaser + Na;
% loop thru axis
for j=1:3
    % set position initial condition for target at the jth axis
    x(i+j) = simpar.general.ic.(['pt',axis{j}]);
    % set velocity initial condition for target at the jth axis
    x(i+3+j) = simpar.general.ic.(['vt',axis{j}]);
    % set atmo accel initial condition at the jth axis
    x(i+6+j) = simpar.truth.ic.(['sig_a',axis{j}]) * randn;
end


end
