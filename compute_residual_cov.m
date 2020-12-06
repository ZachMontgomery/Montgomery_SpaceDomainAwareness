function resCov = compute_residual_cov( H, P, G, R )
%compute_residual_cov calculates the covariance of the residual
resCov = H * P * H' + G * R * G';
end
