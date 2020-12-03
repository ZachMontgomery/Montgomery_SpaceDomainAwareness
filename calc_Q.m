function [ Q ] = calc_Q( simpar )
%calc_Q Calculates the process noise power spectral density

axis = {'x', 'y', 'z'};

%% Unpack the inputs
Na = simpar.general.n_assets;

%% Calcs

% initialize Q matrix
Q = zeros(Na+6);

% clocking bias
for i=1:Na
    Q(i,i) = 2 * simpar.nav.params.(['sig_b',int2str(i),'_ss'])^2 / simpar.Constants.tauBias;
end

% velocity dot
for i=1:3
    j = Na + i;
    Q(j,j) = simpar.nav.params.(['Q_grav_',axis{i}]);
end

% atmo accelerations
for i=1:3
    j = Na + 3 + i;
    Q(j,j) = 2 * simpar.nav.params.(['sig_a',axis{i},'_ss'])^2 / simpar.Constants.tauAtmo;
end

end
