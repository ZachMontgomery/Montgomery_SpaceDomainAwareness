function [ Q ] = calc_Q( simpar )
%calc_Q Calculates the process noise power spectral density

axis = {'x', 'y', 'z'};

%% Unpack the inputs
Na = simpar.general.n_assets;

%% Calcs

% initialize Q matrix
Q = zeros(3*Na+6);

% clocking bias
for i=1:Na
    Q(i,i) = 2 * simpar.nav.params.(['sig_b',int2str(i),'_ss'])^2 / simpar.Constants.tauBias;
end

% RaDec bias
for i=Na+1:2:3*Na
    Q(i,i) = 2 * simpar.nav.params.('sig_bias_alpha')^2 / simpar.Constants.tauBias;
    Q(i+1,i+1) = 2 * simpar.nav.params.('sig_bias_delta')^2 / simpar.Constants.tauBias;
end

% velocity dot
for i=1:3
    j = 3*Na + i;
    Q(j,j) = simpar.nav.params.(['Q_grav_',axis{i}]);
end

% atmo accelerations
for i=1:3
    j = 3*Na + 3 + i;
    Q(j,j) = 2 * simpar.nav.params.(['sig_a',axis{i},'_ss'])^2 / simpar.Constants.tauAtmo;
end

end
