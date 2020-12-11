function K = compute_Kalman_gain( P, H, resCov, enable )
%compute_Kalman_gain calculates the Kalman gain

K = P * H' * inv( resCov ) * enable;
% K = P * H' * eye(3) * 0;
% K = zeros(12,3);

end
