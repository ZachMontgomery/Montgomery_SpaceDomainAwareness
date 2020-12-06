function delx = estimate_error_state_vector( K, res )
%estimate_error_state_vector calculates the estimate of the error state
%vector

delx = K * res;

end
