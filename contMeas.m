function del_tdoa = contMeas( x, input )
%contInertialMeas synthesizes noise measurements used to propagate the
%navigation state
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
% [ output_args ] = contInertialMeas( input_args )

% Author: 
% Date: 31-Aug-2020 15:46:59
% Reference: 
% Copyright 2020 Utah State University

simpar = input.simpar;
nu = input.nu;


% determine the number of chaser assets
Na = simpar.general.n_assets;
% initialize the position and velocity vectors for the chaser assets
p = zeros(3,Na);
% v = zeros(3,Na);
% initialize the clocking bias for the chaser assets
b = zeros(Na,1);
% loop through the chaser assets
for ii=1:Na
    % update indexer for chaser assets
    i = (ii - 1) * 7;
    % set position of chaser ii
    p(:,ii) = x(i+1:i+3);
    % set velocity of chaser ii
%     v(:,ii) = x(i+4:i+6);
    % set the bias of chaser ii
    b(ii) = x(i+7);
end
% update indexer for target
i = 7*Na;
ptarget = x(i+1:i+3);
% vtarget = x(i+4:i+6);

N_tdoa = 0;
for ii=1:Na-1
    N_tdoa = N_tdoa + ii;
end

del_r_true = zeros(N_tdoa,1);
cnt = 0;
for i=1:Na-1
    for j=i+1:Na
        cnt = cnt + 1;
        del_r_true(cnt) = norm( ptarget - p(:,i) ) - norm( ptarget - p(:,j) );
    end
end

del_tdoa_true = del_r_true / simpar.Constants.c;

del_tdoa = zeros(N_tdoa,1);
cnt = 0;
for i=1:Na-1
    for j=i+1:Na
        cnt = cnt + 1;
        del_tdoa(cnt) = del_tdoa_true(cnt) + nu(j) - nu(i) + b(j) - b(i);
    end
end

end