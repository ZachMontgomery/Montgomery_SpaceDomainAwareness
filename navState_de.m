function xhatdot = navState_de(xhat,input)
%navState_de computes the derivative of the nav state
%
% Inputs:
%   xhat = nav state (mixed units)
%   input = input (mixed units)
%
% Outputs
%   xhatdot = nav state derivative (mixed units)
%
% Example Usage
% xhatdot = navState_de(xhat,input)

% Author: Randy Christensen
% Date: 21-May-2019 10:40:10
% Reference: none
% Copyright 2019 Utah State University

%% Unpack the inputs
simpar = input.simpar;
del_tdoa = input.ytilde;
x = input.x;

%% Compute individual elements of x_dot

% % position dot of target equals velocity of target
% xhatdot(1:3) = xhat(4:6);
% % calculate the position mag
% pmag = norm( xhat(1:3) );   %sqrt( xhat(1)^2 + xhat(2)^2 + xhat(3)^2 );
% % velocity dot of the target equals gravity + atmo accel + noise
% xhatdot(4:6) = -simpar.Canstants.muEarth / pmag ^3 * xhat(1:3) + xhat(7:9); % + w(4:6);
% % a_atmo dot
% tau = 500;  % set tau for a_atmo to 500 seconds
% xhatdot(7:9) = -xhat(7:9)/tau; % + w(7:9);

%% extract known postions of chaser assets
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

%% correct del_tdoa for known biases
cnt = 0;
for i=1:Na-1
    for j=i+1:Na
        cnt = cnt + 1;
        del_tdoa(cnt) = del_tdoa(cnt) + b(i) - b(j);
    end
end

% compute del_r
del_r = simpar.Constants.c * del_tdoa;
% ptarget initial guess to previous time step
ptarget0 = xhat(1:3);
% vtarget0 = xhat(4:6);

N_tdoa = length(del_tdoa);

del_ptarget = ptarget0(:);

CNT = 0;
z = zeros(N_tdoa,1);
while norm(del_ptarget) > 1

    % compute Jacobian
    A = zeros(N_tdoa,3);
    for col=1:3
        cnt = 0;
        for i=1:Na-1
            for j=i+1:Na
                cnt = cnt + 1;
                A(cnt,col) = (ptarget0(col) - p(col,i)) / norm(ptarget0 - p(:,i)) - (ptarget0(col) - p(col,j)) / norm(ptarget0 - p(:,j));
            end
        end
    end
    % compute z from reference Foy
    cnt = 0;
    for i=1:Na-1
        for j=i+1:Na
            cnt = cnt + 1;
            z(cnt) = del_r(cnt) - norm(ptarget0 - p(:,i)) + norm(ptarget0 - p(:,j));
        end
    end
    
    del_ptarget = inv(A'*A)*A'*z;
    ptarget0 = ptarget0 + del_ptarget;
    
    CNT = CNT + 1;
    if CNT > 200
        disp('Took too long to iterate through taylor-series method')
        input()
    end
end

ptarget = ptarget0;
vtarget = (ptarget - xhat(1:3)) / simpar.general.dt;



%% Assign to output
xhatdot = zeros(9,1);
xhatdot(1:3) = ptarget;
xhatdot(4:6) = vtarget;
% a_atmo dot
tau = 500;  % set tau for a_atmo to 500 seconds
xhatdot(7:9) = -xhat(7:9)/tau; % + w(7:9);
end
