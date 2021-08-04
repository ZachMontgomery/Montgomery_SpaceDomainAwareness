function [ H ] = compute_H( x,xhat,simpar )
%compute_H_example calculates the measurement sensitivity matrix
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
% [ output_args ] = compute_H_example( input_args )
%
% See also FUNC1, FUNC2

% Author: Randy Christensen
% Date: 31-Aug-2020 16:04:33
% Reference: 
% Copyright 2020 Utah State University

% Parameter
posRSO  = simpar.states.ixf.posRSO; %indices for rRSO
posObs  = simpar.states.ix.posObs;  %indices for rObs
bias    = simpar.states.ixf.bias;   %indices for b
nObs    = simpar.states.nObs;       %number of observers

%Get the states needed
rhatRSO = xhat(posRSO);
rObs    = reshape(x(reshape(posObs,[3*nObs,1])),[3,nObs]); %[3,nObs]

%Synthesize measurement
H = zeros(2*nObs,6+2*nObs);
for i = 1:nObs
    norm_e = norm(rhatRSO-rObs(:,i));
    W1 = 1/(1+((rhatRSO(2)-rObs(2,i))/(rhatRSO(1)-rObs(1,i)))^2);
    T = (rhatRSO(2)-rObs(2,i))/(rhatRSO(1)-rObs(1,i))^2;
    W3 = -norm_e^3;
    W2 = 1/sqrt(1+((rhatRSO(3)-rObs(3,i))/norm_e)^2);
    H(2*i-1,1) = -W1*T;
    H(2*i-1,2) = W1/(rhatRSO(1)-rObs(1,i));
    H(2*i,1) = W2*rhatRSO(1)/W3;
    H(2*i,2) = W2*rhatRSO(2)/W3;
    H(2*i,3) = W2*((rhatRSO(3)-rObs(3,i))/W3 + 1/norm_e);
    H(2*i+(-1:0),6+2*i+(-1:0)) = eye(2);
end

end
