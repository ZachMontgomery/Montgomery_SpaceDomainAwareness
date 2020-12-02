function [ P_dot ] = navCov_de( P, input )

%Unpack the inputs for clarity
xhat = input.xhat;
simpar = input.simpar;
ytilde = input.ytilde;

%Compute state dynamics matrix
F = calc_F(xhat, ytilde, simpar);

%Compute process noise coupling matrix
G = calc_G(xhat, simpar);

%Compute process noise PSD matrix
Q = calc_Q(xhat, simpar);

%Compute Phat_dot
P_dot = [];
end
