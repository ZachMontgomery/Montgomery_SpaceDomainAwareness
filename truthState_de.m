function xdot = truthState_de( x, input)
%truthState_de computes the derivative of the truth state
%% Unpack the inputs
simpar = input.simpar;
w = input.w;
%% unpack unit conversions
pc = simpar.Constants.posCover;
vc = simpar.Constants.velCover;
bc = simpar.Constants.biaCover;
ac = simpar.Constants.atmCover;
%% Compute individual elements of x_dot
Na = simpar.general.n_assets;
% initialize bias indexer
j = Na*simpar.general.n_chaser;
% initialize xdot
xdot = zeros(j+simpar.general.n_design,1);
% loop thru chaser assets
for ii=1:Na
    % update indexer for asset ii
    i = (ii - 1)*simpar.general.n_chaser;
    % position dot of asset i equals velocity of asset i
    xdot(i+1:i+3) = x(i+4:i+6) / vc * pc;                                   % Eq 12
    % velocity dot of asset i equals gravitational point mass model
    xdot(i+4:i+6) = -simpar.Constants.muEarth / norm(x(i+1:i+3))^3 * ...
        x(i+1:i+3) * pc^2 * vc;                                              % Eq 13
    % b dot of asset i
    xdot(j+ii) = -x(j+ii) / simpar.Constants.tauBias + w(ii);               % Eq 14
end
% update indexer for target
i = j + Na;
% position dot of target equals velocity of target
xdot(i+1:i+3) = x(i+4:i+6) / vc * pc;                                       % Eq 15
% velocity dot of the target equals gravity + atmo accel + noise
xdot(i+4:i+6) = (-simpar.Constants.muEarth / norm(x(i+1:i+3))^3 * ...
    x(i+1:i+3) * pc^2 + x(i+7:i+9) / ac) * vc + w(Na+1:Na+3);                 % Eq 16
% a_atmo dot
xdot(i+7:i+9) = -x(i+7:i+9)/simpar.Constants.tauAtmo + w(Na+4:Na+6);        % Eq 17
end