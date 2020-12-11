function H = compute_H( xhat, input )

%% uppack inputs
simpar = input.simpar;
x = input.chaserStates;  % this only contains the chaser assets states

Na = simpar.general.n_assets;
c = simpar.Constants.c;

pc = simpar.Constants.posCover;
bc = simpar.Constants.biaCover;

%% compute the number of tdoa measurements
N_tdoa = 0;
for ii=1:Na-1
    N_tdoa = N_tdoa + ii;
end
N_tdoa = Na - 1;

%%
pt = xhat(Na+1:Na+3);

H = zeros(N_tdoa,simpar.general.n_design);
cnt = 0;
% for i=1:Na-1
    i = 1;
    ii = (i-1)*simpar.general.n_chaser;
    pi = x(ii+1:ii+3);
    for j = i+1:Na
        cnt = cnt + 1;
        jj = (j-1)*simpar.general.n_chaser;
        pj = x(jj+1:jj+3);
        
        % derivative with respect to bias terms
        H(cnt,i) = 1;
        H(cnt,j) = -1;
        
        % derivative with respect to target position
        for k=1:3
            H(cnt,Na+k) = ((pt(k)-pi(k))/norm(pt-pi) - (pt(k)-pj(k))/norm(pt-pj)) ...
                / c * bc / pc;
        end
    end
% end
end
