function [ res ] = compute_residual( x, xhat,activeObs, simpar )
%compute_residual_example calculates the measurement residual
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
% [ output_args ] = compute_residual_example( input_args )
%
% See also FUNC1, FUNC2

% Author: Randy Christensen
% Date: 31-Aug-2020 16:01:24
% Reference: 
% Copyright 2020 Utah State University

ztilde = radec.synthesize_measurement(x,simpar);
zhattilde = radec.predict_measurement(x,xhat,simpar);

isActive = expandActiveObs(activeObs);

res = (ztilde-zhattilde).*isActive;

end
