function xdot = truthState_de( x, input)
%truthState_de computes the derivative of the truth state
%
% Inputs:
%   x = truth state (mixed units)
%   u = input (mixed units)
%
% Outputs
%   xdot = truth state derivative (mixed units)
%
% Example Usage
% xdot = truthState_de( x, input)

% Author: Randy Christensen
% Date: 21-May-2019 10:40:10
% Reference: none
% Copyright 2019 Utah State University

%% Unpack the inputs
simpar = input.simpar;
w = input.w;
%% Compute individual elements of x_dot
Na = simpar.general.n_assets;
% initialize xdot
xdot = zeros(7*Na+9,1);
% loop thru chaser assets
for ii=1:Na
    % update indexer for asset ii
    i = (ii - 1)*7;
    % position dot of asset i equals velocity of asset i
    xdot(i+1:i+3) = x(i+4:i+6);                                             % Eq 12
    % velocity dot of asset i equals gravitational point mass model
    xdot(i+4:i+6) = -simpar.Constants.muEarth / norm(x(i+1:i+3)) ^3 * x(i+1:i+3);       % Eq 13
    % b dot of asset i
    tau = 1000;  % set tau for clocking biases to 1000 seconds
    xdot(i+7) = -x(i+7) / tau + w(i+7);                                     % Eq 14
end
% update indexer for target
i = Na*7;
% position dot of target equals velocity of target
xdot(i+1:i+3) = x(i+4:i+6);                                                 % Eq 15
% velocity dot of the target equals gravity + atmo accel + noise
xdot(i+4:i+6) = -simpar.Constants.muEarth / norm(x(i+1:i+3)) ^3 * x(i+1:i+3) + x(i+7:i+9) + w(i+4:i+6);    % Eq 16
% a_atmo dot
tau = 500;  % set tau for a_atmo to 500 seconds
xdot(i+7:i+9) = -x(i+7:i+9)/tau + w(i+7:i+9);                               % Eq 17
end