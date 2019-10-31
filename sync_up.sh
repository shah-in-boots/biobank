#!/bin/bash

# Add the log files to the raw patient folder on the cluster for analysis
rsync -arvuz ./ asshah4@hpc5.sph.emory.edu:projects/biobank/ --delete-after
