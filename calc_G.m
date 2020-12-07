function G = calc_G( simpar )
%calc_G Calculates the process noise dynamic coupling matrix
%% Unpack the inputs
Na = simpar.general.n_assets;
Ntdoa = 0;
for i=1:Na-1
    Ntdoa = Ntdoa + i;
end
Ntdoa = Na - 1;

%% Compute G
G = zeros(Ntdoa,Na);
cnt = 0;
% for i=1:Na-1
    i = 1;
    for j=i+1:Na
        cnt = cnt + 1;
        G(cnt,i) = 1;
        G(cnt,j) = -1;
    end
% end
end
