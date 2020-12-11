function [ xhat ] = initialize_nav_state( x, simpar)
%initialize_nav_state initializes the navigation state vector consistent
%with the initial covariance matrix

% Consistent with the truth state initialization, you should randomize the
% vehicle states, and initialize any sensor parameters to zero.  An example
% of these calculations are shown below.

% [L_posvelatt,p] = chol(P(simpar.states.ixfe.vehicle,...
%     simpar.states.ixfe.vehicle,1),'lower');
% assert(p == 0, 'Phat_0 is not positive definite');
% delx_0 = zeros(simpar.states.nxfe,1);
% delx_0(simpar.states.ixfe.vehicle,1) = L_posvelatt * ...
%     randn(length(simpar.states.ixfe.vehicle),1);
% xhat = injectErrors(truth2nav(x),delx_0, simpar);
% xhat(simpar.states.ixf.parameter,1) = 0;


Na = simpar.general.n_assets;

% initialize error vector to zeros
delx = zeros(simpar.general.n_design,1);

if simpar.general.process_noise_enable

    % biases were randomized in the truth state, so they need to be left to
    % zero here

    % loop thru axis
    axis = {'x', 'y', 'z'};
    for i=1:3
        % set position error
        delx(Na+i)   = simpar.nav.ic.(['sig_p',axis{i}]) * randn;
        % set velocity error
        delx(Na+3+i) = simpar.nav.ic.(['sig_v',axis{i}]) * randn;
        % atmo accelerations errors were set in the truth state
    end
end

% inject the errors to create xhat
xhat = injectErrors(truth2nav(x, simpar), delx, simpar);

% since the biases and atmo accelerations were set in the truth state, the
% xhat must be set to zero for these states, otherwise these states always
% start with 0 estimated error
if simpar.general.process_noise_enable
    xhat(1:Na) = 0.;
    xhat(Na+6+1:end) = 0.;
end

% xhat = truth2nav(x, simparams);


end
