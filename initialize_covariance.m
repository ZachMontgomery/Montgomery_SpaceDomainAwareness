function P = initialize_covariance( simpar )

n_design = simpar.general.n_design;

P = zeros(n_design);

Na = simpar.general.n_assets;

for i=1:Na
    P(i,i) = simpar.nav.ic.(['sig_b',int2str(i)])^2;
end

axis = {'x','y','z'};

for i=1:3
    P(Na+i,Na+i) = simpar.nav.ic.(['sig_p',axis{i}])^2;
    P(Na+i+3,Na+i+3) = simpar.nav.ic.(['sig_v',axis{i}])^2;
    P(Na+i+6,Na+i+6) = simpar.nav.ic.(['sig_a',axis{i}])^2;
end 

end
