% Example MATLAB submission script for running a parallel job on the 
% SNS Hyperion Cluster
% Mar-2014 Lee Colbert, lcolbert@ias.edu

% Modify these lines to suit your job requirements.
cluster = parallel.cluster.Generic('JobStorageLocation', '/home/asshah4/projects/biobank');
h_rt = '00:15:00';
exclusive = 'false';

% Do not modify these lines
set(cluster, 'HasSharedFilesystem', true);
set(cluster, 'ClusterMatlabRoot', '/usr/local/matlab');
set(cluster, 'OperatingSystem', 'unix');
set(cluster, 'NumWorkers',16);
set(cluster, 'IndependentSubmitFcn', {@independentSubmitFcn,h_rt,exclusive});
set(cluster, 'CommunicatingSubmitFcn', {@communicatingSubmitFcn,h_rt,exclusive});
set(cluster, 'GetJobStateFcn', @getJobStateFcn);
set(cluster, 'DeleteJobFcn', @deleteJobFcn);

% Create parallel job with default settings.
%pjob = createCommunicatingJob(cluster, 'Type', 'SPMD');
pjob = createCommunicatingJob(cluster, 'Type', 'pool');

% Specify the number of workers required for execution of your job
pjob.NumWorkersRange = [1 16];

% Add a task to the job. 
createTask(pjob, AnalyzeHRV, 1, {});

% Submit the job to the cluster
submit(pjob);

% Wait for the job to finish running, and retrieve the results.
% This is optional. Your program will block here until the parallel
% job completes. If your program is writing it's results to file, you
% many not want this, or you might want to move this further down in your
% code, so you can do other stuff while pjob runs.
wait(pjob, 'finished');
results = fetchOutputs(pjob);

% This checks for errors from individual tasks and reports them.
% very useful for debugging
errmsgs = get(pjob.Tasks, {'ErrorMessage'});
nonempty = ~cellfun(@isempty, errmsgs);
celldisp(errmsgs(nonempty));

% Display the results
disp(results);

% Destroy job
% For parallel jobs, I recommend NOT using the destroy command, since it
% causes the SGE jobs to exit with an Error due to a race condition. If you
% insist on using it to clean up the 'Job' files and subdirectories in your
% working directory, you must include the pause statement to avoid the job 
% finishing in SGE with a Error. 
%pause(16);
%destroy(pjob);
