function Pp = update_covariance( K, H, Pa, G, R, simpar )
%update_covariance updates the covariance matrix

%Don't forget to perform numerical checking and conditioning of covariance
%matrix

Nd = simpar.general.n_design;

temp = eye(Nd) - K * H;

Pp = temp*Pa*temp' + K*G*R*G'*K';

if ~issymmetric(Pp)
%     disp('updated covariance is not symmetric');
%     pause
    Pp = (Pp + Pp') / 2;
end

d = eig(Pp);
if ~all(d > -2*eps)
    disp('updated covariance is not semipositive definite')
    pause
end


end
