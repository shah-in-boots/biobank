#!/bin/bash

#$ -cwd -V

# Matlab script
matlab -nodisplay -r AnalyzeHRV > AnalyzeHRV.output
