function [ dele ] = calcErrors( xhat, x, simpar )
%calcErrors computes estimation errors
%
% Inputs:
%   x_hat = estimated state vector(mixed units)
%   x = state vector (mixed units)
%
% Outputs
%   dele = estimation error state vector (mixed units)
%
% Example Usage
% [ dele ] = calcErrors( x_hat, x )


%Get size of input and verify that it is a single vector
[~,m_x] = size(x);
[~, m_xhat] = size(xhat);
assert(m_x == m_xhat);
xhat_true = truth2nav(x, simpar);           % Eq. 10 or 11

dele = xhat_true - xhat;                    % Eq. 9
end
