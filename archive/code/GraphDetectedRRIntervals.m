% File to visualize ECG morphology and labeled RR peaks
function patient = GraphDetectedRRIntervals(name)

% Add all necessary files to path
addpath(genpath(pwd));

% Folder holding data
raw_folder = [pwd filesep 'raw_patients'];

% Target folder for patient data
proc_folder = [pwd filesep 'proc_patients'];

% Remove pre-existing parameter files
delete([proc_folder filesep name filesep 'Parameters*']);
delete([proc_folder filesep name filesep '*.fig']);

% VivaLNK parser to run and make .mat files for ECG and ACC data
% Move this into output folder
VivaLNK_parser_beta(raw_folder, name);
movefile([raw_folder filesep name '*.mat'], [proc_folder filesep name]);

% Load ECG signal, leave time stamps behind
ecg = load([proc_folder filesep name filesep name '_ecg.mat'], 'ecg');
ecg = ecg.ecg;

% Load basic paramaters of HRV Analysis, including sample frequency
HRVparams = InitializeHRVparams(name);
Fs = HRVparams.Fs;

% Create time vector for visualizing data
tm = 0:1/Fs:(length(ecg)-1)/Fs;

% plot the signal
figure(1);
plot(tm,ecg);
xlabel('[s]');
ylabel('[mV]');

% call the function that perform peak detection
% added a multiplier of a 1000 to get a detection of value
r_peaks = jqrs(ecg, HRVparams);

% plot the detected r_peaks on the top of the ecg signal
figure(1);
hold on;
plot(r_peaks./Fs, ecg(r_peaks),'o');
legend('ecg signal', 'detected R peaks');

% Save file
saveas(figure(1), [proc_folder filesep name filesep name '.fig'])

% end of file
end
