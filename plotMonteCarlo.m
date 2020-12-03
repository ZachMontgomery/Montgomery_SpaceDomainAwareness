function [ hfigs ] = plotMonteCarlo(errors, traj_ref, traj, simpar)
%PLOTMONTECARLO_GPSINS creates hair plots of the estimation error for each
%state.  I left example code so you can see how I normally make these
%plots.
[n, ~, ~] = size(errors);
hfigs = [];

%% Unpack values
Na = simpar.general.n_assets;

%% Plot estimation errors
% for i=1:Na
%     hfigs(end+1) = figure('Name', sprintf('est_err_%d', i ));
%     hold on;
%     grid on;
%     ensemble = squeeze(errors(i,:,:));
%     filter_cov = squeeze(traj_ref.navCov(i,i,:));
%     h_hair = stairs(traj_ref.time_nav, ensemble, 'Color', [0.7,0.7,0.7]);
%     h_filter_cov = stairs(traj_ref.time_nav, ...
%         [3*sqrt(filter_cov) -3*sqrt(filter_cov)], '--r');
%     legend([h_hair(1), h_filter_cov(1)], 'MC run', 'EKF cov')
%     xlabel('time(s)')
%     ylabel(['Asset ',int2str(i), ' clocking bias (sec)'])
% end

axis = {'x', 'y', 'z'};
ylabels = {};
for i=1:Na
    ylabels{i} = ['Asset ',int2str(i), ' clocking bias (sec)'];
end
for i=1:3
    ylabels{Na+i}   = ['RSO target ',axis{i},' position (m)'];
    ylabels{Na+3+i} = ['RSO target ',axis{i},' velocity (m/s)'];
    ylabels{Na+6+i} = ['Atmospheric ',axis{i},' acceleration (m/s^2)'];
end
for i=1:n
    
    hfigs(end + 1) = figure('Name',sprintf('est_err_%d',i)); %#ok<*AGROW>
    hold on;
    grid on;
    ensemble = squeeze(errors(i,:,:));
    filter_cov = squeeze(traj_ref.navCov(i,i,:));
    h_hair = stairs(traj_ref.time_nav, ensemble,'Color',[0.8 0.8 0.8]);
    h_filter_cov = stairs(traj_ref.time_nav, ...
        [3*sqrt(filter_cov) -3*sqrt(filter_cov)],'--r');
    legend([h_hair(1), h_filter_cov(1)],'MC run','EKF cov')
    xlabel('time(s)')
    ylabel(ylabels{i})
end
% %% Create estimation error plots in LVLH frame
% nsamp = length(traj_ref.time_nav);
% %Transform
% P_lvlh = zeros(simpar.states.nxfe, simpar.states.nxfe, nsamp);
% errors_lvlh = zeros(simpar.states.nxfe,nsamp,...
%     simpar.general.n_MonteCarloRuns);
% for i=1:nsamp
%     r_i = traj_ref.truthState(simpar.states.ix.pos,i);
%     v_i = traj_ref.truthState(simpar.states.ix.vel,i);
%     T_i2lvlh = inertial2lvlh(r_i, v_i);
%     A = blkdiag(T_i2lvlh, T_i2lvlh, ...
%         eye(simpar.states.nxfe-6, simpar.states.nxfe-6));
%     P_lvlh(:,:,i) = A*traj_ref.navCov(:,:,i)*A';
%     for j=1:simpar.general.n_MonteCarloRuns
%         errors_lvlh(:,i,j) = A*errors(:,i,j);
%     end
% end
% ylabels = {'$X_{LVLH}$ Position Error $(m)$',...
%     '$Y_{LVLH}$ Position Error $(m)$',...
%     '$Z_{LVLH}$ Position Error $(m)$',...
%     '$X_{LVLH}$ Velocity Error $(m/s)$',...
%     '$Y_{LVLH}$ Velocity Error $(m/s)$',...
%     '$Z_{LVLH}$ Velocity Error $(m/s)$'};
% for i=1:6
%     hfigs(end+1) = figure('Name',sprintf('est_err_lvlh_%d',i)); %#ok<*AGROW>
%     hold on;
%     grid on;
%     ensemble = squeeze(errors_lvlh(i,:,:));
%     filter_cov = squeeze(P_lvlh(i,i,:));
%     h_hair = stairs(traj_ref.time_nav, ensemble,'Color',[0.8 0.8 0.8]);
%     h_filter_cov = stairs(traj_ref.time_nav, ...
%         [3*sqrt(filter_cov) -3*sqrt(filter_cov)],'--r');
%     legend([h_hair(1), h_filter_cov(1)],'MC run','EKF cov')
%     xlabel('time$\left(s\right)$','Interpreter','latex');
%     ylabel(ylabels{i},'Interpreter','latex');
% end
end