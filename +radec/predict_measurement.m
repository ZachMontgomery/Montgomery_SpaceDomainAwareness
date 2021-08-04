function [ zhattilde ] = predict_measurement( x,xhat,simpar )
%predict_measurement_example predicts the discrete measurement
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
% [ output_args ] = predict_measurement_example( input_args )
%
% See also FUNC1, FUNC2

% Author: Randy Christensen
% Date: 31-Aug-2020 16:00:53
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
bhat    = reshape(xhat(bias),[2,nObs]); %[2,nObs]

%Synthesize measurement
alpha_hat_tilde = zeros(nObs,1);
delta_hat_tilde = zeros(nObs,1);
for i = 1:nObs
    alpha_hat_tilde(i) = atan2(rhatRSO(2)-rObs(2,i),rhatRSO(1)-rObs(1,i)) + ...
        bhat(1,i);
    delta_hat_tilde(i) = asin((rhatRSO(3)-rObs(3,i))/norm(rhatRSO-rObs(:,i))) + ...
        bhat(2,i);
end
zhattilde = reshape([alpha_hat_tilde,delta_hat_tilde]',[2*nObs,1]); %[2*nObs,1]
end

