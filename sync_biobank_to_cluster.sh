#!/bin/bash

# Add the log files to the raw patient folder on the cluster for analysis
rsync -arvuz ./raw_data/ asshah4@hpc5.sph.emory.edu:projects/biobank/raw_data/ --delete-after
