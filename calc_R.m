function R = calc_R( simpar )
%calc_R Calculates the measurement noise covariance

%% Unpack the inputs
Na = simpar.general.n_assets;

sigmaSq = zeros(Na,1);
for i=1:Na
    % amount of noise error is total error - bias error
    sigmaSq(i) = simpar.nav.params.(['sig_nu',int2str(i),'_ss'])^2;
end

if ~simpar.general.Randys_R_def_enable
    R = diag(sigmaSq);
else
    % calc number of tdoa measurements
    if simpar.general.all_tdoa_enable
        Ntdoa = 0;
        for i=1:Na-1
            Ntdoa = Ntdoa + i;
        end
    else
        Ntdoa = Na - 1;
    end

    % initialize R
    R = zeros(Ntdoa, Ntdoa);

    %% Calcs
    
    if simpar.general.all_tdoa_enable
        % loop thru rows of R
        row = 0;
        for irow = 1:Na-1
            for jrow = irow+1:Na
                row = row + 1;
                % loop thru columns of R
                col = 0;
                for icol = 1:Na-1
                    for jcol = icol+1:Na
                        col = col + 1;

                        if irow == icol
                            R(row,col) = R(row,col) + sigmaSq(irow);
                        end

                        if irow == jcol
                            R(row,col) = R(row,col) - sigmaSq(irow);
                        end

                        if jrow == icol
                            R(row,col) = R(row,col) - sigmaSq(jrow);
                        end

                        if jrow == jcol
                            R(row,col) = R(row,col) + sigmaSq(jrow);
                        end
                    end
                end
            end
        end
        
    else
        % loop thru rows of R
        row = 0;
        irow = 1;
        for jrow = irow+1:Na
            row = row + 1;

            % loop thru columns of R
            col = 0;
            icol = 1;
            for jcol = icol+1:Na
                col = col + 1;

                if irow == icol
                    R(row,col) = R(row,col) + sigmaSq(irow);
                end

                if irow == jcol
                    R(row,col) = R(row,col) - sigmaSq(irow);
                end

                if jrow == icol
                    R(row,col) = R(row,col) - sigmaSq(jrow);
                end

                if jrow == jcol
                    R(row,col) = R(row,col) + sigmaSq(jrow);
                end
            end
        end
    end
end

