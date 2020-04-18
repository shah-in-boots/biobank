% Extract RR intervals for each patient

%% Set up environment

% Clear workspace
clear; clc; 

% Add necessary files to path
% Need to be in highest biobank folder
addpath(genpath(pwd));

% Folder holding data
raw_folder = [pwd filesep 'raw_data'];

% Target folder for patient data
proc_folder = [pwd filesep 'proc_data'];

% Identify all VivaLNK files
files = dir(fullfile(raw_folder, '*.txt'));

% Identify all VivaLNK files
files = dir(fullfile(raw_folder, '*.txt'));
patients = regexprep({files.name}, '.txt', '');
numsub = length(patients);

%% Parallel for loop for analysis

% Loop, timed with tic toc
tic
parfor i = 1:numsub
  % Time it
  tic

  % Make a folder
  name = patients{i};
  mkdir(proc_folder, name);

  % VivaLNK parser to run and make .mat files for ECG and ACC data
  % Move this into output folder
  fprintf('Vivalnk about to start processing patient %s.\n', name);
  VivaLNK_parser_beta(raw_folder, patients{i});
  movefile([raw_folder filesep name '*.mat'], [proc_folder filesep name]);
  toc
  fprintf('Vivalnk processing completed for %s.\n', name);

  % Initialize HRV parameters
  HRVparams = InitializeHRVparams(name);
  HRVparams.readdata = [proc_folder filesep name];
  HRVparams.writedata = [proc_folder filesep name];
  HRVparams.MSE.on = 0; % No MSE analysis for this demo
  HRVparams.DFA.on = 0; % No DFA analysis for this demo
  HRVparams.HRT.on = 0; % No HRT analysis for this demo
  HRVparams.output.separate = 1; % Write out results per patient

  % Extract ECG signal
  fprintf('Extracting ECG from mat files for patient %s.\n', name);
  raw_ecg = load([proc_folder filesep name filesep name '_ecg.mat'], 'ecg');
  ecg = raw_ecg.ecg;
  t = load([proc_folder filesep name filesep name '_ecg.mat'], 't');

  % Extract RR intervals for each patien
  fprintf('Making RR intervals for patient %s.\n', name);
  [t_RR, rr, jqrs_ann, SQIjw, StartIdxSQIwindows_jw] = ... 
      ConvertRawDataToRRIntervals(ecg, HRVparams, name);

  % Save the RR table
  m = [t_RR(:), rr(:)];
  T = array2table(m, 'VariableNames',{'time','rr'});
  writetable(T, [proc_folder filesep name filesep name '_rr.csv']);

  % Stop time
  toc
  fprintf('Analysis done for %s.\n', name);

end
fprintf('Total Run Time...');
toc

