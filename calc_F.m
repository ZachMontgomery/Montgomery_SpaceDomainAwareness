function [ F ] = calc_F( xhat, simpar )
%calc_F computes the dynamics coupling matrix

%% Unpack the inputs

Na = simpar.general.n_assets;
mu = simpar.Constants.muEarth;

TauBias = -1/simpar.Constants.tauBias * eye(Na);
TauAtmo = -1/simpar.Constants.tauAtmo * eye(3);

phat = xhat(Na+1:Na+3);
phatMag = norm(phat);

g = mu / phatMag^5 * (3 * phat * phat' - phatMag^2 * eye(3));

F = [TauBias, zeros(Na,9);
     zeros(3,Na+3), eye(3), zeros(3,3);
     zeros(3,Na), g, zeros(3,3), eye(3);
     zeros(3,Na+6), TauAtmo];

end