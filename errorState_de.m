function delx_dot = errorState_de( delx, input )
% Equation 5 in the debugging guide

% extract input parameters
xhat = input.xhat;
simpar = input.simpar;

% Na = simpar.general.n_assets;
% mu = simpar.Constants.muEarth;
% 
% TauBias = -1/simpar.Constants.tauBias * eye(Na);
% TauAtmo = -1/simpar.Constants.tauAtmo * eye(3);
% 
% phat = xhat(Na+1:Na+3);
% phatMag = norm(phat);
% 
% g = mu / phatMag^5 * (3 * diag(phat)^2 - phatMag^2 * eye(3));
% 
% F = [TauBias, zeros(Na,9);
%      zeros(3,Na+3), eye(3), zeros(3,3);
%      zeros(3,Na), g, zeros(3,3), eye(3);
%      zeros(3,Na+6), TauAtmo];

F = calc_F(xhat, simpar);

delx_dot = F * delx + input.w;

end
