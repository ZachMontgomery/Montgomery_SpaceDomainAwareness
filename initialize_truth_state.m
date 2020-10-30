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
    x(Na*simpar.general.n_chaser+i) = simpar.general.ic.(['b',int2str(i)]);
end



% if Na >= 1
%     x(1)  = simpar.general.ic.p1x;
%     x(2)  = simpar.general.ic.p1y;
%     x(3)  = simpar.general.ic.p1z;
%     x(4)  = simpar.general.ic.v1x;
%     x(5)  = simpar.general.ic.v1y;
%     x(6)  = simpar.general.ic.v1z;
% end
% if Na >= 2
%     x(8)  = simpar.general.ic.p2x;
%     x(9)  = simpar.general.ic.p2y;
%     x(10) = simpar.general.ic.p2z;
%     x(11) = simpar.general.ic.v2x;
%     x(12) = simpar.general.ic.v2y;
%     x(13) = simpar.general.ic.v2z;
% end
% if Na >= 3
%     x(15) = simpar.general.ic.p3x;
%     x(16) = simpar.general.ic.p3y;
%     x(17) = simpar.general.ic.p3z;
%     x(18) = simpar.general.ic.v3x;
%     x(19) = simpar.general.ic.v3y;
%     x(20) = simpar.general.ic.v3z;
% end
% if Na >= 4
%     x(22) = simpar.general.ic.p4x;
%     x(23) = simpar.general.ic.p4y;
%     x(24) = simpar.general.ic.p4z;
%     x(25) = simpar.general.ic.v4x;
%     x(26) = simpar.general.ic.v4y;
%     x(27) = simpar.general.ic.v4z;
% end
% if Na >= 5
%     x(29) = simpar.general.ic.p5x;
%     x(30) = simpar.general.ic.p5y;
%     x(31) = simpar.general.ic.p5z;
%     x(32) = simpar.general.ic.v5x;
%     x(33) = simpar.general.ic.v5y;
%     x(34) = simpar.general.ic.v5z;
% end
% if Na >= 6
%     x(36) = simpar.general.ic.p6x;
%     x(37) = simpar.general.ic.p6y;
%     x(38) = simpar.general.ic.p6z;
%     x(39) = simpar.general.ic.v6x;
%     x(40) = simpar.general.ic.v6y;
%     x(41) = simpar.general.ic.v6z;
% end
% if Na >= 7
%     x(43) = simpar.general.ic.p7x;
%     x(44) = simpar.general.ic.p7y;
%     x(45) = simpar.general.ic.p7z;
%     x(46) = simpar.general.ic.v7x;
%     x(47) = simpar.general.ic.v7y;
%     x(48) = simpar.general.ic.v7z;
% end

% i = Na * 6;

% set the indexer
i = Na*7;
% loop thru axis
for j=1:3
    % set position initial condition for target at the jth axis
    x(i+j) = simpar.general.ic.(['pt',axis{j}]);
    % set velocity initial condition for target at the jth axis
    x(i+3+j) = simpar.general.ic.(['vt',axis{j}]);
    % set atmo accel initial condition at the jth axis
    x(i+6+j) = simpar.general.ic.(['a',axis{j}]);
end

% x(i+1)  = simpar.general.ic.ptx;
% x(i+2)  = simpar.general.ic.pty;
% x(i+3)  = simpar.general.ic.ptz;
% x(i+4)  = simpar.general.ic.vtx;
% x(i+5)  = simpar.general.ic.vty;
% x(i+6)  = simpar.general.ic.vtz;
% x(i+7) = simpar.general.ic.ax;
% x(i+8) = simpar.general.ic.ay;
% x(i+9) = simpar.general.ic.az;

end
