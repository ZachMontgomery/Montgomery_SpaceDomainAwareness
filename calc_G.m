function G = calc_G( simpar )
%calc_G Calculates the process noise dynamic coupling matrix
%% Unpack the inputs
Na = simpar.general.n_assets;
if simpar.general.all_tdoa_enable
    Ntdoa = 0;
    for i=1:Na-1
        Ntdoa = Ntdoa + i;
    end
else
    Ntdoa = Na - 1;
end

%% Compute G
if simpar.general.Randys_R_def_enable
    G = eye(Ntdoa);
else
    G = zeros(Ntdoa,Na);
    cnt = 0;
    if simpar.general.all_tdoa_enable
        for i=1:Na-1
            for j=i+1:Na
                cnt = cnt + 1;
                G(cnt,i) = 1;
                G(cnt,j) = -1;
            end
        end
    else
        i = 1;
        for j=i+1:Na
            cnt = cnt + 1;
            G(cnt,i) = 1;
            G(cnt,j) = -1;
        end
    end
end
