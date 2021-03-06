function del_tdoa = synthesize_measurement( x, input )
%synthesize_measurement_example synthesizes the discrete measurement
%corrupted by noise

%% extract input parameters
simpar = input.simpar;
nu = input.nu;

pc = simpar.Constants.posCover;
bc = simpar.Constants.biaCover;

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
% update indexer for target
i = (simpar.general.n_chaser+1)*Na;
% set the clocking bias for the chaser assets
b = x(Na*simpar.general.n_chaser+1:i);
% set the position vector for the target
ptarget = x(i+1:i+3);
%% calculate the tdoa measuremnts
% compute the number of tdoa measurements
if simpar.general.all_tdoa_enable
    N_tdoa = 0;
    for ii=1:Na-1
        N_tdoa = N_tdoa + ii;
    end
else
    N_tdoa = Na - 1;
end
% initialize the true distance difference vector
del_r_true = zeros(N_tdoa,1);
% loop thru the tdoa measurement indexes (i,j) and compute the true
% distance difference vector
cnt = 0;
if simpar.general.all_tdoa_enable
    for i=1:Na-1
        for j=i+1:Na
            cnt = cnt + 1;
            del_r_true(cnt) = norm(ptarget - p(:,i)) - norm(ptarget - p(:,j));  % part of Eq 28
        end
    end
else
    i = 1;
    for j=i+1:Na
        cnt = cnt + 1;
        del_r_true(cnt) = norm(ptarget - p(:,i)) - norm(ptarget - p(:,j));  % part of Eq 28
    end
end

% compute the true tdoa measurement
del_tdoa_true = del_r_true / simpar.Constants.c / pc * bc;        % remianing part of Eq 28
% initialize the actual tdoa measurement
del_tdoa = zeros(N_tdoa,1);
% loop thru the tdoa measurement indexed (i,j) and compute the actual tdoa
% measurements
if simpar.general.all_tdoa_enable
    cnt = 0;
    for i=1:Na-1
        for j=i+1:Na
            cnt = cnt + 1;
            if simpar.general.Randys_R_def_enable
                del_tdoa(cnt) = del_tdoa_true(cnt) + nu(cnt) + b(i) - b(j);   % Eq 29
            else
                del_tdoa(cnt) = del_tdoa_true(cnt) + nu(i) - nu(j) + b(i) - b(j);   % Eq 29
            end
        end
    end
else
    cnt = 0;
    i = 1;
    for j=i+1:Na
        cnt = cnt + 1;
        if simpar.general.Randys_R_def_enable
            del_tdoa(cnt) = del_tdoa_true(cnt) + nu(cnt) + b(i) - b(j);   % Eq 29
        else
            del_tdoa(cnt) = del_tdoa_true(cnt) + nu(i) - nu(j) + b(i) - b(j);   % Eq 29
        end
    end
end
end