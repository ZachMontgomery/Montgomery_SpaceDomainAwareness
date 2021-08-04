function [ ztilde ] = synthesize_measurement( x, simpar )
%synthesize_measurement_example synthesizes the discrete measurement
%corrupted by noise
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
% [ output_args ] = synthesize_measurement_example( input_args )
%
% See also FUNC1, FUNC2

% Author: Randy Christensen
% Date: 31-Aug-2020 16:00:48
% Reference: 
% Copyright 2020 Utah State University

% Parameter
posRSO  = simpar.states.ix.posRSO; %indices for rRSO
posObs  = simpar.states.ix.posObs; %indices for rObs
bias    = simpar.states.ix.bias;   %indices for b
nObs    = simpar.states.nObs;      %number of observers

% Get sigmas for radec
sigma = zeros(2,nObs); %[2,nObs]

fieldName = ['sig_meas_alpha';'sig_meas_delta'];
for i = 1:nObs
    sigma(1,i) = simpar.truth.params.(fieldName(1,:));
    sigma(2,i) = simpar.truth.params.(fieldName(2,:));
end

%Synthesize white noise eta
eta = sigma.*randn(2,nObs); %[2,nObs]

%Get the states needed
rRSO = x(posRSO);
rObs = reshape(x(reshape(posObs,[3*nObs,1])),[3,nObs]); %[3,nObs]
b    = reshape(x(bias),[2,nObs]); %[2,nObs]

%Synthesize measurement
alpha_tilde = zeros(nObs,1);
delta_tilde = zeros(nObs,1);
for i = 1:nObs
    alpha_tilde(i) = atan2(rRSO(2)-rObs(2,i),rRSO(1)-rObs(1,i)) + ...
        b(1,i) + eta(1,i);
    delta_tilde(i) = asin((rRSO(3)-rObs(3,i))/norm(rRSO-rObs(:,i))) + ...
        b(2,i) + eta(2,i);
end
ztilde = reshape([alpha_tilde,delta_tilde]',[2*nObs,1]); %[2*nObs,1]
end
