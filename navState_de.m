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

% Author: Randy Christensen
% Date: 21-May-2019 10:40:10
% Reference: none
% Copyright 2019 Utah State University

% Unpack the inputs
simpar = input.simpar;
%% Compute individual elements of x_dot
% initialize xhatdot
xhatdot = zeros(9,1);
% position dot of target equals velocity of target
xhatdot(1:3) = xhat(4:6);                                                   % Eq 18
% calculate the position mag
pmag = norm( xhat(1:3) );   %sqrt( xhat(1)^2 + xhat(2)^2 + xhat(3)^2 );
% velocity dot of the target equals gravity + atmo accel
xhatdot(4:6) = -simpar.Constants.muEarth / norm(xhat(1:3)) ^3 * xhat(1:3) + xhat(7:9);      % Eq 19
% a_atmo dot
tau = 500;  % set tau for a_atmo to 500 seconds
xhatdot(7:9) = -xhat(7:9)/tau;                                              % Eq 20
end
