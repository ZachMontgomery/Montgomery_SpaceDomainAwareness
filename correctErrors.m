function [ x_hat_c ] = correctErrors( x_hat, dele, simpar)
%correctState corrects the state vector given an estimated error state
%vector
%
% Inputs:
%   x_hat = estimated state vector (mixed units)
%   delx = error state vector (mixed units)
%
% Outputs
%   x = description (units)
%
% Example Usage
% [ x ] = correctState( x_hat, delx )


%Get size of input and verify that it is a single vector
[~,m_x] = size(x_hat);
[~, m_delx] = size(dele);
assert(m_x == m_delx);

x_hat_c = x_hat + dele;                 % Eq. 7

end
