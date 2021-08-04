function Q = computePSD(simpar , truthNav)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

nObs = simpar.general.nObs;
fnames = fieldnames(simpar.(truthNav).params);
iSS = contains(fnames,"bias");
sigs = struct2cell(simpar.(truthNav).params);
sigBias = cell2mat(sigs(iSS));

Q = zeros(2*nObs,1);
for i = 1:2*nObs
    
    if mod(i,2)
        sig = sigBias(1);
    else
        sig = sigBias(2);
    end
    Q(i) = 2*sig.^2./simpar.general.tau_obs;

end

end