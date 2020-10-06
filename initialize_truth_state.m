function [ x ] = initialize_truth_state(simpar)
%initialize_truth_state initialize the truth state vector consistent with
%the initial covariance matrix
%
% Inputs:
%   Input1 = description (units)
%   Input2 = description (units)
%
% Outputs
%   Output1 = description (units)
%   Output2 = description (units)
%
% Example Usage
% [ output_args ] = initialize_truth_state( input_args )

% Author: 
% Date: 31-Aug-2020 15:46:59
% Reference: 
% Copyright 2020 Utah State University

% In the initialization of the truth and navigation states, you need only
% ensure that the estimation error is consistent with the initial
% covariance matrix.  One realistic way to do this is to set the true 
% vehicle states to the same thing every time, and randomize any sensor 
% parameters.
n_assets = simpar.general.n_assets;
x = zeros(12+7*n_assets,1);
if n_assets >= 1
    x(1)  = simpar.general.ic.p1x;
    x(2)  = simpar.general.ic.p1y;
    x(3)  = simpar.general.ic.p1z;
    x(4)  = simpar.general.ic.v1x;
    x(5)  = simpar.general.ic.v1y;
    x(6)  = simpar.general.ic.v1z;
    x(7)  = simpar.general.ic.b1;
end
if n_assets >= 2
    x(8)  = simpar.general.ic.p2x;
    x(9)  = simpar.general.ic.p2y;
    x(10) = simpar.general.ic.p2z;
    x(11) = simpar.general.ic.v2x;
    x(12) = simpar.general.ic.v2y;
    x(13) = simpar.general.ic.v2z;
    x(14) = simpar.general.ic.b2;
end
if n_assets >= 3
    x(15) = simpar.general.ic.p3x;
    x(16) = simpar.general.ic.p3y;
    x(17) = simpar.general.ic.p3z;
    x(18) = simpar.general.ic.v3x;
    x(19) = simpar.general.ic.v3y;
    x(20) = simpar.general.ic.v3z;
    x(21) = simpar.general.ic.b3;
end
if n_assets >= 4
    x(22) = simpar.general.ic.p4x;
    x(23) = simpar.general.ic.p4y;
    x(24) = simpar.general.ic.p4z;
    x(25) = simpar.general.ic.v4x;
    x(26) = simpar.general.ic.v4y;
    x(27) = simpar.general.ic.v4z;
    x(28) = simpar.general.ic.b4;
end
if n_assets >= 5
    x(29) = simpar.general.ic.p5x;
    x(30) = simpar.general.ic.p5y;
    x(31) = simpar.general.ic.p5z;
    x(32) = simpar.general.ic.v5x;
    x(33) = simpar.general.ic.v5y;
    x(34) = simpar.general.ic.v5z;
    x(35) = simpar.general.ic.b5;
end
if n_assets >= 6
    x(36) = simpar.general.ic.p6x;
    x(37) = simpar.general.ic.p6y;
    x(38) = simpar.general.ic.p6z;
    x(39) = simpar.general.ic.v6x;
    x(40) = simpar.general.ic.v6y;
    x(41) = simpar.general.ic.v6z;
    x(42) = simpar.general.ic.b6;
end
if n_assets >= 7
    x(43) = simpar.general.ic.p7x;
    x(44) = simpar.general.ic.p7y;
    x(45) = simpar.general.ic.p7z;
    x(46) = simpar.general.ic.v7x;
    x(47) = simpar.general.ic.v7y;
    x(48) = simpar.general.ic.v7z;
    x(49) = simpar.general.ic.b7;
end

i = n_assets*7;

x(i+1)  = simpar.general.ic.ptx;
x(i+2)  = simpar.general.ic.pty;
x(i+3)  = simpar.general.ic.ptz;
x(i+4)  = simpar.general.ic.vtx;
x(i+5)  = simpar.general.ic.vty;
x(i+6)  = simpar.general.ic.vtz;
x(i+7)  = simpar.general.ic.egx;
x(i+8)  = simpar.general.ic.egy;
x(i+9)  = simpar.general.ic.egz;
x(i+10) = simpar.general.ic.ax;
x(i+11) = simpar.general.ic.ay;
x(i+12) = simpar.general.ic.az;

end
