#!/bin/bash

#$ -cwd -V
#$ -S /bin/bash

# Matlab script
matlab -nodisplay -r ExtractIntervals > cluster.log

