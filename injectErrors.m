function [ xhat_err ] = injectErrors( xhat_true, dele, simpar )
%injectErrors injects errors into the state estimates
%
% Inputs:
%   xhat_true = true navigation state vector (mixed units)
%   delx = error state vector (mixed units)
%
% Outputs
%   xhat_err = estimated state vector(units)
%
% Example Usage
% [ xhat_err ] = injectErrors( xhat_true, delx )


%Get size of inputs
[~,m_x] = size(xhat_true);
[~, m_delx] = size(dele);
assert(m_x == m_delx);
%Inject errors
xhat_err = xhat_true - dele;                % Eq. 8
end
