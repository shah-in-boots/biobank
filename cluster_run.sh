#!/bin/bash

# Ensure in same directory as running file
#$ -cwd

# Matlab script
matlab -nodisplay -r "AnalyzeHRV"
