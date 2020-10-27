function [ simparams, simparamsref ] = createSimParams( parameterFile)
%% Read general simulation parameters
t = readtable(parameterFile,'sheet','general');
[n,~] = size(t);
for i=1:n
    simparams.general.(t.Name{i}) = t.MatlabValues(i);
end
%% Read initial conditions
t = readtable(parameterFile,'sheet','initialConditions');
[n,~] = size(t);
for i=1:n
    simparams.general.ic.(t.Name{i}) = t.MatlabValues(i);
end
%% Read truth state parameters
t = readtable(parameterFile,'sheet','truthStateParams');
[n,~] = size(t);
for i=1:n
    simparams.truth.params.(t.Name{i}) = t.MatlabValues(i);
end
%% Read truth state initial uncertainty
t = readtable(parameterFile,'sheet','truthStateInitialUncertainty');
[n,~] = size(t);
for i=1:n
    simparams.truth.ic.(t.Name{i}) = t.MatlabValues(i);
end
%% Read navigation state parameters
t = readtable(parameterFile,'sheet','navStateParams');
[n,~] = size(t);
for i=1:n
    simparams.nav.params.(t.Name{i}) = t.MatlabValues(i);
end
%% Read navigation state initial uncertainty
t = readtable(parameterFile,'sheet','navStateInitialUncertainty');
[n,~] = size(t);
for i=1:n
    simparams.nav.ic.(t.Name{i}) = t.MatlabValues(i);
end
%% Read error injection
t = readtable(parameterFile,'sheet','errorInjection');
[n,~] = size(t);
for i=1:n
    simparams.errorInjection.(t.Name{i}) = t.MatlabValues(i);
end
%% Read state indices
t = readtable(parameterFile,'sheet','truthStateIdx');
[n,~] = size(t);
for i=1:n
    name = t.State{i};
    simparams.states.ix.(name) = t.start_idx(i):t.end_idx(i);
    simparams.states.ixe.(name) = t.error_start_idx(i):t.error_end_idx(i);
end
% simparams.states.nx = max(t.end_idx);
% simparams.states.nxe = max(t.error_end_idx);
simparams.states.nx  = 9 + 7 * simparams.general.n_assets;
simparams.states.nxe = 9 + 7 * simparams.general.n_assets;

t = readtable(parameterFile,'sheet','navStateIdx');
[n,~] = size(t);
for i=1:n
    name = t.State{i};
    simparams.states.ixf.(name) = t.start_idx(i):t.end_idx(i);
    simparams.states.ixfe.(name) = t.error_start_idx(i):t.error_end_idx(i);
end
simparams.states.nxf = max(t.end_idx);
simparams.states.nxfe = max(t.error_end_idx);
% simparams.states.nxf = 12

%% Read Constants
t = readtable(parameterFile,'sheet','Constants');
[n,~] = size(t);
for i=1:n
    simparams.Constants.(t.Name{i}) = t.Value(i);
end
%% Create reference trajectory simparams
%With all process noise, initial conditions, and measurement noise turned off)
simparamsref = simparams;
truthInitialUncertainty = fieldnames(simparamsref.truth.ic);
for i=1:length(truthInitialUncertainty)
    simparamsref.truth.ic.(truthInitialUncertainty{i}) = 0;
end
truthParams = fieldnames(simparamsref.truth.params);
for i=1:length(truthParams)
    simparamsref.truth.params.(truthParams{i}) = 0;
end

end