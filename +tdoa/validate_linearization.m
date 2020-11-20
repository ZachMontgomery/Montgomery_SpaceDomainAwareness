function validate_linearization( input )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% unpack inputs
simpar = input.simpar;
x = input.x;
ztilde = input.ztilde;
Na = simpar.general.n_assets;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create error vector
delx = zeros(simpar.general.n_design,1);
for i=1:Na
    delx(i) = simpar.errorInjection.(['b',int2str(i)]);
end
axis = {'x','y','z'};
for i=1:3
    delx(Na+i) = simpar.errorInjection.(['pt',axis{i}]);
    delx(Na+3+i) = simpar.errorInjection.(['vt',axis{i}]);
    delx(Na+6+i) = simpar.errorInjection.(['a',axis{i}]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inject errors to create xhat
xhat = injectErrors(truth2nav(x,simpar), delx, simpar);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate predicted measurement nonlinear
input_predMeas.simpar = simpar;
input_predMeas.chaserStates = x(1:simpar.general.n_chaser*Na);
ztildehat_nl = tdoa.predict_measurement(xhat, input_predMeas);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate predicted measurement linear
H = tdoa.compute_H(xhat, input_predMeas);
ztildehat_l = H * delx;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute nonlinear and linear residuals and their difference
residual_nl = ztilde - ztildehat_nl;
residual_l  = ztilde - ztildehat_l;
difference = residual_nl - residual_l;
results = table(residual_nl, residual_l, difference);
disp(results)
end
