#!/bin/bash

# Sync back down to biobank 
rsync -arvuzn asshah4@hpc5.sph.emory.edu:projects/biobank/ ./ --delete-after
