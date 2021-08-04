function B = calc_B( simpar )

Na = simpar.general.n_assets;
Nw = 3*Na + 6;

B = [eye(3*Na), zeros(3*Na,6);
    zeros(3,Nw);
    zeros(6,3*Na), eye(6)];

end