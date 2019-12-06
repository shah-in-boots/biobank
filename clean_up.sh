#!/bin/bash

# To clean up all the parameter files that are old
for d in ./proc_data/*/; do (cd "$d" && ls -t Param*.csv | sed '1d' | xargs rm); done
for d in ./proc_data/*/; do (cd "$d" && ls -t Param*.tex | sed '1d' | xargs rm); done

# Removed WIndows file
for d in ./proc_data/*/; do (cd "$d" && ls -t Removed*.csv | sed '1d' | xargs rm); done

# HRV result files
for d in ./proc_data/*/; do (cd "$d" && ls -t *HRV_results*.csv | sed '1d' | xargs rm); done

