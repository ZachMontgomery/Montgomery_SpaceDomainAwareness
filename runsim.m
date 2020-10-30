function [ traj ] = runsim( simpar, verbose, seed)
rng(seed);
%RUNSIM Runs a single trajectory given the parameters in simparams
tic;
%% Prelims
%Derive the number of steps in the simulation and the time
nstep = ceil(simpar.general.tsim/simpar.general.dt + 1);
nstep_aid = ceil(simpar.general.tsim/simpar.general.dt_kalmanUpdate);
t = (0:nstep-1)'*simpar.general.dt;
t_kalman = (0:nstep_aid)'.*simpar.general.dt_kalmanUpdate;
nstep_aid = length(t_kalman);
%% Pre-allocate buffers for saving data
% Truth, navigation, and error state buffers
x_buff          = zeros(simpar.states.nx,nstep);
xhat_buff       = zeros(simpar.states.nxf,nstep);
delx_buff       = zeros(simpar.states.nxfe,nstep);
est_error       = zeros(simpar.states.nxf,nstep);
% Navigation covariance buffer
% P_buff       = zeros(simpar.states.nxfe,simpar.states.nxfe,nstep);
% Continuous measurement buffer
% ytilde_buff     = zeros(simpar.general.n_inertialMeas,nstep);
% Residual buffers (star tracker is included as an example)
res_tdoa          = zeros(3,nstep_aid);
% TDOA measurement buffers
Ntdoa = 0;
for i=1:simpar.general.n_assets
    Ntdoa = Ntdoa + 1;
end
ztilde_tdoa    = zeros(Ntdoa,nstep_aid);
ztildehat_tdoa = zeros(Ntdoa,nstep_aid);
% resCov_tdoa       = zeros(3,3,nstep_aid);
% K_tdoa_buff       = zeros(simpar.states.nxfe,3,nstep_aid);
%% Initialize Vectors and matrices
% % Initialize the navigation covariance matrix
% P_buff(:,:,1) = initialize_covariance();
% Initialize the truth state vector
x_buff(:,1) = initialize_truth_state(simpar);
% Initialize the navigation state vector
xhat_buff(:,1) = initialize_nav_state(x_buff(:,1), simpar);
% Initialize the estimation error
est_error(:,1) = calcErrors(xhat_buff(:,1), x_buff(:,1), simpar);
%% Miscellaneous calcs
% Synthesize continuous sensor data at t_n-1

%Initialize the measurement counter
k = 1;


%Check that the error injection, calculation, and removal are all
%consistent if the simpar.general.checkErrDefConstEnable is enabled.
if simpar.general.checkErrDefConstEnable
    checkErrorDefConsistency(xhat_buff(:,1), x_buff(:,1), simpar)
end
%Inject errors if the simpar.general.errorPropTestEnable flag is enabled
if simpar.general.errorPropTestEnable
    fnames = fieldnames(simpar.errorInjection);
    for i=1:length(fnames)
        delx_buff(i,1) = simpar.errorInjection.(fnames{i});
    end
    xhat_buff(:,1) = injectErrors(truth2nav(x_buff(:,1)), delx_buff(:,1), simpar);
end
%% Loop over each time step in the simulation
for i=2:nstep
    % Propagate truth states to t_n
    %   Realize a sample of process noise (don't forget to scale Q by 1/dt!)
    %   Define any inputs to the truth state DE
    %   Perform one step of RK4 integration
    input_truth.w = zeros(length(x_buff(:,1)),1);
    input_truth.simpar = simpar;
    x_buff(:,i) = rk4('truthState_de', x_buff(:,i-1), input_truth, simpar.general.dt);
    % Synthesize continuous sensor data at t_n
    
    % Propagate navigation states to t_n using sensor data from t_n-1
    %   Assign inputs to the navigation state DE
    %   Perform one step of RK4 integration
    input_nav.simpar = simpar;
    xhat_buff(:,i) = rk4('navState_de', xhat_buff(:,i-1), input_nav, simpar.general.dt);
    
    % compute estimation errors
    est_error(:,i) = calcErrors(xhat_buff(:,i), x_buff(:,i), simpar);
    % Propagate the covariance to t_n
%     input_cov.ytilde = [];
%     input_cov.simpar = simpar;
%     P_buff(:,:,i) = rk4('navCov_de', P_buff(:,:,i-1), input_cov, ...
%         simpar.general.dt);
    % Propagate the error state from tn-1 to tn if errorPropTestEnable == 1
    if simpar.general.errorPropTestEnable
        input_delx.xhat = xhat_buff(:,i-1);
        input_delx.ytilde = [];
        input_delx.simpar = simpar;
        delx_buff(:,i) = rk4('errorState_de', delx_buff(:,i-1), ...
            input_delx, simpar.general.dt);
    end
    
    % If discrete measurements are available, perform a Kalman update
    if abs(t(i)-t_kalman(k+1)) < simpar.general.dt*0.01
        %   Check error state propagation if simpar.general.errorPropTestEnable = true
        if simpar.general.errorPropTestEnable
            checkErrorPropagation(x_buff(:,i), xhat_buff(:,i),...
                delx_buff(:,i), simpar);
        end
        %Adjust the Kalman update index
        k = k + 1;
        %   For each available measurement
        %       Synthesize the noisy measurement, ztilde
        %       Predict the measurement, ztildehat
        %       Compute the measurement sensitivity matrix, H
        %       If simpar.general.measLinerizationCheckEnable == true
        %           Check measurement linearization
        %       Compute and save the residual
        %       Compute and save the residual covariance
        %       Compute and save the Kalman gain, K
        %       Estimate the error state vector
        %       Update and save the covariance matrix
        %       Correct and save the navigation states
        
        
        
        % prep the inputs for measurement synthesation
        input_synthMeas.nu = zeros(length(x_buff(:,1)),1);
        input_synthMeas.simpar = simpar;
        % synthesize measurement        
        ztilde_tdoa(:,k) = tdoa.synthesize_measurement(x_buff(:,i), input_synthMeas);
        % prep the inputs for predicting measurement
        input_predMeas.simpar = simpar;
        input_predMeas.chaserStates = x_buff(1:simpar.general.n_chaser*simpar.general.n_assets,i);
        ztildehat_tdoa(:,k) = tdoa.predict_measurement(xhat_buff(:,i), input_predMeas);
%         H_tdoa = tdoa.compute_H();
%         tdoa.validate_linearization();
        res_tdoa(:,k) = tdoa.compute_residual(ztilde_tdoa(:,k), ztildehat_tdoa(:,k));
%         resCov_tdoa(:,k) = compute_residual_cov();
%         K_tdoa_buff(:,:,k) = compute_Kalman_gain();
%         del_x = estimate_error_state_vector();
%         P_buff(:,:,k) = update_covariance();
%         xhat_buff(:,i) = correctErrors();
    end
    if verbose && mod(i,100) == 0
        fprintf('%0.1f%% complete\n',100 * i/nstep);
    end
end

if verbose
    fprintf('%0.1f%% complete\n',100 * t(i)/t(end));
end

T_execution = toc;
%Package up residuals
navRes.tdoa = res_tdoa;
% navResCov.tdoa = resCov_tdoa;
% kalmanGains.tdoa = K_tdoa_buff;
%Package up outputs
traj = struct('navState',xhat_buff,...
    'navRes',navRes,...
    'truthState',x_buff,...
    'time_nav',t,...
    'time_kalman',t_kalman,...
    'executionTime',T_execution,...
    'simpar',simpar,...
    'ztilde_tdoa',ztilde_tdoa,...
    'ztildehat_tdoa',ztildehat_tdoa,...
    'est_error',est_error);
% traj = struct('navState',xhat_buff,...
%     'navCov',P_buff,...
%     'navRes',navRes,...
%     'navResCov',navResCov,...
%     'truthState',x_buff,...
%     'time_nav',t,...
%     'time_kalman',t_kalman,...
%     'executionTime',T_execution,...
%     'continuous_measurements',ytilde_buff,...
%     'kalmanGain',kalmanGains,...
%     'simpar',simpar);
end