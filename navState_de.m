function xhatdot = navState_de(xhat,input)
%navState_de computes the derivative of the nav state
%
% Inputs:
%   xhat = nav state (mixed units)
%   input = input (mixed units)
%
% Outputs
%   xhatdot = nav state derivative (mixed units)
%
% Example Usage
% xhatdot = navState_de(xhat,input)


% Unpack the inputs
simpar = input.simpar;
% number of assets
Na = simpar.general.n_assets;
% set tau for biases
tau = 1000;
%% Compute individual elements of x_dot
% initialize xhatdot
xhatdot = zeros(simpar.general.n_design,1);
% loop thru assets
for i=1:Na
    % bias dot of asset $i$
    xhatdot(i) = -xhat(i) / tau;                                            % Eq 18
end
% position dot of target equals velocity of target
xhatdot(Na+1:Na+3) = xhat(Na+4:Na+6);                                       % Eq 19
% velocity dot of the target equals gravity + atmo accel
xhatdot(Na+4:Na+6) = -simpar.Constants.muEarth ...
    / norm(xhat(Na+1:Na+3))^3 * xhat(Na+1:Na+3) + xhat(Na+7:Na+9);          % Eq 20
% a_atmo dot
tau = 500;  % set tau for a_atmo to 500 seconds
xhatdot(Na+7:Na+9) = -xhat(Na+7:Na+9)/tau;                                  % Eq 21
end
