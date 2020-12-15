function h_figs = plotNavPropErrors(traj)
% In this function, you should plot everything you want to see for a
% single simulation when there are no errors present.  I like to see things
% like the 3D trajectory, altitude, angular rates, etc.  Two sets of plots
% that are required are the estimation errors for every state and the
% residuals for any measurements.  I left some of my code for a lunar
% lander application, so you can see how I do it.  Feel free to use or
% remove whatever applies to your problem.
%% Prelims
h_figs = [];
simpar = traj.simpar;
Na = simpar.general.n_assets;
Nc = simpar.general.n_chaser;
if simpar.general.all_tdoa_enable
    Ntdoa = 0;
    for i=1:Na-1
        Ntdoa = Ntdoa + i;
    end
else
    Ntdoa = Na - 1;
end

%% Plot Trajectories
h_figs(end + 1) = figure('Name',sprintf('Reference Trajectory'));
% target orbit line
I = Nc * Na + Na;
lines = [];
lines(1) = plot3(traj.truthState(I+1,:),...
      traj.truthState(I+2,:),...
      traj.truthState(I+3,:),'k');
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
    lines(1+i) = plot3(traj.truthState(I+1,:),...
          traj.truthState(I+2,:),...
          traj.truthState(I+3,:),'Color',colorz{i});
end
% plot starting locations
I = Nc * Na + Na;
plot3(traj.truthState(I+1,1),...
      traj.truthState(I+2,1),...
      traj.truthState(I+3,1),'ko')
for i=1:Na
    I = (i-1)*Nc;
    plot3(traj.truthState(I+1,1),...
          traj.truthState(I+2,1),...
          traj.truthState(I+3,1),'Color',colorz{i},'Marker','o')
end
legend(lines,'Target',  'Asset 1',...
                        'Asset 2',...
                        'Asset 3',...
                        'Asset 4',...
                        'Asset 5',...
                        'Asset 6',...
                        'Asset 7')
axis equal


%% plot residuals
h_figs(end+1) = figure('Name',sprintf('Measurement_Residuals'));
plot(traj.time_kalman, traj.navRes.tdoa)
grid on;
xlabel('time (s)')
ylabel('TDOA residual (ns)')
labels = {};
cnt = 0;
for i = 1:Na-1
    for j = i+1:Na
        cnt = cnt + 1;
        if cnt > Ntdoa
            break
        end
        nums = [int2str(i),int2str(j)];
        labels{cnt} = ['$\tilde{z}_{',nums,'} - \hat{\tilde{z}}_{',nums,'}$'];
    end
end
legend( labels ,'Interpreter', 'latex')

%% plot actual TDOA measurements
h_figs(end+1) = figure('Name',sprintf('Measurements'));
plot(traj.time_kalman, traj.ztilde_tdoa)
xlabel('time (s)')
ylabel('$\tilde{z}$ (ns)', 'Interpreter', 'latex')
labels = {};
cnt = 0;
for i = 1:Na-1
    for j = i+1:Na
        cnt = cnt + 1;
        if cnt > Ntdoa
            break
        end
        nums = [int2str(i),int2str(j)];
        labels{cnt} = ['$\tilde{z}_{',nums,'}$'];
    end
end
legend( labels,'Interpreter', 'latex')
grid on;

%% plot estimation errors
h_figs(end+1) = figure('Name',sprintf('Estimation_Errors'));
nav_errors = calcErrors( traj.navState, traj.truthState, simpar );
plot(traj.time_nav, nav_errors)
xlabel('time (s)')
grid on;
labels = {};
for i=1:Na;
    labels{i} = ['bias ',int2str(i)];
end
axisName = {'x', 'y', 'z'};
for i=1:3;
    labels{Na+i}   = ['p',axisName{i},' target'];
    labels{Na+3+i} = ['v',axisName{i},' target'];
    labels{Na+6+i} = ['a',axisName{i},' atmo'];
end
legend(labels,'NumColumns', 4)
    
end