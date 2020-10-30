function del_tdoa = predict_measurement( xhat, input )
%predict_measurement_example predicts the discrete measurement

%% extract input parameters
simpar = input.simpar;
x = input.chaserStates;         % this only contains the chaser positions and velocities
%% extract position matrices
% determine the number of chaser assets
Na = simpar.general.n_assets;
% initialize the position vectors for the chaser assets
p = zeros(3,Na);
% loop through the chaser assets
for ii=1:Na
    % update indexer for chaser assets
    i = (ii - 1) * simpar.general.n_chaser;
    % set position of chaser ii
    p(:,ii) = x(i+1:i+3);
end
% set the clocking bias for the chaser assets
bhat = xhat(1:Na);
% set the position vector for the target
phattarget = xhat(Na+1:Na+3);
%% calculate the tdoa measuremnts
% compute the number of tdoa measurements
N_tdoa = 0;
for ii=1:Na-1
    N_tdoa = N_tdoa + ii;
end
% initialize the true distance difference vector
del_r_true = zeros(N_tdoa,1);
% loop thru the tdoa measurement indexes (i,j) and compute the true
% distance difference vector
cnt = 0;
for i=1:Na-1
    for j=i+1:Na
        cnt = cnt + 1;
        del_r_true(cnt) = norm( phattarget - p(:,i) ) - norm( phattarget - p(:,j) );  % part of Eq 28
    end
end
% compute the true tdoa measurement
del_tdoa_true = del_r_true / simpar.Constants.c;   % another part of Eq 28
% initialize the actual tdoa measurement
del_tdoa = zeros(N_tdoa,1);
% loope thru the tdoa measurement indexed (i,j) and compute the actual tdoa
% measurements
cnt = 0;
for i=1:Na-1
    for j=i+1:Na
        cnt = cnt + 1;
        del_tdoa(cnt) = del_tdoa_true(cnt) + bhat(i) - bhat(j);  % final part of Eq 28
    end
end
end