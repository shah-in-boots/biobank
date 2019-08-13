#!/bin/bash

rsync -arvuz ./raw_patients/ asshah4@hpc5.sph.emory.edu:projects/biobank/raw_patients/ --delete-after
