#!/bin/bash

# Add the log files to the raw patient folder on the cluster for analysis
rsync -arvuz ./raw_patients/ asshah4@hpc5.sph.emory.edu:projects/biobank/raw_patients/ --delete-after
