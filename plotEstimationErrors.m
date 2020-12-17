function h_figs = plotEstimationErrors(traj, simpar)
%plotEstimationErrors plots residuals and estimation errors for a
%single Monte Carlo run.  You need to include residuals and the +/- 3-sigma
%for all measurements that are active during this run.  You should also
%plot the estimation error with it's +/- 3-sigma for each state. I left 
%some example code from a Lunar Lander project so you can see how these
%plots are created.  I also left some example code that converts the errors 
%and covariances to a different coordinate system.
%% Extract true states, nav states, and covariances
navState = traj.navState;
navCov = traj.navCov;
nav_errors = calcErrors( navState, traj.truthState, simpar );
h_figs = [];

%% TDOA residuals
Na = simpar.general.n_assets;
if simpar.general.all_tdoa_enable
    Ntdoa = 0;
    for i=1:Na-1
        Ntdoa = Ntdoa + i;
    end
else
    Ntdoa = Na - 1;
end
cnt = 0;
for i = 1:Na-1
    for j = i+1:Na
        cnt = cnt + 1;
        if cnt > Ntdoa
            break
        end
        h_figs(end+1) = figure('Name',sprintf('res_tdoa_%d',i));
        stairs(traj.time_kalman, traj.navRes.tdoa(cnt,:)');
        hold on
        stairs(traj.time_kalman, ...
            3.*sqrt(squeeze(traj.navResCov.tdoa(cnt,cnt,:))),'r--');
        stairs(traj.time_kalman, ...
            -3.*sqrt(squeeze(traj.navResCov.tdoa(cnt,cnt,:))),'r--');
        xlabel('time (sec)');
        ylabel(sprintf('TDOA residual of assets %d and %d, (ns)',i,j));
        grid on;
    end
end

%% clocking bias error
for i = 1:Na
    h_figs(end+1) = figure('Name',sprintf('est_err_bias_%d',i));
    stairs(traj.time_nav, nav_errors(i,:));
    hold on;
    stairs(traj.time_nav,  3.*sqrt(squeeze(navCov(i,i,:))),'r--');
    stairs(traj.time_nav, -3.*sqrt(squeeze(navCov(i,i,:))),'r--');
    xlabel('time (sec)');
    ylabel(sprintf('Clocking bias of asset %d (ns)', i));
    legend('error','3-sigma');
    grid on;
end

%% Postion error
axisName = {'x','y','z'};
for i = 1:3
    j = Na + i;
    h_figs(end+1) = figure('Name',sprintf('est_error_pos_%d',i));
    stairs(traj.time_nav, nav_errors(j,:));
    hold on;
    stairs(traj.time_nav,  3.*sqrt(squeeze(navCov(j,j,:))),'r--');
    stairs(traj.time_nav, -3.*sqrt(squeeze(navCov(j,j,:))),'r--');
    xlabel('time (sec)');
    ylabel(sprintf('Estimated error of %s position (m)',axisName{i}));
    legend('error','3-sigma');
    grid on;
end

%% velocity error
for i = 1:3
    j = Na + 3 + i;
    h_figs(end+1) = figure('Name',sprintf('est_error_vel_%d',i));
    stairs(traj.time_nav, nav_errors(j,:));
    hold on;
    stairs(traj.time_nav,  3.*sqrt(squeeze(navCov(j,j,:))),'r--');
    stairs(traj.time_nav, -3.*sqrt(squeeze(navCov(j,j,:))),'r--');
    xlabel('time (sec)');
    ylabel(sprintf('Estimated error of %s velocity (cm/s)',axisName{i}));
    legend('error','3-sigma');
    grid on;
end

%% atmo error
for i = 1:3
    j = Na + 6 + i;
    h_figs(end+1) = figure('Name',sprintf('est_error_atmo_%d',i));
    stairs(traj.time_nav, nav_errors(j,:));
    hold on;
    stairs(traj.time_nav,  3.*sqrt(squeeze(navCov(j,j,:))),'r--');
    stairs(traj.time_nav, -3.*sqrt(squeeze(navCov(j,j,:))),'r--');
    xlabel('time (sec)');
    ylabel(sprintf('Estimated error of %s atmo accel (dnm/s^2)',axisName{i}));
    legend('error','3-sigma');
    grid on;
end

% %% Position estimation error
% axis_str = {'X_{i}','Y_{i}','Z_{i}'};
% i_axis = 0;
% for i=simpar.states.ixfe.pos
%     i_axis = i_axis + 1;
%     h_figs(end+1) = figure('Name',sprintf('est_err_%d',i)); %#ok<*AGROW>
%     stairs(traj.time_nav, nav_errors(i,:)); hold on
%     stairs(traj.time_nav, 3.*sqrt(squeeze(navCov(i,i,:))),'r--');
%     stairs(traj.time_nav,-3.*sqrt(squeeze(navCov(i,i,:))),'r--'); hold off
%     xlabel('Time(s)')
%     ystring = sprintf('%s Position Est Err (m)',axis_str{i_axis});
%     ylabel(ystring)
%     legend('error','3-sigma')
%     grid on;
% end
% %% Velocity esimation error
% axis_str = {'X_{i}','Y_{i}','Z_{i}'};
% i_axis = 0;
% for i=simpar.states.ixfe.vel
%     i_axis = i_axis + 1;
%     h_figs(end+1) = figure('Name',sprintf('est_err_%d',i)); %#ok<*AGROW>
%     stairs(traj.time_nav, nav_errors(i,:)); hold on
%     stairs(traj.time_nav, 3.*sqrt(squeeze(navCov(i,i,:))),'r--');
%     stairs(traj.time_nav,-3.*sqrt(squeeze(navCov(i,i,:))),'r--'); hold off
%     xlabel('Time(s)')
%     ystring = sprintf('%s Velocity Est Err (m/s)',axis_str{i_axis});
%     ylabel(ystring)
%     legend('error','3-sigma')
%     grid on;
% end
% %% Attitude estimation error
% axis_str = {'X_{b}','Y_{b}','Z_{b}'};
% i_axis = 0;
% for i=simpar.states.ixfe.att
%     i_axis = i_axis + 1;
%     h_figs(end+1) = figure('Name',sprintf('est_err_%d',i)); %#ok<*AGROW>
%     stairs(traj.time_nav, nav_errors(i,:)); hold on
%     stairs(traj.time_nav, 3.*sqrt(squeeze(navCov(i,i,:))),'r--');
%     stairs(traj.time_nav, -3.*sqrt(squeeze(navCov(i,i,:))),'r--'); hold off
%     xlabel('Time(s)')
%     ystring = sprintf('%s Attitude Est Err (rad)',axis_str{i_axis});
%     ylabel(ystring)
%     legend('estimated','true','3-sigma')
%     grid on;
% end
% %% Star tracker misalignment estimation error
% legend('X_{st}','Y_{st}','Z_{st}')
% i_axis = 0;
% for i=simpar.states.ixfe.stmis
%     i_axis = i_axis + 1;
%     h_figs(end+1) = figure('Name',sprintf('est_err_%d',i)); %#ok<*AGROW>
%     stairs(traj.time_nav, nav_errors(i,:)); hold on
%     stairs(traj.time_nav, 3.*sqrt(squeeze(navCov(i,i,:))),'r--');
%     stairs(traj.time_nav, -3.*sqrt(squeeze(navCov(i,i,:))),'r--'); hold off
%     xlabel('Time(s)')
%     ystring = sprintf('%s Star Tracker Misalignment Est Err(rad/s)',axis_str{i_axis});
%     ylabel(ystring)
%     legend('estimated','true','3-sigma')
%     grid on;
% end
% %% Camera misalignment estimation error
% legend('X_{c}','Y_{c}','Z_{c}')
% i_axis = 0;
% for i=simpar.states.ixfe.cmis
%     i_axis = i_axis + 1;
%     h_figs(end+1) = figure('Name',sprintf('est_err_%d',i)); %#ok<*AGROW>
%     stairs(traj.time_nav, nav_errors(i,:)); hold on
%     stairs(traj.time_nav, 3.*sqrt(squeeze(navCov(i,i,:))),'r--');
%     stairs(traj.time_nav, -3.*sqrt(squeeze(navCov(i,i,:))),'r--'); hold off
%     xlabel('Time(s)')
%     ystring = sprintf('%s Camera Misalignment Est Err (rad/s)',axis_str{i_axis});
%     ylabel(ystring)
%     legend('estimated','true','3-sigma')
%     grid on;
% end
% %% Gyro bias estimation error
% axis_str = {'X_{b}','Y_{b}','Z_{b}'};
% i_axis = 0;
% for i=simpar.states.ixfe.gbias
%     i_axis = i_axis + 1;
%     h_figs(end+1) = figure('Name',sprintf('est_err_%d',i)); %#ok<*AGROW>
%     stairs(traj.time_nav, nav_errors(i,:)); hold on
%     stairs(traj.time_nav, 3.*sqrt(squeeze(navCov(i,i,:))),'r--');
%     stairs(traj.time_nav, -3.*sqrt(squeeze(navCov(i,i,:))),'r--'); hold off
%     xlabel('Time(s)')
%     ystring = sprintf('%s Gyro Bias Est Err (rad/s)',axis_str{i_axis});
%     ylabel(ystring)
%     legend('estimated','true','3-sigma')
%     grid on;
% end
% %% Plot pos/vel covariances in LVLH frame
% % LVLH position and velocity
% nsamp = length(traj.time_nav);
% P_lvlh = zeros(simpar.states.nxfe, simpar.states.nxfe, nsamp);
% for i=1:nsamp
%     r_i = traj.truthState(simpar.states.ix.pos,i);
%     v_i = traj.truthState(simpar.states.ix.vel,i);
%     T_i2lvlh = inertial2lvlh(r_i, v_i);
%     A = blkdiag(T_i2lvlh, T_i2lvlh, ...
%         eye(simpar.states.nxfe-6, simpar.states.nxfe-6));
%     P_lvlh(:,:,i) = A*traj.navCov(:,:,i)*A';
% end
% ylabels = {'DR Position $(m)$',...
%     'CT Position $(m)$',...
%     'ALT Position $(m)$',...
%     'DR Velocity $(m/s)$',...
%     'CT Velocity $(m/s)$',...
%     'ALT Velocity $(m/s)$'};
% fignames = {'cov_position_errors_X_lvlh',...
%     'cov_position_errors_Y_lvlh',...
%     'cov_position_errors_Z_lvlh',...
%     'cov_velocity_errors_X_lvlh',...
%     'cov_velocity_errors_Y_lvlh',...
%     'cov_velocity_errors_Z_lvlh'};
% for i=1:6
%     h = figure('Name',fignames{i});
%     h_figs(end+1) = h;
%     hold on;
%     grid on;
%     filter_cov = squeeze(P_lvlh(i,i,:));
%     i_plot = 1:simpar.general.dt_kalmanUpdate/simpar.general.dt:nsamp;
%     stairs(traj.time_nav(i_plot), 3*sqrt(filter_cov(i_plot)));
%     xlabel('Time(s)')
%     ylabel(ylabels{i});
% end
end