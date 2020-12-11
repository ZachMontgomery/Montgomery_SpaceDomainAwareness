function xhatdot = navState_de(xhat,input)
%navState_de computes the derivative of the nav state
%% Unpack the inputs
simpar = input.simpar;
% unpack unit conversions
pc = simpar.Constants.posCover;
vc = simpar.Constants.velCover;
bc = simpar.Constants.biaCover;
ac = simpar.Constants.atmCover;
% number of assets
Na = simpar.general.n_assets;
%% Compute individual elements of x_dot
% initialize xhatdot
xhatdot = zeros(simpar.general.n_design,1);
% loop thru assets
for i=1:Na
    % bias dot of asset $i$
    xhatdot(i) = -xhat(i) / simpar.Constants.tauBias;                       % Eq 19
end
% position dot of target equals velocity of target
xhatdot(Na+1:Na+3) = xhat(Na+4:Na+6) / vc * pc;                             % Eq 20
% velocity dot of the target equals gravity + atmo accel
xhatdot(Na+4:Na+6) = (-simpar.Constants.muEarth ...
    / norm(xhat(Na+1:Na+3))^3 * xhat(Na+1:Na+3) * pc^2 + ...
    xhat(Na+7:Na+9) / ac) * vc;                                             % Eq 21
% a_atmo dot
xhatdot(Na+7:Na+9) = -xhat(Na+7:Na+9)/simpar.Constants.tauAtmo;             % Eq 22
end
