function [ xhat ] = truth2nav( x, simparam )
%truth2nav maps the truth state vector to the navigation state vector
%
% Inputs:
%   x = truth state (mixed units)
%
% Outputs
%   xhat = navigation state (mixed units)
%
% Example Usage
% [ xhat ] = truth2nav( x )

% Author: Randy Christensen
% Date: 21-May-2019 14:17:45
% Reference: 
% Copyright 2019 Utah State University
A = [zeros(9,7*simparam.general.n_assets) eye(9)];
xhat = A * x;
end
