# I'm glad you asked about the parallel for-loop.   There have been a number of "sneaky core assignment" -type programs submitted lately (mostly in R) and I am having to crack down on those kind of submissions, as they are crashing machines.   I would use a for loop in my job submission script that calls SGE (qsub) within it, and submit different input and output parameters for each iteration.  That way there is a one-to-one job to job-submission ratio, and none of the processors will get overloaded (without GE's knowledge).

# Another way to to it maybe to use job arrays (I'm cutting from another response I've written):

# This utilizes the -t flag to qsub, for example "qsub -t 1-20 my_job.sh'.   They are good for embarrassingly parallel jobs in that one submission can launch a large number of similar jobs. Such a script might look like this:

#!/bin/bash
#
#$ -t 1-100
#
echo "Task id is $SGE_TASK_ID"

./myprog.exe $SGE_TASK_ID > output.$SGE_TASK_ID
The variable $SGE_TASK_ID allows you to refer to a particular instance, and could be used to alter the parameters for a set of jobs.

Here is an example I found that uses the array to change the inputs:


# Tell SGE that this is an array job, with "tasks" numbered from 1 to 150
#$ -t 1-150

# Run the application passing in the input and output filenames
./myprog < data.$SGE_TASK_ID > results.$SGE_TASK_ID


# Use current working directory
#$ -cwd -V

# Array job
