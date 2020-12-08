function [ hfigs ] = plotMonteCarlo(errors, traj_ref, traj, simpar)
%PLOTMONTECARLO_GPSINS creates hair plots of the estimation error for each
%state.  I left example code so you can see how I normally make these
%plots.
[n, ~, ~] = size(errors);
hfigs = [];

%% Unpack values
Na = simpar.general.n_assets;
Nc = simpar.general.n_chaser;

%% Plot estimation errors

axisName = {'x', 'y', 'z'};
ylabels = {};
for i=1:Na
    ylabels{i} = ['Asset ',int2str(i), ' clocking bias (sec)'];
end
for i=1:3
    ylabels{Na+i}   = ['RSO target ',axisName{i},' position (m)'];
    ylabels{Na+3+i} = ['RSO target ',axisName{i},' velocity (m/s)'];
    ylabels{Na+6+i} = ['Atmospheric ',axisName{i},' acceleration (m/s^2)'];
end
for i=1:n
    hfigs(end + 1) = figure('Name',sprintf('est_err_%d',i)); %#ok<*AGROW>
    hold on;
    grid on;
    ensemble = squeeze(errors(i,:,:));
    filter_cov = squeeze(traj_ref.navCov(i,i,:));
    h_hair = stairs(traj_ref.time_nav, ensemble,'Color',[0.5 0.5 0.5]);
    h_filter_cov = stairs(traj_ref.time_nav, ...
        [3*sqrt(filter_cov) -3*sqrt(filter_cov)],'--r');
    legend([h_hair(1), h_filter_cov(1)],'MC run','EKF cov')
    xlabel('time(s)')
    ylabel(ylabels{i})
end

%% Plot Trajectories
hfigs(end + 1) = figure('Name',sprintf('Reference Trajectory'));
% target orbit line
I = Nc * Na + Na;
lines = [];
lines(1) = plot3(traj_ref.truthState(I+1,:),...
      traj_ref.truthState(I+2,:),...
      traj_ref.truthState(I+3,:),'k');
hold on;
grid on;
% asset orbit lines
colorz = {  '#0072BD',...
            '#D95319',...
            '#EDB120',...
            '#7E2F8E',...
            '#77AC30',...
            '#4DBEEE',...
            '#A2142F'};
for i=1:Na
    I = (i-1)*Nc;
    lines(1+i) = plot3(traj_ref.truthState(I+1,:),...
          traj_ref.truthState(I+2,:),...
          traj_ref.truthState(I+3,:),'Color',colorz{i});
end
% plot starting locations
I = Nc * Na + Na;
plot3(traj_ref.truthState(I+1,1),...
      traj_ref.truthState(I+2,1),...
      traj_ref.truthState(I+3,1),'ko')
for i=1:Na
    I = (i-1)*Nc;
    plot3(traj_ref.truthState(I+1,1),...
          traj_ref.truthState(I+2,1),...
          traj_ref.truthState(I+3,1),'Color',colorz{i},'Marker','o')
end
legend(lines,'Target',  'Asset 1',...
                        'Asset 2',...
                        'Asset 3',...
                        'Asset 4',...
                        'Asset 5',...
                        'Asset 6',...
                        'Asset 7')
axis equal

end