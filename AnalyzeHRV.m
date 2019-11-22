% Analyze HRV for each patient that gave raw data
% Summary function for analylzing HRV data en masse
% Uses HRV toolbox heavily

%% Set up environment

% Clear workspace
clear; clc; close all;

% Add necessary files to path
% Need to be in highest biobank folder
addpath(genpath(pwd));

% Folder holding data
raw_folder = [pwd filesep 'raw_data'];

% Target folder for patient data
proc_folder = [pwd filesep 'proc_data'];

% Identify all VivaLNK files
files = dir(fullfile(raw_folder, '*.txt'));
%patients = regexprep({files.name}, '.txt', '');
%numsub = length(patients);

% Restrict to just new, unprocessed data
log = readtable([raw_folder filesep 'patient_log.xlsx']);
patients = log.ID(log.Status == "processed")';
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
  raw_ecg = load([proc_folder filesep name filesep name '_ecg.mat'], 'ecg');
  ecg = raw_ecg.ecg;
  t = load([proc_folder filesep name filesep name '_ecg.mat'], 't');

  % Graph ECG signal into MATLAB file for visualization of errors/quality

  % Create time vector for visualizing data
  %Fs = HRVparams.Fs;
  %tm = 0:1/Fs:(length(ecg)-1)/Fs;
  % plot the signal
  %figure(1);
  %plot(tm,ecg);
  %xlabel('[s]');
  %ylabel('[mV]');

  % call the function that perform peak detection
  % added a multiplier of a 1000 to get a detection of value
  %r_peaks = jqrs(ecg,HRVparams);

  % plot the detected r_peaks on the top of the ecg signal
  %figure(1);
  %hold on;
  %plot(r_peaks./Fs, ecg(r_peaks),'o');
  %legend('ecg signal', 'detected R peaks');

  % Save file
  %saveas(figure(1), [proc_folder filesep name filesep name '.fig']);

  % Run the HRV analysis
  [results, resFilenameHRV] = ...
      Main_HRV_Analysis(ecg, [], 'ECGWaveform', HRVparams, name);
  
  % STop time
  toc
  fprintf('HRV analysis done for %s.\n', name);

end
fprintf('Total Run Time...');
toc

