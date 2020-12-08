function Pp = update_covariance( K, H, Pa, G, R, simpar )
%update_covariance updates the covariance matrix

%Don't forget to perform numerical checking and conditioning of covariance
%matrix

Nd = simpar.general.n_design;

temp = eye(Nd) - K * H;

Pp = temp*Pa*temp' + K*G*R*G'*K';

if ~issymmetric(Pp)
    disp('updated covariance is not symmetric');
%     pause
    for i=1:Nd-1
        for j=i+1:Nd
            if i==j
                continue
            end
            temp = (Pp(i,j) + Pp(j,i)) / 2;
            Pp(i,j) = temp;
            Pp(j,i) = temp;
        end
    end
end

d = eig(Pp);
if ~all(d > -2*eps)
    disp('updated covariance is not semipositive definite')
%     pause
end


end
