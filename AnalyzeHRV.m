% Analyze HRV for each patient that gave raw data
% Summary function for analylzing HRV data en masse
% Uses HRV toolbox heavily

% Clear workspace
clear; clc; close all;

% Add necessary files to path
% Need to be in highest biobank folder
addpath(genpath(pwd));

% Folder holding data
folder = [pwd filesep 'raw_patients'];

% Identify all VivaLNK files
files = dir(fullfile(folder, '*.txt'));
patients = regexprep({files.name}, '.txt', '');
numsub = length(patients);

% Loop, timed with tic toc
tic
parfor i = 1:numsub
  % Make a folder
  name = patients{i};
  mkdir(folder, name);
  
  % VivaLNK parser to run and make .mat files for ECG and ACC data
  % Move this into output folder
  VivaLNK_parser_beta(folder, patients{1});
  movefile([folder filesep '*.mat'], [folder filesep name]);

  % Initialize HRV parameters
  HRVparams = InitializeHRVparams(name);
  HRVparams.readdata = [folder filesep name];
  HRVparams.writedata = [folder filesep name];
  HRVparams.MSE.on = 0; % No MSE analysis for this demo
  HRVparams.DFA.on = 0; % No DFA analysis for this demo
  HRVparams.HRT.on = 0; % No HRT analysis for this demo
  HRVparams.output.separate = 1; % Write out results per patient
  
  % Extract ECG signal
  raw_ecg = load([folder filesep name filesep name '_ecg.mat'], 'ecg');
  ecg = raw_ecg.ecg;
  t = load([folder filesep name filesep name '_ecg.mat'], 't');
  
  % Graph ECG signal into MATLAB file for visualization of errors/quality
  
  % Create time vector for visualizing data
  Fs = HRVparams.Fs;
  tm = 0:1/Fs:(length(ecg)-1)/Fs;
  % plot the signal
  figure(1);
  plot(tm,ecg);
  xlabel('[s]');
  ylabel('[mV]');
  
  % call the function that perform peak detection
  % added a multiplier of a 1000 to get a detection of value
  r_peaks = jqrs(ecg,HRVparams);

  % plot the detected r_peaks on the top of the ecg signal
  figure(1);
  hold on;
  plot(r_peaks./Fs, ecg(r_peaks),'o');
  legend('ecg signal', 'detected R peaks');

  % Save file
  saveas(figure(1), [folder filesep name filesep name '.fig'])

  % Run the HRV analysis
  [results, resFilenameHRV] = ...
      Main_HRV_Analysis(ecg, [], 'ECGWaveform', HRVparams, name);
  
end
toc