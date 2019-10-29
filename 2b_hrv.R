#!/usr/bin/env Rscript

## Read in HRV {{{

# Can only be run after matlab
rawfile <- read_csv(Sys.glob(file.path(folder, "*allwindows*.csv")), col_names = TRUE)

# Pick out relevant columns
svar <- c("t_start", "NNmean", "SDNN", "RMSSD", "pnn50", "ulf", "vlf", "lf", "hf", "lfhf", "ttlpwr", "ac", "dc", "SampEn", "ApEn")
df <- rawfile[svar] %>% na.omit()
names(df) <- c("time", "NN", "SDNN", "RMSSD", "PNN50", "ULF", "VLF", "LF", "HF", "LFHF", "TP", "AC", "DC", "SampEn", "ApEn")

# Saved final HRV data
df_hrv <- df

# Removed files
removed <- read_csv(Sys.glob(file.path(folder, "Removed*")), col_names = TRUE)

# HRV parameters
hrvparams <- read_csv(Sys.glob(file.path(folder, "Parameters*.csv")), col_names = TRUE)

# Cath/chart data
# Including timing
interventions <- read_excel(Sys.glob(file.path(raw_folder, "patient_log.xlsx")))

# }}}

