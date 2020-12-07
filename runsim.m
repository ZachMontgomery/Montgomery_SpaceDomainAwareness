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

Na = simpar.general.n_assets;
Ntdoa = 0;
for i=1:Na-1
    Ntdoa = Ntdoa + i;
end
Ntdoa = Na - 1;
Nd = simpar.general.n_design;

axis = {'x','y','z'};

%% Pre-allocate buffers for saving data
% Truth, navigation, and error state buffers
x_buff          = zeros(simpar.states.nx,nstep);
xhat_buff       = zeros(simpar.states.nxf,nstep);
delx_buff       = zeros(simpar.states.nxfe,nstep);
est_error       = zeros(simpar.states.nxf,nstep);

% Navigation covariance buffer
P_buff          = zeros(simpar.states.nxfe,simpar.states.nxfe,nstep);

% Continuous measurement buffer
% ytilde_buff     = zeros(simpar.general.n_inertialMeas,nstep);

% Residual buffers
res_tdoa        = zeros(Ntdoa,nstep_aid);

% TDOA measurement buffers
ztilde_tdoa     = zeros(Ntdoa,nstep_aid);
ztildehat_tdoa  = zeros(Ntdoa,nstep_aid);
resCov_tdoa     = zeros(Ntdoa,Ntdoa,nstep_aid);
K_tdoa_buff     = zeros(Nd,Ntdoa,nstep_aid);

%% Initialize Vectors and matrices

% % Initialize the navigation covariance matrix
P_buff(:,:,1) = initialize_covariance(simpar);

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
    % bias errors
    for i=1:Na
        delx_buff(i,1) = simpar.errorInjection.(['b',int2str(i)]);
    end
    for i=1:3
        delx_buff(Na+i,1) = simpar.errorInjection.(['pt',axis{i}]);
        delx_buff(Na+3+i,1) = simpar.errorInjection.(['vt',axis{i}]);
        delx_buff(Na+6+i,1) = simpar.errorInjection.(['a',axis{i}]);
    end
    xhat_buff(:,1) = injectErrors(truth2nav(x_buff(:,1),simpar), ...
        delx_buff(:,1), simpar);
end

%% Compute the constant process noise PSD's
Q = calc_Q( simpar );
%% Compute the constant measurement noise matrix R
R = eye(Na) * (2.e-8 - simpar.truth.params.sig_b1_ss);
G = calc_G( simpar );
%% Loop over each time step in the simulation
for i=2:nstep
    % Propagate truth states to t_n
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Realize a sample of process noise (don't forget to scale Q by 1/dt!)
    %   Define any inputs to the truth state DE
    input_truth.w = sqrt(Q / simpar.general.dt) * randn(Na+6,1);  
    input_truth.simpar = simpar;
    
    % debugging by turning of some error sources
    % input_truth.w(:) = 0;
    
    %   Perform one step of RK4 integration
    x_buff(:,i) = rk4('truthState_de', x_buff(:,i-1), input_truth, ...
        simpar.general.dt);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Synthesize continuous sensor data at t_n
    
    % Propagate navigation states to t_n using sensor data from t_n-1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Assign inputs to the navigation state DE
    input_nav.simpar = simpar;
    %   Perform one step of RK4 integration
    xhat_buff(:,i) = rk4('navState_de', xhat_buff(:,i-1), input_nav, ...
        simpar.general.dt);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % compute estimation errors
    est_error(:,i) = calcErrors(xhat_buff(:,i), x_buff(:,i), simpar);
    
    % Propagate the covariance to t_n
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Assign inputs to the navigation covariance DE
    input_cov.simpar = simpar;
    input_cov.xhat = xhat_buff(:,i-1);
    %   Perform one step of RK4 integration
    P_buff(:,:,i) = rk4('navCov_de', P_buff(:,:,i-1), input_cov, ...
            simpar.general.dt);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Propagate the error state from tn-1 to tn if errorPropTestEnable == 1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if simpar.general.errorPropTestEnable
        % Assign inputs for the error state DE
        input_delx.xhat = xhat_buff(:,i-1);
        input_delx.simpar = simpar;
        input_delx.w = zeros(simpar.general.n_design,1);
        % Perform one step of RK4 integration
        delx_buff(:,i) = rk4('errorState_de', delx_buff(:,i-1), ...
            input_delx, simpar.general.dt);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % If discrete measurements are available, perform a Kalman update
    if abs(t(i)-t_kalman(k+1)) < simpar.general.dt*0.01
        % Check error state prop if simpar.general.errorPropTestEnable = true
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % prep the inputs for measurement synthesation
        input_synthMeas.nu = R * randn(Na,1);
        input_synthMeas.simpar = simpar;
        % synthesize measurement        
        ztilde_tdoa(:,k) = tdoa.synthesize_measurement(x_buff(:,i), ...
            input_synthMeas);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % prep the inputs for predicting measurement
        input_predMeas.simpar = simpar;
        input_predMeas.chaserStates = x_buff(1:simpar.general.n_chaser*Na,i);
        ztildehat_tdoa(:,k) = tdoa.predict_measurement(xhat_buff(:,i), ...
            input_predMeas);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % compute H matrix
        H_tdoa = tdoa.compute_H( xhat_buff(:,i), input_predMeas );
        % check for measurement linearization Check
        if simpar.general.measLinerizationCheckEnable
            % prep inputs for measurement linearization check
            input_validateHlinearization.simpar = simpar;
            input_validateHlinearization.x = x_buff(:,i);
            input_validateHlinearization.ztilde = ztilde_tdoa(:,k);
            % validate measurement linearization
            tdoa.validate_linearization(input_validateHlinearization);
            % compute measurement residual
            res_tdoa(:,k) = tdoa.compute_residual(ztilde_tdoa(:,k), ...
                ztildehat_tdoa(:,k));
        end
        resCov_tdoa(:,:,k) = compute_residual_cov(H_tdoa,P_buff(:,:,i),G,R);
        K_tdoa_buff(:,:,k) = compute_Kalman_gain(P_buff(:,:,i),H_tdoa,resCov_tdoa(:,:,k));
        del_x = estimate_error_state_vector(K_tdoa_buff(:,:,k),...
            tdoa.compute_residual(ztilde_tdoa(:,k), ztildehat_tdoa(:,k)));
        P_buff(:,:,i) = update_covariance(K_tdoa_buff(:,:,k), H_tdoa, P_buff(:,:,i), G, R, simpar);
        xhat_buff(:,i) = correctErrors(xhat_buff(:,i),del_x,simpar);
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
% navRes.tdoa = res_tdoa;
% navResCov.tdoa = resCov_tdoa;
% kalmanGains.tdoa = K_tdoa_buff;
%Package up outputs
traj = struct('navState',xhat_buff,...
    'navCov',P_buff,...
    'truthState',x_buff,...
    'time_nav',t,...
    'time_kalman',t_kalman,...
    'executionTime',T_execution,...
    'simpar',simpar,...
    'ztilde_tdoa',ztilde_tdoa,...
    'ztildehat_tdoa',ztildehat_tdoa,...
    'est_error',est_error);
%     'navRes',navRes,...
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