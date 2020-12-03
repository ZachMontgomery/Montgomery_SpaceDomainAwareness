function B = calc_B( simpar )

Na = simpar.general.n_assets;
Nw = Na + 6;

B = [eye(Na), zeros(Na,6);
    zeros(3,Nw);
    zeros(6,Na), eye(6)];

end