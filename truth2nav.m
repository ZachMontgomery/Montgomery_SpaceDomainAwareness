function [ xhat ] = truth2nav( x, simparam )
%truth2nav maps the truth state vector to the navigation state vector

% Eq 11
A = [zeros(simparam.general.n_design, ...
    simparam.general.n_assets*simparam.general.n_chaser)...
    eye(simparam.general.n_design)];
xhat = A * x;
end
