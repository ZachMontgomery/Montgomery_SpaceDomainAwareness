function P_dot = navCov_de( P, input )

%Unpack the inputs for clarity
xhat = input.xhat;
simpar = input.simpar;
Q = input.Q;
B = input.B;

%Compute state dynamics matrix
F = calc_F(xhat, simpar);

%Compute process noise coupling matrix
% B = calc_B( simpar );

%Compute process noise PSD matrix
% Q = calc_Q( simpar );

%Compute Phat_dot
P_dot = F*P + P*F' + B*Q*B';
end
